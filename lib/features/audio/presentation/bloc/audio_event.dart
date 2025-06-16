part of 'audio_bloc.dart';

abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object> get props => [];
}

class LoadAudiosEvent extends AudioEvent {
  final String codeSejour;
  final String type;
  final String date;
  final String token;

  const LoadAudiosEvent({
    required this.codeSejour,
    required this.type,
    required this.date,
    required this.token,
  });

  @override
  List<Object> get props => [codeSejour, type, date, token];
}

class ToggleAudioLikeEvent extends AudioEvent {
  final String audioId;
  final bool isLiked;
  final String token;

  const ToggleAudioLikeEvent({
    required this.audioId,
    required this.isLiked,
    required this.token,
  });

  @override
  List<Object> get props => [audioId, isLiked, token];
}