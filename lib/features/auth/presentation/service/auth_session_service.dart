import 'package:ticket_free/features/auth/presentation/service/auth_service.dart';

class AuthSessionService implements AuthService{

  @override
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return email == 'josurances@gmail.com' && password == '0500';
  }
  
  @override
  Future<bool> isLoggedIn() {
    // TODO: implement isLoggedIn
    throw UnimplementedError();
  }
  
  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }}