import '../models/login_model.dart';
import '../datasources/login_remote_datasource.dart';
import '../../domain/repositories/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource dataSource;

  LoginRepositoryImpl(this.dataSource);

  @override
  Future<String> login(String username, String password) async {
    final loginModel = LoginModel(username: username, password: password);
    return await dataSource.login(loginModel);
  }
}
