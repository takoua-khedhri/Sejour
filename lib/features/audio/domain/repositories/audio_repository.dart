import '../entities/audio.dart';

abstract class AudioRepository {
  Future<List<Audio>> getAudios(
    String codeSejour, 
    String type, 
    String date, 
    String token
  );
  
}