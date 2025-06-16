import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:parent_5sur5/features/home/data/models/publication_model.dart';
import 'package:parent_5sur5/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:parent_5sur5/features/favorites/data/datasources/favorites_remote_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remote;

  FavoritesRepositoryImpl({
    required this.remote, 
  });

  @override
  Future<List<PublicationModel>> getFavorites(String codeSejour, String token) async {
    try {
      return await remote.getLikedPublications(codeSejour, token);
    } on DioException catch (e) {
      debugPrint('API Error: ${e.response?.statusCode}');
      throw Exception('Failed to load favorites: ${e.message}');
    }
  }

  @override
  Future<void> toggleLike(String publicationId, bool isLiked, String token) async {
    try {
      debugPrint('Tentative de like pour $publicationId');
      
      await remote.toggleLike(publicationId, isLiked, token);
      debugPrint('Like réussi');
      
    } catch (e) {
      debugPrint('Erreur lors du like: $e');
      throw Exception('Like failed: ${e.toString()}');
    }
  }
}