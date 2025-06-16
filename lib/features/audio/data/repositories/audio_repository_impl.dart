import '../../domain/repositories/audio_repository.dart';
import '../datasources/audio_remote_datasource.dart';
import '../models/audio_model.dart';
import '../../domain/entities/audio.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioRemoteDataSource remoteDataSource;

  AudioRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Audio>> getAudios(
    String codeSejour, 
    String type, 
    String date, 
    String token
  ) async {
    final models = await remoteDataSource.getAudios(codeSejour, token);
    return models.map((model) => model.toEntity()).toList();
  }


}