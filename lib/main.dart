import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticket_free/config/router/app_router.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://lquauwdimhlhtqzkjisn.supabase.co/',
    anonKey: 'sb_publishable_UTc8K-1M4-PW-D5C9q2yZA_bTL4Ypgn',
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFD7B396),
          onPrimary: Colors.white,
          secondary: Color(0xFFB89B79),
          onSecondary: Colors.black87,
          background: Color(0xFFF5EFE6),
          onBackground: Colors.black87,
          surface: Color(0xFFEEE1D3),
          onSurface: Colors.black87,
          error: Color(0xFFB00020),
          onError: Colors.white,
          primaryContainer: Color(0xFFF1E1CD),
          secondaryContainer: Color(0xFFDFCAA9),
          tertiary: Color(0xFF102147),
          onTertiary: Colors.white,
          primaryFixed: Color.fromARGB(255, 214, 185, 140),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5EFE6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF102147),
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFFFFF6ED),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF102147),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/PromoImage.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: const Text(
                      'Ticket Free',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'La mejor forma de gestionar tus eventos',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 545),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          minimumSize: const Size(140, 60),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        onPressed: () => context.go('/login'),
                        child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
