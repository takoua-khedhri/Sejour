import 'package:parent_5sur5/features/home/domain/entities/sejour.dart';

abstract class SejourInfoRepository {
  Future<Sejour> getSejourInfo(String codeSejour, String token);
}