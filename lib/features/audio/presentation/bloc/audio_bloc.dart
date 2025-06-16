import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/audio.dart';
import '../../domain/usecases/get_audios_usecase.dart';
import '../../domain/repositories/audio_repository.dart';

part 'audio_event.dart';
part 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final GetAudiosUseCase getAudiosUseCase;
  final AudioRepository audioRepository;

  AudioBloc({
    required this.getAudiosUseCase,
    required this.audioRepository,
  }) : super(const AudioState()) {
    on<LoadAudiosEvent>(_onLoadAudios);
  }

  Future<void> _onLoadAudios(
    LoadAudiosEvent event,
    Emitter<AudioState> emit,
  ) async {
    emit(state.copyWith(status: AudioStatus.loading));
    
    try {
      final audios = await getAudiosUseCase(
        event.codeSejour,
        event.type,
        event.date,
        event.token,
      );
      
      emit(state.copyWith(
        status: AudioStatus.success,
        audios: audios,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AudioStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

   
}