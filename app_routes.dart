import 'package:flutter/material.dart';
import 'package:true_love_app/src/features/auth/presentation/pages/splash_page.dart';
import 'package:true_love_app/src/features/auth/presentation/pages/age_gate_page.dart';
import 'package:true_love_app/src/features/auth/presentation/pages/login_page.dart';
import 'package:true_love_app/src/features/auth/presentation/pages/register_page.dart';
import 'package:true_love_app/src/features/home/presentation/pages/home_page.dart';
import 'package:true_love_app/src/features/chat/presentation/pages/chat_page.dart';
import 'package:true_love_app/src/features/community/presentation/pages/community_page.dart';
import 'package:true_love_app/src/features/profile/presentation/pages/profile_page.dart';
import 'package:true_love_app/src/features/home/presentation/pages/match_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String ageGate = '/age-gate';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String community = '/community';
  static const String profile = '/profile';
  static const String match = '/match';
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      
      case ageGate:
        return MaterialPageRoute(builder: (_) => const AgeGatePage());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      case chat:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ChatPage(
              matchId: args['matchId'],
              userId: args['userId'],
              userName: args['userName'],
              userImage: args['userImage'],
            ),
          );
        }
        return _errorRoute();
      
      case community:
        return MaterialPageRoute(builder: (_) => const CommunityPage());
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      
      case match:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => MatchPage(
              matchId: args['matchId'],
              userData: args['userData'],
            ),
          );
        }
        return _errorRoute();
      
      default:
        return _errorRoute();
    }
  }
  
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(child: Text('الصفحة غير موجودة')),
      ),
    );
  }
  
  static void navigateTo(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }
  
  static void navigateAndReplace(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushReplacementNamed(routeName, arguments: arguments);
  }
  
  static void navigateAndRemoveUntil(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  static void goBack() {
    navigatorKey.currentState?.pop();
  }
}