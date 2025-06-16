import 'package:dio/dio.dart';
import 'package:parent_5sur5/features/home/data/models/publication_model.dart';
import 'package:flutter/foundation.dart';

class FavoritesRemoteDataSource {
  final Dio dio;

  FavoritesRemoteDataSource(this.dio);

  Future<List<PublicationModel>> getLikedPublications(
    String codeSejour, String token) async {
  final response = await dio.get(
    '/accomp/attachment/$codeSejour',
    queryParameters: {'type': 'image,video'}, 
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );

  return (response.data as List)
      .map((json) => PublicationModel.fromJson(json))
      .where((publication) => publication.likes >= 1) 
      .toList();
}

Future<void> toggleLike(String publicationId, bool isLiked, String token) async {
  await dio.post(
    '/accomp/attachment/like/$publicationId',  
    data: {'like': isLiked},
    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',  
      },
    ),
  );
}
}