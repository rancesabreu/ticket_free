import 'package:go_router/go_router.dart';
import 'package:ticket_free/features/home/add_ticket_screen.dart';
import 'package:ticket_free/features/home/home_screen.dart';
import 'package:ticket_free/main.dart';
import 'package:ticket_free/features/auth/presentation/screen/login_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()), // Pantalla de inicio de sesión
    GoRoute(
      path: '/',
      builder:
          (context, state) => const MainScreen() // Pantalla principal de bienvenida
    ),
    GoRoute(
      path: '/home',
      builder:
          (context, state) => const HomeScreen(), // Pantalla principal con lista de tickets
    ),
    GoRoute(
      path: '/add-ticket',
      builder: (context, state) => const AddTicketScreen(), // Pantalla para agregar nuevos tickets
    ),
  ],
);
