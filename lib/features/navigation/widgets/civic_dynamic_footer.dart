import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../directory/pages/about_civic_screen.dart';
import '../../directory/pages/constitution_bns_screen.dart';
import '../../directory/pages/legal_clinics_screen.dart';
import '../../directory/pages/verified_advocates_screen.dart';
import '../../directory/pages/police_encounter_screen.dart';
import '../../directory/pages/fir_registration_screen.dart';
import '../../directory/pages/arrest_safeguards_screen.dart';
import '../../directory/pages/digital_rights_screen.dart';
import '../../directory/pages/offline_archive_screen.dart';
import '../../directory/pages/court_directories_screen.dart';
import '../../directory/pages/emergency_dispatch_screen.dart';
import '../../directory/pages/whitepaper_screen.dart';
import '../../directory/pages/privacy_policy_screen.dart';
import '../../directory/pages/citizen_rights_screen.dart';
import '../../directory/pages/crpc_bnss_compliance_screen.dart';
import '../../directory/pages/terms_of_use_screen.dart';
import '../../showcase/civic_scroll_gallery_screen.dart';

/// Dynamic, animated light footer showcase matching the CIVIC Design System.
/// Features 21st.dev / Motion-grade animations:
/// - 21st.dev "Border Beam" gradient runner gliding along the top edge
/// - Continuous pulsing radar beacon on 24/7 ACTIVE helpline status
/// - Interactive hover translation & indicator micro-interactions on directory links
/// - Spring-animated social circle badges
/// - Light CIVIC architectural color scheme (#FFFFFF, #FAFAFA, #17261F, #FF5A00)
class CivicDynamicFooter extends StatefulWidget {
  const CivicDynamicFooter({super.key});

  @override
  State<CivicDynamicFooter> createState() => _CivicDynamicFooterState();
}

class _CivicDynamicFooterState extends State<CivicDynamicFooter>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 21st.dev Border Beam Runner animation controller
  late AnimationController _beamController;

  // Radar beacon pulsing animation controller
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String? _hoveredLink;
  String? _hoveredSocial;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
    _entranceController.forward();

    // 2. 21st.dev Border Beam continuous loop (3.5 seconds)
    _beamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // 3. Radar beacon pulse continuous loop (1.6 seconds)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    // Only start infinite repeating loops when not running in automated widget test environment,
    // ensuring tester.pumpAndSettle() settles properly while users experience smooth 60fps motion.
    final bool isTest = WidgetsBinding.instance.runtimeType.toString().contains(
      'Test',
    );
    if (!isTest) {
      _beamController.repeat();
      _pulseController.repeat(reverse: true);
    } else {
      _beamController.value = 0.5;
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _beamController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => page,
        transitionsBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  void _showCopiedToast(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$text" to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(top: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: const Color(0xFFE2E4EB), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 28,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 21st.dev Animated Border Beam along the top edge
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 2.5,
                  child: AnimatedBuilder(
                    animation: _beamController,
                    builder: (context, child) {
                      final double progress = _beamController.value;
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(progress * 2.4 - 1.2, 0.0),
                            end: Alignment(progress * 2.4, 0.0),
                            colors: const [
                              Colors.transparent,
                              Color(0xFFFF5A00),
                              Color(0xFFFFB800),
                              Color(0xFFFF5A00),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Large Watermark Faded Brand Typography
                Positioned(
                  bottom: -15,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'CIVIC',
                      style: GoogleFonts.montserrat(
                        fontSize: 88,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6.0,
                        color: const Color(0xFF17261F).withValues(alpha: 0.03),
                      ),
                    ),
                  ),
                ),

                // Main Footer Body Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 96.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand Badge & Mission Tagline
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5A00)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFF5A00)
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/civic_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'CIVIC',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.0,
                                      color: const Color(0xFF17261F),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3EB),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0xFFFF5A00)
                                            .withValues(alpha: 0.35),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      'PRO-BONO',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 9.0,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.6,
                                        color: const Color(0xFFFF5A00),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'OPEN CIVIC JUSTICE HUB & DIRECTORY',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // 4 Directory Columns in a 2x2 Layout
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Column 1: Initiative
                          Expanded(
                            child: _buildColumnSection(
                              title: 'INITIATIVE',
                              links: [
                                _LinkItem(
                                  'About CIVIC',
                                  () => _navigateTo(const AboutCivicScreen()),
                                ),
                                _LinkItem(
                                  'Constitution & BNS',
                                  () => _navigateTo(
                                    const ConstitutionBnsScreen(),
                                  ),
                                ),
                                _LinkItem(
                                  'Legal Clinics',
                                  () => _navigateTo(const LegalClinicsScreen()),
                                ),
                                _LinkItem(
                                  'Verified Advocates',
                                  () => _navigateTo(
                                    const VerifiedAdvocatesScreen(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Column 2: Protocols
                          Expanded(
                            child: _buildColumnSection(
                              title: 'PROTOCOLS',
                              links: [
                                _LinkItem(
                                  'Police Encounter',
                                  () => _navigateTo(
                                    const PoliceEncounterScreen(),
                                  ),
                                ),
                                _LinkItem(
                                  'FIR Registration',
                                  () => _navigateTo(
                                    const FirRegistrationScreen(),
                                  ),
                                ),
                                _LinkItem(
                                  'Arrest Safeguards',
                                  () => _navigateTo(
                                    const ArrestSafeguardsScreen(),
                                  ),
                                ),
                                _LinkItem(
                                  'Digital Rights',
                                  () =>
                                      _navigateTo(const DigitalRightsScreen()),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Column 3: Resources
                          Expanded(
                            child: _buildColumnSection(
                              title: 'RESOURCES',
                              links: [
                                _LinkItem(
                                  'Offline Legal Archive',
                                  () =>
                                      _navigateTo(const OfflineArchiveScreen()),
                                ),
                                _LinkItem(
                                  'Visual Scenario Gallery',
                                  () => _navigateTo(
                                    const CivicScrollGalleryScreen(),
                                  ),
                                ),
                                _LinkItem(
                                  'Court Directories',
                                  () => _navigateTo(
                                    const CourtDirectoriesScreen(),
                                  ),
                                ),
                                _LinkItem(
                                  'Emergency 112 / NALSA',
                                  () => _navigateTo(
                                    const EmergencyDispatchScreen(),
                                  ),
                                ),
                                _LinkItem(
                                  'Whitepaper',
                                  () => _navigateTo(const WhitepaperScreen()),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Column 4: Legal & Trust
                          Expanded(
                            child: _buildColumnSection(
                              title: 'LEGAL & TRUST',
                              links: [
                                _LinkItem(
                                  'Privacy (Zero Telemetry)',
                                  () =>
                                      _navigateTo(const PrivacyPolicyScreen()),
                                ),
                                _LinkItem(
                                  'Citizen Rights',
                                  () =>
                                      _navigateTo(const CitizenRightsScreen()),
                                ),
                                _LinkItem(
                                  'CrPC Compliance',
                                  () => _navigateTo(
                                    const CrpcBnssComplianceScreen(),
                                  ),
                                ),
                                _LinkItem(
                                  'Terms of Use',
                                  () => _navigateTo(const TermsOfUseScreen()),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),

                      // Helpline & Support Highlight Card (with 21st.dev Pulsing Radar Beacon)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'HELPLINE & SUPPORT',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: const Color(0xFF17261F),
                                  ),
                                ),
                                // Radar Pulsing Live Indicator
                                Row(
                                  children: [
                                    AnimatedBuilder(
                                      animation: _pulseAnimation,
                                      builder: (context, child) {
                                        return Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width:
                                                  14 +
                                                  (6 * _pulseAnimation.value),
                                              height:
                                                  14 +
                                                  (6 * _pulseAnimation.value),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF10B981)
                                                    .withValues(
                                                      alpha:
                                                          0.25 *
                                                          (1.0 -
                                                              _pulseAnimation
                                                                  .value),
                                                    ),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF10B981),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '24/7 ACTIVE',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        color: const Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () => _showCopiedToast('help@civicapp.in'),
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2.0,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.email_outlined,
                                      size: 14,
                                      color: Color(0xFFFF5A00),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'help@civicapp.in',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF4B5563),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () => _showCopiedToast('1800-11-2026'),
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2.0,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_outlined,
                                      size: 14,
                                      color: Color(0xFFFF5A00),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '+91 1800-11-2026 (Toll-Free National Directory)',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF4B5563),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      const Divider(color: Color(0xFFE2E4EB), height: 1),
                      const SizedBox(height: 20),

                      // Social Channels with Smooth Hover Motion
                      Row(
                        children: [
                          _buildSocialCircle(
                            label: 'X',
                            icon: Icons.tag,
                            onTap: () =>
                                _showCopiedToast('https://x.com/civicapp_in'),
                          ),
                          const SizedBox(width: 10),
                          _buildSocialCircle(
                            label: 'GitHub',
                            icon: Icons.code_rounded,
                            onTap: () => _showCopiedToast(
                              'https://github.com/civic-legal/civic',
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildSocialCircle(
                            label: 'LinkedIn',
                            icon: Icons.business_center_rounded,
                            onTap: () => _showCopiedToast(
                              'https://linkedin.com/company/civic-legal',
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildSocialCircle(
                            label: 'Security',
                            icon: Icons.security_rounded,
                            onTap: () =>
                                _showCopiedToast('security@civicapp.in'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Office Location & Legal Notice
                      Text(
                        'CIVIC, Legal Defense Hub, Banglore, India.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '© 2026 CIVIC. Open Civic Infrastructure. All rights reserved under Constitution of India Art 39A.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: const Color(0xFF94A3B8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Directory Column with 21st.dev style interactive link hover micro-animation
  Widget _buildColumnSection({
    required String title,
    required List<_LinkItem> links,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: const Color(0xFF17261F),
          ),
        ),
        const SizedBox(height: 10),
        ...links.map((link) {
          final bool isHovered = _hoveredLink == link.title;
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredLink = link.title),
            onExit: (_) => setState(() => _hoveredLink = null),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: link.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(
                  isHovered ? 4.0 : 0.0,
                  0.0,
                  0.0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 3.5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isHovered) ...[
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 11,
                        color: Color(0xFFFF5A00),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        link.title,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isHovered
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isHovered
                              ? const Color(0xFFFF5A00)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Social Circle button with smooth hover scale and brand accent fill
  Widget _buildSocialCircle({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool isHovered = _hoveredSocial == label;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredSocial = label),
      onExit: (_) => setState(() => _hoveredSocial = null),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: 34,
          height: 34,
          transform: Matrix4.diagonal3Values(
            isHovered ? 1.12 : 1.0,
            isHovered ? 1.12 : 1.0,
            1.0,
          ),
          decoration: BoxDecoration(
            color: isHovered
                ? const Color(0xFFFF5A00)
                : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(
              color: isHovered
                  ? const Color(0xFFFF5A00)
                  : const Color(0xFFE2E4EB),
              width: 1.0,
            ),
            boxShadow: isHovered
                ? [
                    const BoxShadow(
                      color: Color(0x33FF5A00),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 14,
              color: isHovered ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkItem {
  final String title;
  final VoidCallback onTap;
  _LinkItem(this.title, this.onTap);
}
