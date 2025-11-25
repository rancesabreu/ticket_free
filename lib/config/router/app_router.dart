import 'package:go_router/go_router.dart';
import 'package:ticket_free/features/home/home_screen.dart';
import 'package:ticket_free/main.dart';
import 'package:ticket_free/features/auth/presentation/screen/login_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/',
      builder:
          (context, state) => const MainScreen()
    ),
    GoRoute(
      path: '/home',
      builder:
          (context, state) => const HomeScreen(),
    ),
  ],
);
