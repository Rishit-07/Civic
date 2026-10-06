import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/services/app_preferences.dart';
import '../../features/splash_loading/loading_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/navigation/main_tab_scaffold.dart';
import '../../features/scenarios/situation_list_screen.dart';
import '../../features/scenarios/situation_card_screen.dart';
import '../../features/directory/pages/about_civic_screen.dart';
import '../../features/directory/pages/constitution_bns_screen.dart';
import '../../features/directory/pages/legal_clinics_screen.dart';
import '../../features/directory/pages/verified_advocates_screen.dart';
import '../../features/directory/pages/police_encounter_screen.dart';
import '../../features/directory/pages/fir_registration_screen.dart';
import '../../features/directory/pages/arrest_safeguards_screen.dart';
import '../../features/directory/pages/digital_rights_screen.dart';
import '../../features/directory/pages/offline_archive_screen.dart';
import '../../features/directory/pages/court_directories_screen.dart';
import '../../features/directory/pages/emergency_dispatch_screen.dart';
import '../../features/directory/pages/whitepaper_screen.dart';
import '../../features/directory/pages/privacy_policy_screen.dart';
import '../../features/directory/pages/citizen_rights_screen.dart';
import '../../features/directory/pages/crpc_bnss_compliance_screen.dart';
import '../../features/directory/pages/terms_of_use_screen.dart';
import '../../features/showcase/civic_scroll_gallery_screen.dart';
import '../../features/alerts/civic_alerts_screen.dart';
import '../../features/profile/citizen_verification_screen.dart';

/// Centralized Declarative URL Router supporting HTML5 Deep Linking & Clean Path Navigation
class AppRouter {
  static const String initial = '/';
  static const String home = '/home';
  static const String verify = '/verify';
  static const String prepare = '/prepare';
  static const String notes = '/notes';
  static const String ask = '/ask';
  static const String help = '/help';
  static const String alerts = '/alerts';
  static const String notifications = '/notifications';
  static const String situations = '/situations';
  static const String scenarios = '/scenarios';
  static const String onboarding = '/onboarding';
  static const String signIn = '/signin';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '/');
    final path = uri.path;

    // Direct Root / Splash
    if (path == '/' || path == '/splash') {
      if (kIsWeb) {
        // On Web, the HTML preloader in index.html already served as the initial splash
        // while the browser loaded Flutter bundle and assets. Route directly to avoid
        // a jarring duplicate splash screen.
        final isReturning = AppPreferences.isFirstLaunchComplete;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => isReturning
              ? const MainTabScaffold()
              : const OnboardingScreen(),
        );
      }
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

    // Directory & Protocol Routes
    if (path == '/about') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const AboutCivicScreen(),
      );
    }

    if (path == '/constitution-bns') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const ConstitutionBnsScreen(),
      );
    }

    if (path == '/legal-clinics') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const LegalClinicsScreen(),
      );
    }

    if (path == '/verified-advocates') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const VerifiedAdvocatesScreen(),
      );
    }

    if (path == '/police-encounter') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const PoliceEncounterScreen(),
      );
    }

    if (path == '/fir-registration') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const FirRegistrationScreen(),
      );
    }

    if (path == '/arrest-safeguards') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const ArrestSafeguardsScreen(),
      );
    }

    if (path == '/digital-rights') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const DigitalRightsScreen(),
      );
    }

    if (path == '/archive') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const OfflineArchiveScreen(),
      );
    }

    if (path == '/courts') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const CourtDirectoriesScreen(),
      );
    }

    if (path == '/sos' || path == '/helpline' || path == '/emergency') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const EmergencyDispatchScreen(),
      );
    }

    if (path == '/whitepaper') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const WhitepaperScreen(),
      );
    }

    if (path == '/alerts' || path == '/notifications') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const CivicAlertsScreen(),
      );
    }

    if (path == '/privacy') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const PrivacyPolicyScreen(),
      );
    }

    if (path == '/citizen-rights') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const CitizenRightsScreen(),
      );
    }

    if (path == '/bnss-crpc') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const CrpcBnssComplianceScreen(),
      );
    }

    if (path == '/terms') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const TermsOfUseScreen(),
      );
    }

    // Citizen Verification Deep Link: /verify or /#/verify
    if (path == '/verify' || path.startsWith('/verify') || uri.fragment.startsWith('/verify') || uri.fragment.startsWith('verify')) {
      final params = Map<String, String>.from(uri.queryParameters);
      if (uri.fragment.contains('?')) {
        final fragUri = Uri.parse('dummy://${uri.fragment}');
        params.addAll(fragUri.queryParameters);
      }
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => CitizenVerificationScreen.fromQueryParams(params),
      );
    }

    // Framer Motion Style Horizontal Scroll Gallery
    if (path == '/gallery' || path == '/showcase') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const CivicScrollGalleryScreen(),
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
