import 'package:equatable/equatable.dart';

abstract class FavoritesEvent {}

class LoadFavorites extends FavoritesEvent {
  final String codeSejour;
  final String token;
  LoadFavorites(this.codeSejour, this.token);
}

class ToggleFavorite extends FavoritesEvent {
  final String publicationId;
  final bool isLiked;
  final String token;
  ToggleFavorite(this.publicationId, this.isLiked, this.token);
}