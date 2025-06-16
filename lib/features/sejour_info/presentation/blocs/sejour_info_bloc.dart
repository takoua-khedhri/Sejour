import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parent_5sur5/features/home/domain/entities/sejour.dart';
import '../../domain/usecases/get_sejour_info_usecase.dart';
import '../../domain/exceptions/sejour_info_exceptions.dart';

part 'sejour_info_event.dart';
part 'sejour_info_state.dart';

class SejourInfoBloc extends Bloc<SejourInfoEvent, SejourInfoState> {
  final GetSejourInfoUseCase getSejourInfo;

  SejourInfoBloc({required this.getSejourInfo}) 
    : super(SejourInfoInitial()) {
    on<LoadSejourInfo>(_onLoadSejourInfo);
  }

 Future<void> _onLoadSejourInfo(
  LoadSejourInfo event,
  Emitter<SejourInfoState> emit,
) async {
  // Utiliser les données initiales seulement si on est dans l'état initial
  if (state is SejourInfoInitial && event.initialSejour != null) {
    emit(SejourInfoLoaded(sejour: event.initialSejour!));
  }

  emit(SejourInfoLoading());
  
  try {
    final sejour = await getSejourInfo.execute(
      codeSejour: event.codeSejour,
      token: event.token,
    );
    emit(SejourInfoLoaded(sejour: sejour));
  } on SejourNetworkException catch (e) {
    // Si échec réseau mais qu'on a des données initiales, les utiliser
    if (event.initialSejour != null) {
      emit(SejourInfoLoaded(sejour: event.initialSejour!));
    } else {
      emit(SejourInfoError(message: e.message));
    }
  } on SejourNotFoundException catch (e) {
    emit(SejourInfoError(message: e.message));
  } catch (e) {
    emit(SejourInfoError(message: 'Erreur inattendue: ${e.toString()}'));
  }
}
}