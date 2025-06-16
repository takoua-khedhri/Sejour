import '../datasources/home_remote_datasource.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/entities/sejour.dart';
import '../../domain/entities/day_description.dart';
import '../../domain/entities/publication.dart';
import '../models/sejour_model.dart';
import '../models/day_description_model.dart';
import '../models/publication_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Sejour> getSejour(String codeSejour, String token) async {
    final model = await remoteDataSource.getSejour(codeSejour, token);
    return model.toEntity();
  }

  @override
  Future<DayDescription> getDayDescription(
    String codeSejour, 
    String date, 
    String token
  ) async {
    final model = await remoteDataSource.getDayDescription(
      codeSejour, 
      date, 
      token
    );
    return model.toEntity();
  }

  @override
  Future<List<Publication>> getPublications(
    String codeSejour,
    String type,
    String date,
    String token
  ) async {
    final models = await remoteDataSource.getAttachement(
      codeSejour,
      type,
      date,
      token
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> toggleLike(
    String publicationId, 
    bool isLiked, 
    String token
  ) async {
    await remoteDataSource.toggleLike(publicationId, isLiked, token);
  }
}