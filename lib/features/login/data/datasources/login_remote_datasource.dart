import 'package:dio/dio.dart';
import 'package:parent_5sur5/features/login/data/models/login_model.dart';
import 'package:parent_5sur5/core/error/exceptions.dart';

class LoginRemoteDataSource {
  final Dio dio;

  LoginRemoteDataSource({required this.dio});

  Future<String> login(LoginModel loginModel) async {
    try {

      final response = await dio.post(
        'https://media.5sur5sejour.com/api/login', // URL
        data: loginModel.toJson(), // 👈 reprendre l’utilisation normale
        options: Options(
          headers: {'Content-Type':'application/json'},
        ),
      );
      print('Réponse de l\'API: ${response.data}'); // Affiche la réponse dans la console

      //vérification que le token est retourné
      return response.data['token'];

    } catch (e) {
      print('Erreur login: $e');
      throw ServerException();
    }
  }
}
