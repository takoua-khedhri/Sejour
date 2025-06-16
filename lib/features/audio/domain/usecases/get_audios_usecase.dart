import '../entities/audio.dart';
import '../repositories/audio_repository.dart';

class GetAudiosUseCase {
  final AudioRepository repository;

  GetAudiosUseCase(this.repository);

  Future<List<Audio>> call(
    String codeSejour, 
    String type, 
    String date, 
    String token
  ) async {
    try {
      // Le repository retourne déjà des Audio (entités)
      return await repository.getAudios(
        codeSejour, 
        type, 
        date, 
        token
      );
    } catch (e) {
      print('Erreur dans GetAudiosUseCase: $e');
      rethrow;
    }
  }
}