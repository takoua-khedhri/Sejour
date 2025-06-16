import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/logout_repository.dart';

class LogoutRepositoryImpl implements LogoutRepository {
  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    final tokenBefore = prefs.getString('token');
    final codeBefore = prefs.getString('codeSejour');
    print('Token before logout: $tokenBefore');
    print('CodeSejour before logout: $codeBefore');

    await prefs.remove('token');
    await prefs.remove('codeSejour');

    final tokenAfter = prefs.getString('token');
    final codeAfter = prefs.getString('codeSejour');
    print('Token after logout: $tokenAfter');
    print('CodeSejour after logout: $codeAfter');

    if (tokenAfter != null || codeAfter != null) {
      throw Exception('Données encore présentes après logout');
    }
  }
}
