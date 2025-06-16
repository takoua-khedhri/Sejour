import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parent_5sur5/features/login/domain/usecases/login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc({required this.loginUseCase}) : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        final token = await loginUseCase.execute(
            event.username, event.password);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString(
            'codeSejour', event.username); // 👈 Ajout du code séjour

        emit(LoginSuccess(token: token, codeSejour: event.username));
      } catch (e) {
        emit(LoginFailure(
          message: "Identifiants incorrects, veuillez réessayer.",
        ));
      }
    });
  }
}
