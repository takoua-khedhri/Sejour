import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:parent_5sur5/features/home/domain/entities/sejour.dart';
import 'package:parent_5sur5/features/sejour_info/presentation/blocs/sejour_info_bloc.dart';
import 'package:parent_5sur5/features/sejour_info/domain/usecases/get_sejour_info_usecase.dart';
import 'package:parent_5sur5/features/sejour_info/data/repositories/sejour_info_repository_impl.dart';
import 'package:parent_5sur5/features/sejour_info/data/datasources/sejour_info_remote_datasource.dart';
import 'package:parent_5sur5/features/sejour_info/presentation/widgets/sejour_info_item.dart';

class SejourInfoScreen extends StatelessWidget {
  final String codeSejour;
  final String token;
  final Sejour? initialSejour; // Rendons-le optionnel

  const SejourInfoScreen({
    required this.codeSejour,
    required this.token,
    this.initialSejour, // Plus besoin de valeur par défaut ici
    Key? key,
  }) : super(key: key);

  @override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (context) {
      final dio = Dio();
      final remoteDataSource = SejourInfoRemoteDataSource(dio);
      final repository = SejourInfoRepositoryImpl(remoteDataSource);
      final getSejourInfo = GetSejourInfoUseCase(repository: repository);

      return SejourInfoBloc(getSejourInfo: getSejourInfo)
        ..add(LoadSejourInfo(
          codeSejour: codeSejour, 
          token: token,
          initialSejour: initialSejour,
        ));
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Informations du Séjour'),
        elevation: 0,
      ),
      body: BlocListener<SejourInfoBloc, SejourInfoState>(
        listener: (context, state) {
          if (state is SejourInfoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: const SejourInfoItem(),
      ),
    ),
  );
}
}