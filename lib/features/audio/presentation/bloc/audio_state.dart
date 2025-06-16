part of 'audio_bloc.dart';

enum AudioStatus { initial, loading, success, failure }

class AudioState extends Equatable {
  final AudioStatus status;
  final List<Audio> audios;
  final String? errorMessage;

  const AudioState({
    this.status = AudioStatus.initial,
    this.audios = const [],
    this.errorMessage,
  });

  AudioState copyWith({
    AudioStatus? status,
    List<Audio>? audios,
    String? errorMessage,
  }) {
    return AudioState(
      status: status ?? this.status,
      audios: audios ?? this.audios,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, audios, errorMessage];
}