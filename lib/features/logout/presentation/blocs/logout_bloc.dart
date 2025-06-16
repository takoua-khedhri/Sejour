import 'package:flutter_bloc/flutter_bloc.dart';
import 'logout_event.dart';
import 'logout_state.dart';
import 'package:parent_5sur5/features/logout/domain/usecases/logout_usecase.dart';


class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final LogoutUseCase logoutUseCase;

  LogoutBloc(this.logoutUseCase) : super(LogoutInitial()) {
    on<PerformLogout>((event, emit) async {
      emit(LogoutInProgress());
      try {
        await logoutUseCase();
        emit(LogoutSuccess());
        print('Logout success triggered');
      } catch (e) {
        emit(LogoutFailure(e.toString()));
      }
    });
  }
}

