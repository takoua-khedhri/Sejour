import '../../domain/repositories/sejour_info_repository.dart';
import '../datasources/sejour_info_remote_datasource.dart';
import 'package:parent_5sur5/features/home/domain/entities/sejour.dart';
import '../../domain/exceptions/sejour_info_exceptions.dart';

class SejourInfoRepositoryImpl implements SejourInfoRepository {
  final SejourInfoRemoteDataSource remoteDataSource;

  SejourInfoRepositoryImpl(this.remoteDataSource);

  @override
  Future<Sejour> getSejourInfo(String codeSejour, String token) async {
    return remoteDataSource.getSejourInfo(codeSejour, token);
  }
}