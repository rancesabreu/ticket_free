import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticket_free/features/auth/presentation/service/auth_service.dart';

class SpbaseAuthService implements AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<bool> login(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response.user != null;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<void> logout() async {
    await _supabaseClient.auth.signOut();
  }
  
  @override
  Future<bool> isLoggedIn() async {
    return _supabaseClient.auth.currentUser != null;
  }

}
