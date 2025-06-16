import '../entities/sejour.dart';
import '../entities/day_description.dart';
import '../entities/publication.dart';

abstract class HomeRepository {
  /// Récupère les informations d'un séjour
  Future<Sejour> getSejour(String codeSejour, String token);

  /// Récupère la description du jour pour un séjour
  Future<DayDescription> getDayDescription(
    String codeSejour, 
    String date, 
    String token
  );

  /// Récupère les publications (images/vidéos) pour une date donnée
  Future<List<Publication>> getPublications(
    String codeSejour,
    String type, // 'image', 'video' ou 'image,video'
    String date,
    String token
  );

  /// Met à jour l'état "like" d'une publication
  Future<void> toggleLike(
    String publicationId,
    bool isLiked,
    String token
  );
}