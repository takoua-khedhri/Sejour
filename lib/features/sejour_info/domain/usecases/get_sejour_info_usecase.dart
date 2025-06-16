import '../repositories/sejour_info_repository.dart';
import 'package:parent_5sur5/features/home/domain/entities/sejour.dart';

class GetSejourInfoUseCase {
  final SejourInfoRepository repository;

  GetSejourInfoUseCase({required this.repository});

  Future<Sejour> execute({required String codeSejour, required String token}) {
    return repository.getSejourInfo(codeSejour, token);
  }
}