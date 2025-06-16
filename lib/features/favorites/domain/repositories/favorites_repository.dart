import 'package:parent_5sur5/features/home/data/models/publication_model.dart';

abstract class FavoritesRepository {
  Future<List<PublicationModel>> getFavorites(String codeSejour, String token);
  Future<void> toggleLike(String publicationId, bool isLiked, String token);
}