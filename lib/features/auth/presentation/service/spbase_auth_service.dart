import 'dart:convert';
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

 /// Retorna un Record con el nombre y la sección del usuario.
  Future<({String name, String section, String vendorUserId})?> getCurrentUserName() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return null;

    final metadata = user.userMetadata;
    // Obtenemos el campo donde guardamos el JSON
    final displayNameString = metadata?['display_name']?.toString();

    if (displayNameString != null && displayNameString.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(displayNameString);
        
        // Extraemos los valores del JSON
        final String name = data['name']?.toString() ?? user.email ?? user.id;
        final String section = data['section']?.toString() ?? '';
        // Si no viene el vendor_user_id, se asigna una cadena vacía para evitar errores de nullabilidad
        final String vendorUserId = data['vendorUserId']?.toString() ?? '';

        return (name: name, section: section, vendorUserId: vendorUserId);
      } catch (e) {
        // Fallback en caso de que sea solo texto plano
        return (name: 'No Encontrado', section: '', vendorUserId: '');
      }
    }

    // Fallback si no hay metadata
    return (name: 'No Encontrado', section: '', vendorUserId: '');
  }
}
