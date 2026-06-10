import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/dependency_injections.dart';
import 'core/firebase_options.dart';
import 'presentation/login_screen.dart';
import 'presentation/home_screen.dart';
import 'presentation/view_models/home_view_model.dart';
import 'presentation/view_models/login_view_model.dart';
import 'presentation/view_models/registration_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase conectado: ${Firebase.app().options.projectId}');
  } catch (e) {
    debugPrint('Erro ao conectar ao Firebase: $e');
  }

  setupDependencyInjections();
  runApp(const AgroSatApp());
}

class AgroSatApp extends StatelessWidget {
  const AgroSatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<LoginViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<RegistrationViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<HomeViewModel>()),
      ],
      child: MaterialApp(
        title: 'AgroSat Sentinel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR')],
        locale: const Locale('pt', 'BR'),
        home: const AuthGate(),
      ),
    );
  }
}

/// Verifica o estado de autenticação do Firebase ao iniciar o app.
/// Se o usuário já estiver logado (inclusive após refresh no web), vai direto
/// para HomeScreen. Caso contrário, exibe LoginScreen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}