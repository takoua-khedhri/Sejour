import 'package:equatable/equatable.dart';
import 'package:parent_5sur5/features/home/domain/entities/publication.dart';

abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}
class FavoritesLoading extends FavoritesState {}
class FavoritesLoaded extends FavoritesState {
  final List<Publication> favorites;
  FavoritesLoaded(this.favorites);
}
class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);
}