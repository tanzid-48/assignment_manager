import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/assignment_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AssignmentProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AssignmentProvider>();

    return MaterialApp(
      title: 'Assignment Manager',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: p.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const _AuthWrapper(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF534AB7),
        brightness: brightness,
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
    );
  }
}

// ── Auth wrapper — shows login or home based on auth state ──
class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Logged in
        if (snapshot.hasData && snapshot.data != null) {
          return const _HomeWithLoader();
        }

        // Not logged in
        return const AuthScreen();
      },
    );
  }
}

// Loads data once after login, then shows HomeScreen
class _HomeWithLoader extends StatefulWidget {
  const _HomeWithLoader();

  @override
  State<_HomeWithLoader> createState() => _HomeWithLoaderState();
}

class _HomeWithLoaderState extends State<_HomeWithLoader> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final p = context.read<AssignmentProvider>();
    await p.load();
    p.listenToAssignments();
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      final scheme = Theme.of(context).colorScheme;
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: scheme.primary),
              const SizedBox(height: 16),
              Text('Loading your assignments...',
                  style: TextStyle(
                      color: scheme.onSurface.withOpacity(0.5),
                      fontSize: 14)),
            ],
          ),
        ),
      );
    }
    return const HomeScreen();
  }
}