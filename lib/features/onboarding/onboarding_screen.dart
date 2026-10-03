import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_radii.dart';
import '../../data/services/app_preferences.dart';
import '../auth/sign_in_screen.dart';
import '../scenarios/situation_list_screen.dart';
import 'widgets/onboarding_illustrations.dart';

/// Pixel-perfect Onboarding / Landing Screen matching CIVIC design standards:
/// - 3 swipeable slides (KNOW, PREPARE, ACT)
/// - Top bar language toggle chip (English / हिन्दी)
/// - Last slide "GET STARTED ->" button with legal disclaimer
/// - Direct "In trouble right now? Get help" link on EVERY slide bypassing sign-in
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _currentLanguage = AppPreferences.selectedLanguage;
  }

  void _toggleLanguage(String lang) {
    setState(() {
      _currentLanguage = lang;
    });
    AppPreferences.setSelectedLanguage(lang);
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const SignInScreen(),
        transitionsBuilder: (context, anim1, anim2, child) {
          return FadeTransition(opacity: anim1, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _navigateToEmergency() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SituationListScreen(),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToSignIn();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isHindi => _currentLanguage == 'hi';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isCompact = mediaQuery.size.height < 740;
    final isWide = mediaQuery.size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: 3,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Geometric Background Accents
                _buildBackgroundShapes(index, isWide),

                // 2. Main Slide Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header: Logo Capsule Pill, Language Switcher & SKIP button
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 48.0 : 20.0,
                        vertical: isWide ? 24.0 : 16.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // White Capsule Badge with official CIVIC shield logo
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppRadii.pillBorder,
                              border: Border.all(color: const Color(0xFFE2E4EB), width: 1),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/civic_logo.png',
                                  width: 22,
                                  height: 22,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'CIVIC',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                    color: const Color(0xFF17261F),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Language Chip Toggle (English / हिन्दी)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppRadii.pillBorder,
                              border: Border.all(color: const Color(0xFFE2E4EB), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildLanguageButton('EN', 'en', !_isHindi),
                                _buildLanguageButton('हिन्दी', 'hi', _isHindi),
                              ],
                            ),
                          ),

                          // SKIP link
                          TextButton(
                            onPressed: _navigateToSignIn,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              _isHindi ? 'छोड़ें' : 'SKIP',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.8,
                                color: index == 1
                                    ? const Color(0xFFFF5A00)
                                    : const Color(0xFF8A8A8A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center & Bottom Content Area with generous reading column
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Center Illustration Area
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                    child: OnboardingIllustration(
                                      slideIndex: index,
                                      height: isCompact ? 220 : (isWide ? 340 : 280),
                                    ),
                                  ),
                                ),
                              ),

                              // Bottom Content & Actions
                              _buildBottomSection(index, isCompact, isWide),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String label, String code, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF17261F) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  /// Exact background shapes per slide matching the design
  Widget _buildBackgroundShapes(int index, bool isWide) {
    if (index == 0) {
      // Slide 1 (KNOW)
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: isWide ? -150 : -125,
            left: isWide ? -100 : -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE8E9F0), width: 28),
              ),
            ),
          ),
          Positioned(
            bottom: isWide ? -120 : -95,
            left: isWide ? -70 : -50,
            child: Container(
              width: 255,
              height: 255,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5A00),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0F5).withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );
    } else if (index == 1) {
      // Slide 2 (PREPARE)
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 340,
              height: 340,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5A00),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -160,
            left: -160,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF8B4A).withValues(alpha: 0.35),
                  width: 32,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Slide 3 (ACT)
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -140,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF0F5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 380,
                height: 200,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5A00),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(190)),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildEmergencyLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0),
      child: Center(
        child: TextButton.icon(
          onPressed: _navigateToEmergency,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFF5A00),
            size: 16,
          ),
          label: Text(
            _isHindi
                ? 'क्या आप अभी संकट में हैं? तुरंत सहायता पाएं'
                : 'In trouble right now? Get help',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFF5A00),
              decoration: TextDecoration.underline,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(int index, bool isCompact, bool isWide) {
    if (index == 0) {
      // SLIDE 1 (KNOW)
      return Padding(
        padding: EdgeInsets.fromLTRB(28.0, 0.0, 28.0, isWide ? 32.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isHindi ? 'जानिए' : 'KNOW',
              style: GoogleFonts.montserrat(
                fontSize: isWide ? 46 : 42,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF17261F),
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isHindi
                  ? 'दैनिक जीवन में अपने अधिकारों\nको पहचानें'
                  : 'KNOW YOUR RIGHTS IN\nEVERYDAY LIFE',
              style: GoogleFonts.montserrat(
                fontSize: isWide ? 13 : 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B7280),
                letterSpacing: 1.6,
                height: 1.5,
              ),
            ),
            SizedBox(height: isWide ? 28 : 22),

            // Bottom Navigation Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pagination Dots
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                _buildCircularArrowButton(),
              ],
            ),

            // Emergency Bypass Link on Slide 1
            _buildEmergencyLink(),
          ],
        ),
      );
    } else if (index == 1) {
      // SLIDE 2 (PREPARE)
      return Padding(
        padding: EdgeInsets.fromLTRB(28.0, 0.0, 28.0, isWide ? 32.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isHindi ? 'तैयारी' : 'PREPARE',
              style: GoogleFonts.montserrat(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF17261F),
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isHindi
                  ? 'संकट से पहले शांत रहकर\nपूरी तैयारी रखें'
                  : 'LEARN CALMLY BEFORE IT\nMATTERS',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8A8A8A),
                letterSpacing: 1.6,
                height: 1.5,
              ),
            ),
            SizedBox(height: isWide ? 28 : 22),

            // Bottom Navigation Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 3 Pagination Dots: . — . (middle active)
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1D3D8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 28,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5A00),
                        borderRadius: BorderRadius.circular(4.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1D3D8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                _buildCircularArrowButton(),
              ],
            ),

            // Emergency Bypass Link on Slide 2
            _buildEmergencyLink(),
          ],
        ),
      );
    } else {
      // SLIDE 3 (ACT)
      return Padding(
        padding: EdgeInsets.fromLTRB(28.0, 0.0, 28.0, isWide ? 28.0 : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _isHindi ? 'कदम उठाएं' : 'ACT',
              style: GoogleFonts.montserrat(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF17261F),
                letterSpacing: -0.5,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _isHindi
                  ? 'ज़रूरत पड़ने पर चरण-दर-चरण कानूनी मदद'
                  : 'STEP-BY-STEP HELP WHEN YOU NEED IT',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8A8A8A),
                letterSpacing: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            // Centered 3 Pagination Dots: . . — (3rd active)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E4EB),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E4EB),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 28,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5A00),
                    borderRadius: BorderRadius.circular(4.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Full-width Action Button: GET STARTED ->
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17261F),
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: const Color(0x33000000),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.pillBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isHindi ? 'शुरू करें' : 'GET STARTED',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Disclaimer line directly under GET STARTED
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _isHindi
                    ? 'सिविक कानूनी जानकारी प्रदान करता है, वकालत नहीं। आपातकाल में 112 पर कॉल करें।'
                    : 'CIVIC provides legal information, not attorney representation. In emergencies, call 112.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                  height: 1.35,
                ),
              ),
            ),

            // Emergency Bypass Link on Slide 3
            _buildEmergencyLink(),
          ],
        ),
      );
    }
  }

  Widget _buildCircularArrowButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFF17261F),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _nextPage,
          child: const Center(
            child: Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
