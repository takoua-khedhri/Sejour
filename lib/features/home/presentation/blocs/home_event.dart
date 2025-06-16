import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => []; // Changé en Object? pour supporter les valeurs null
}

class LoadHomeEvent extends HomeEvent {
  final String codeSejour;
  final String? date; // Maintenant optionnel (peut être null)
  final String token;
  final String type;

  const LoadHomeEvent({
    required this.codeSejour,
    this.date, // Plus required
    required this.token,
    this.type = 'image,video',
  });

  @override
  List<Object?> get props => [codeSejour, date, token, type]; // Object? pour supporter null
}

class TogglePublicationLikeEvent extends HomeEvent {
  final String publicationId;
  final bool isLiked;
  final String token;

  const TogglePublicationLikeEvent({
    required this.publicationId,
    required this.isLiked,
    required this.token,
  });

  @override
  List<Object> get props => [publicationId, isLiked, token];
}