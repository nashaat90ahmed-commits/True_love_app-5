import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:true_love_app/src/config/routes/app_routes.dart';
import 'package:true_love_app/src/config/themes/app_theme.dart';
import 'package:true_love_app/src/config/localization/app_localizations.dart';
import 'package:true_love_app/src/core/providers/providers.dart';
import 'package:true_love_app/src/core/services/firebase_service.dart';
import 'package:true_love_app/src/core/services/ads_service.dart';
import 'package:true_love_app/src/core/services/notification_service.dart';

Future<void> main() async {
  // Preserve splash screen until initialization is complete
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Shared Preferences
  final prefs = await SharedPreferences.getInstance();
  
  // Initialize Mobile Ads
  await MobileAds.instance.initialize();
  
  // Request notification permissions
  await FirebaseMessaging.instance.requestPermission();
  
  // Initialize services
  await FirebaseService.initialize();
  await NotificationService.initialize();
  await AdsService.initialize();
  
  // Remove splash screen
  FlutterNativeSplash.remove();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      title: 'الحب الحقيقي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
        Locale('fr'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      navigatorKey: AppRoutes.navigatorKey,
    );
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.handleBackgroundMessage(message);
}