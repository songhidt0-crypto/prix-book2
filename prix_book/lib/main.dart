import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: PrixBookApp(),
    ),
  );
}

class PrixBookApp extends StatelessWidget {
  const PrixBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'دفتر الأسعار',
      debugShowCheckedModeBanner: false,

      // RTL Arabic support (Spec Section 4.1)
      locale: const Locale('ar', 'DZ'),
      supportedLocales: const [
        Locale('ar', 'DZ'),
        Locale('fr', 'DZ'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Theme
      theme: AppTheme.lightTheme,

      // Router
      routerConfig: appRouter,

      // RTL direction
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}
