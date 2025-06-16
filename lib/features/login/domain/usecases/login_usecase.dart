import '../repositories/login_repository.dart';

class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase({required this.repository});

  Future<String> execute(String username, String password) {
    return repository.login(username, password);
  }
}