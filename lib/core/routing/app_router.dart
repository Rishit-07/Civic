import 'package:flutter/material.dart';
import '../../features/splash_loading/loading_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/navigation/main_tab_scaffold.dart';
import '../../features/scenarios/situation_list_screen.dart';
import '../../features/scenarios/situation_card_screen.dart';

/// Centralized Declarative URL Router supporting HTML5 Deep Linking & Clean Path Navigation
class AppRouter {
  static const String initial = '/';
  static const String home = '/home';
  static const String prepare = '/prepare';
  static const String notes = '/notes';
  static const String ask = '/ask';
  static const String help = '/help';
  static const String situations = '/situations';
  static const String scenarios = '/scenarios';
  static const String onboarding = '/onboarding';
  static const String signIn = '/signin';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '/');
    final path = uri.path;

    // Direct Root / Splash
    if (path == '/' || path == '/splash') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const LoadingScreen(),
      );
    }

    // Onboarding
    if (path == '/onboarding') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const OnboardingScreen(),
      );
    }

    // Sign In
    if (path == '/signin' || path == '/login') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const SignInScreen(),
      );
    }

    // Main App Tabs
    if (path == '/home') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const MainTabScaffold(initialIndex: 0),
      );
    }

    if (path == '/prepare') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const MainTabScaffold(initialIndex: 1),
      );
    }

    if (path == '/notes') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const MainTabScaffold(initialIndex: 2),
      );
    }

    if (path == '/ask') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const MainTabScaffold(initialIndex: 3),
      );
    }

    if (path == '/help') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const MainTabScaffold(initialIndex: 4),
      );
    }

    // Situation List / Scenarios
    if (path == '/situations' || path == '/scenarios') {
      final category = uri.queryParameters['category'];
      final search = uri.queryParameters['q'];
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => SituationListScreen(
          initialCategoryId: category,
          initialSearchQuery: search,
        ),
      );
    }

    // Specific Scenario Card Deep Link: /scenario/:id or /card/:id
    if (path.startsWith('/scenario/') || path.startsWith('/card/')) {
      final cardId = path.split('/').last.trim();
      if (cardId.isNotEmpty) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SituationCardScreen(cardId: cardId),
        );
      }
    }

    // Default Fallback
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => const MainTabScaffold(initialIndex: 0),
    );
  }
}
