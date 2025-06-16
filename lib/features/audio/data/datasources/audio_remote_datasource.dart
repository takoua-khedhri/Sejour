import 'package:dio/dio.dart';
import '../models/audio_model.dart';

class AudioRemoteDataSource {
  final Dio dio;
  static const String _baseUrl = 'https://media.5sur5sejour.com/api';

  AudioRemoteDataSource({required this.dio}) {
    dio.options.baseUrl = _baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  Future<List<AudioModel>> getAudios(String codeSejour, String token) async {
    try {
      final response = await dio.get(
        '/accomp/attachment/$codeSejour',
        queryParameters: {'type': 'audio'},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'audio/mpeg',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      switch (response.statusCode) {
        case 200:
          if (response.data is! List) {
            throw Exception('Format de réponse inattendu');
          }
          return (response.data as List)
              .map((json) => AudioModel.fromJson(json))
              .toList();
        case 401:
          throw Exception('Authentification requise - Token invalide ou expiré');
        case 403:
          throw Exception('Accès refusé - Permissions insuffisantes');
        case 404:
          throw Exception('Aucun audio trouvé pour ce séjour');
        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Erreur serveur: ${e.response?.statusCode}');
      } else {
        throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }
}