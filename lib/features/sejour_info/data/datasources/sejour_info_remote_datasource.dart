import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:parent_5sur5/features/home/domain/entities/sejour.dart';
import '../../domain/exceptions/sejour_info_exceptions.dart';

class SejourInfoRemoteDataSource {
  final Dio dio;

  SejourInfoRemoteDataSource(this.dio);

Future<Sejour> getSejourInfo(String codeSejour, String token) async {
  try {
    debugPrint('Fetching sejour info for $codeSejour with token $token');
    final response = await dio.get(
      'https://media.5sur5sejour.com/api/sejour/$codeSejour',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response data: ${response.data}');

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      if (data.isEmpty) {
        throw SejourNotFoundException('Séjour vide ou non trouvé');
      }
      return Sejour.fromJson(data);
    } else {
      throw SejourNetworkException('Erreur HTTP ${response.statusCode}');
    }
  } on DioException catch (e) {
    debugPrint('DioError: ${e.message}');
    debugPrint('DioError response: ${e.response?.data}');
    if (e.response?.statusCode == 404) {
      throw SejourNotFoundException('Séjour non trouvé');
    }
    throw SejourNetworkException('Erreur réseau: ${e.message}');
  }
}
}
