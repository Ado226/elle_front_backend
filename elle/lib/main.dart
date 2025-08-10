import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'core/app_initialization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app data
  await AppInitialization.initialize();
  
  runApp(const EllesApp());
}

class EllesApp extends StatelessWidget {
  const EllesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elles - Assistant Santé Africaine',
      theme: AppTheme.themeData,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('fr', 'FR'),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
