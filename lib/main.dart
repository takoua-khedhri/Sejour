import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Home imports
import 'features/home/domain/entities/sejour.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/data/datasources/home_remote_datasource.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/usecases/get_sejour_usecase.dart';
import 'features/home/domain/usecases/get_day_description_usecase.dart';
import 'features/home/domain/usecases/get_publications_usecase.dart';
import 'features/home/presentation/blocs/home_bloc.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/favorites/domain/repositories/favorites_repository.dart';
// Login imports
import 'features/login/presentation/blocs/login_bloc.dart';
import 'features/login/presentation/blocs/login_state.dart';
import 'features/login/presentation/screens/login_screen.dart';
import 'features/login/domain/usecases/login_usecase.dart';
import 'features/login/data/repositories/login_repository_impl.dart';
import 'features/login/data/datasources/login_remote_datasource.dart';

// Logout imports
import 'features/logout/presentation/blocs/logout_bloc.dart';
import 'features/logout/domain/usecases/logout_usecase.dart';
import 'features/logout/data/repositories/logout_repository_impl.dart';

// Audio imports
import 'features/audio/data/datasources/audio_remote_datasource.dart';
import 'features/audio/data/repositories/audio_repository_impl.dart';
import 'features/audio/domain/repositories/audio_repository.dart';
import 'features/audio/domain/usecases/get_audios_usecase.dart';
import 'features/audio/presentation/bloc/audio_bloc.dart';

// Favorites imports
import 'features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/favorites/domain/repositories/favorites_repository.dart';
import 'features/favorites/presentation/blocs/favorites_bloc.dart';
import 'features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'features/favorites/domain/usecases/toggle_favorite_usecase.dart';

// IA imports

Future<void> main() async {
  CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    debugPrint('Global error: ${details.exception}');
  };

  await initializeDateFormatting('fr_FR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://media.5sur5sejour.com/api/',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));

    final loginRemoteDataSource = LoginRemoteDataSource(dio: dio);
    final loginRepository = LoginRepositoryImpl(loginRemoteDataSource);
    final loginUseCase = LoginUseCase(repository: loginRepository);

    final homeRemoteDataSource = HomeRemoteDataSource(dio);
    final homeRepository = HomeRepositoryImpl(homeRemoteDataSource);
    final getSejourUsecase = GetSejourUseCase(homeRepository);
    final getDayDescriptionUsecase = GetDayDescriptionUseCase(homeRepository);
    final getPublicationsUsecase = GetPublicationsUseCase(homeRepository);

    final logoutRepository = LogoutRepositoryImpl();
    final logoutUseCase = LogoutUseCase(logoutRepository);

    final audioRemoteDataSource = AudioRemoteDataSource(dio: dio);
    final audioRepository = AudioRepositoryImpl(audioRemoteDataSource);
    final getAudiosUseCase = GetAudiosUseCase(audioRepository);

    // Ajout du service IA

    final favoritesRemoteDataSource = FavoritesRemoteDataSource(dio);
    final favoritesRepository = FavoritesRepositoryImpl(
      remote: favoritesRemoteDataSource,
    );

    final getFavoritesUseCase = GetFavoritesUseCase(repository: favoritesRepository);
    final toggleFavoriteUseCase = ToggleFavoriteUseCase(favoritesRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginBloc(loginUseCase: loginUseCase)),
        BlocProvider(create: (_) => LogoutBloc(logoutUseCase)),
        BlocProvider(
          create: (_) => AudioBloc(
            getAudiosUseCase: getAudiosUseCase,
            audioRepository: audioRepository,
          ),
        ),
        BlocProvider(
          create: (_) => FavoritesBloc(
            getFavorites: getFavoritesUseCase,
            toggleFavorite: toggleFavoriteUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
        ],
        home: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => HomeBloc(
                          getSejour: getSejourUsecase,
                          getPublications: getPublicationsUsecase,
                          getDayDescription: getDayDescriptionUsecase,
                          favoritesRepository: favoritesRepository,
                          token: state.token,
                        ),
                      ),
                      BlocProvider.value(
                        value: context.read<LogoutBloc>(),
                      ),
                    ],
                    child: HomeScreen(
                      codeSejour: state.codeSejour,
                      token: state.token,
                      sejour: null, // Vous devez fournir un objet Sejour valide ici
                    ),
                  ),
                ),
              );
            } else if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: const LoginScreen(),
        ),
      ),
    );
  }
}