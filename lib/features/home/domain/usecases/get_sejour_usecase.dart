import '../repositories/home_repository.dart';
import '../entities/sejour.dart'; // 🔁 Utiliser l'entité ici

class GetSejourUseCase {
  final HomeRepository repository;

  GetSejourUseCase(this.repository);

  Future<Sejour> call(String codeSejour, String token) {
    return repository.getSejour(codeSejour, token);
  }
}
