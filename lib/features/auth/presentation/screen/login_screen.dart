import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ticket_free/features/auth/presentation/service/spbase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  final SpbaseAuthService _authService = SpbaseAuthService();

  // 1. Variable para controlar el estado de carga
  bool _isLoading = false;

  void _submit() async {
    // Evitar multiples envíos mientras se procesa la solicitud
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true; // Iniciar carga
      });

      try {
        final success = await _authService.login(_email, _password);

        if (!mounted)
          return; // Verificar si el widget sigue montado antes de actualizar el estado

        if (success) {
          context.go('/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Credenciales incorrectas'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (!mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error de conexión. Intenta nuevamente.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Finalizar carga
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SingleChildScrollView( // Añadido para evitar overflow con el teclado
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: _isLoading ? null : () => context.go('/'),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              const SizedBox(height: 10),
              const Text(
                'Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      enabled: !_isLoading, // Deshabilitar campo durante carga
                      decoration: const InputDecoration(labelText: 'Correo'),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) => _email = value!,
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Ingresa tu correo' : null,
                    ),
                    TextFormField(
                      enabled: !_isLoading, // Deshabilitar campo durante carga
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                      ),
                      obscureText: true,
                      onSaved: (value) => _password = value!,
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Ingresa tu contraseña' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                   :  const Text('Iniciar Sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
      )
    );
  }
}
