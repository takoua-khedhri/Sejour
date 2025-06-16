import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parent_5sur5/features/home/domain/entities/publication.dart';
import 'package:parent_5sur5/features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:parent_5sur5/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:parent_5sur5/features/favorites/presentation/blocs/favorites_event.dart';
import 'package:parent_5sur5/features/favorites/presentation/blocs/favorites_state.dart';
import 'package:flutter/foundation.dart'; 

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavorites;
  final ToggleFavoriteUseCase toggleFavorite;

  FavoritesBloc({
    required this.getFavorites,
    required this.toggleFavorite,
  }) : super(FavoritesInitial()) {
    on<LoadFavorites>((event, emit) async {
      emit(FavoritesLoading());
      try {
        final favorites = await getFavorites.execute(event.codeSejour, event.token);
        emit(FavoritesLoaded(favorites));
      } catch (e) {
        emit(FavoritesError('Impossible de charger les favoris'));
      }
    });

    on<ToggleFavorite>((event, emit) async {
  try {
    // Mise à jour optimiste UI
    if (state is FavoritesLoaded) {
      final list = (state as FavoritesLoaded).favorites.map((p) => 
        p.id == event.publicationId ? p.copyWith(isLiked: event.isLiked) : p
      ).toList();
      emit(FavoritesLoaded(list));
    }
    
    await toggleFavorite.execute(event.publicationId, event.isLiked, event.token);
    
  } catch (e) {
    debugPrint('Erreur Bloc: $e');
  }
});
  }
}