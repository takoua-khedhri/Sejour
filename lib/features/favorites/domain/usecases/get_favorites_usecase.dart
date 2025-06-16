import 'package:parent_5sur5/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:parent_5sur5/features/home/domain/entities/publication.dart';
import 'package:parent_5sur5/features/home/data/models/publication_model.dart';

class GetFavoritesUseCase {
  final FavoritesRepository repository;

  // Ajout du constructeur pour initialiser la variable finale
  GetFavoritesUseCase({required this.repository});

  Future<List<Publication>> execute(String codeSejour, String token) async {
    final models = await repository.getFavorites(codeSejour, token);
    return models.map((model) => model.toEntity()).toList();
  }
}