import 'package:parent_5sur5/features/favorites/domain/repositories/favorites_repository.dart';

class ToggleFavoriteUseCase {
  final FavoritesRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<void> execute(String publicationId, bool isLiked, String token) async {
    await repository.toggleLike(publicationId, isLiked, token);
  }
}