import '../entities/publication.dart';
import '../repositories/home_repository.dart';
import '../../data/models/publication_model.dart'; // important !


class GetPublicationsUseCase {
  final HomeRepository repository;

  GetPublicationsUseCase(this.repository);

  Future<List<Publication>> call(
    String codeSejour, 
    String type, 
    String date, 
    String token
  ) async {
    try {
      return await repository.getPublications(codeSejour, type, date, token);
    } catch (e) {
      print('Erreur dans GetPublicationsUseCase: $e');
      rethrow;
    }
  }
}