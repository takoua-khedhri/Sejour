import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/publication_model.dart';
import '../models/sejour_model.dart';
import '../models/day_description_model.dart';

class HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSource(this.dio);

 

// Dans HomeRemoteDataSource
Future<SejourModel> getSejour(String codeSejour, String token) async {
  try {
    debugPrint('🔄 Fetching sejour $codeSejour...');
    
    final response = await dio.get(
      'https://media.5sur5sejour.com/api/sejour/$codeSejour',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        validateStatus: (status) => status == 200 || status == 404,
      ),
    );

    debugPrint('✅ Status Code: ${response.statusCode}');
    debugPrint('🔍 Headers: ${response.headers}');
    debugPrint('📦 Response data: ${response.data}');
    
    if (response.statusCode == 404) {
      throw Exception('Séjour non trouvé');
    }

    if (response.data == null) {
      throw Exception('Réponse vide du serveur');
    }

    return SejourModel.fromJson(response.data);
    
  } on DioException catch (e) {
    debugPrint('🔥 Erreur Dio: ${e.message}');
    debugPrint('📊 Status Code: ${e.response?.statusCode}');
    debugPrint('📊 Réponse erreur: ${e.response?.data}');
    throw Exception('Erreur réseau: ${e.message}');
  } catch (e) {
    debugPrint('❌ Erreur inattendue: $e');
    throw Exception('Erreur inattendue: $e');
  }
}


Future<List<PublicationModel>> getAttachement(
  String codeSejour,
  String type,
  String date,
  String token,
) async {
  try {
    debugPrint('Fetching publications for dateCreate: $date');
    
    final validType = _validateTypeParameter(type);
    
    final response = await dio.get(
      '/accomp/attachment/$codeSejour',
      queryParameters: {
        'dateCreate': date, 
        'type': validType,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer ${token.replaceAll(RegExp(r'\s'), '')}',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status == 200 || status == 404,
      ),
    );

    if (response.statusCode == 404) {
      debugPrint('No publications found for dateCreate $date');
      return [];
    }

    if (response.data == null || response.data.isEmpty) {
      return [];
    }

    return List<PublicationModel>.from(
      response.data.map((x) => PublicationModel.fromJson(x)),
    );
  } on DioException catch (e) {
    debugPrint('Error fetching publications: ${e.message}');
    if (e.response?.statusCode == 500) {
      throw Exception('Server error, please try again later');
    }
    throw Exception('Failed to load publications: ${e.message}');
  } catch (e) {
    debugPrint('Unexpected error: $e');
    throw Exception('An unexpected error occurred');
  }
}

String _validateTypeParameter(String type) {
  if (type == 'all') {
    return 'image,video'; 
  }
  
  // Liste des types valides
  const validTypes = ['image', 'video', 'image,video', 'audio'];
  
  if (!validTypes.contains(type)) {
    return 'image,video'; 
  }
  
  return type;
}

  Future<DayDescriptionModel> getDayDescription(
    String codeSejour,
    String date,
    String token,
  ) async {
    try {
      final response = await dio.get(
        '/accomp/jourdescription/$codeSejour',
        queryParameters: {'date': date},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status == 200 || status == 404,
        ),
      );

      if (response.statusCode == 404 || response.data == null) {
        return DayDescriptionModel.empty();
      }

      return DayDescriptionModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error fetching day description: ${e.message}');
      return DayDescriptionModel.empty();
    }
  }

  Future<void> toggleLike(String publicationId, bool isLiked, String token) async {
  try {
    final response = await dio.post(
      '/accomp/attachment/like/$publicationId',
      data: {'like': isLiked},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Échec de la mise à jour du like');
    }
  } on DioException catch (e) {
    debugPrint('Error toggling like: ${e.message}');
    throw Exception('Failed to toggle like: ${e.message}');
  }
}
}