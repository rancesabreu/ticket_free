abstract class AuthService {
  Future<bool> login(String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
}
