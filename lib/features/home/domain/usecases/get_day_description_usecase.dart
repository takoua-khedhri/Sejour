import '../repositories/home_repository.dart';
import '../entities/day_description.dart'; // 🔁 Utiliser l'entité ici

class GetDayDescriptionUseCase {
  final HomeRepository repository;

  GetDayDescriptionUseCase(this.repository);

  Future<DayDescription> call(String codeSejour, String date, String token) {
    return repository.getDayDescription(codeSejour, date, token);
  }

  
}


