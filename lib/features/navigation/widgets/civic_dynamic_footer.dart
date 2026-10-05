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

/// Dynamic, animated dark footer showcase block matching the CIVIC Design System.
/// Features smooth scroll-driven entrance animation, 4 structured columns,
/// direct helpline access, social channels, and large ambient watermark typography.
class CivicDynamicFooter extends StatefulWidget {
  const CivicDynamicFooter({super.key});

  @override
  State<CivicDynamicFooter> createState() => _CivicDynamicFooterState();
}

class _CivicDynamicFooterState extends State<CivicDynamicFooter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    // Auto-trigger entrance animation
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => page,
        transitionsBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween<Offset>(
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
          margin: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
            color: Color(0xFF0E1116), // Dark slate-950
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(color: Color(0xFF1E293B), width: 1.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 30,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Large Watermark Faded Background Brand Accent
              Positioned(
                bottom: -15,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'CIVIC',
                    style: GoogleFonts.montserrat(
                      fontSize: 84,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6.0,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),
              ),

              // Main Footer Body Content
              Padding(
                padding: const EdgeInsets.fromLTRB(22.0, 28.0, 22.0, 90.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Badge & Mission Tagline
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFFB800).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/civic_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'CIVIC',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB800),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'PRO-BONO',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF0E1116),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'OPEN CIVIC JUSTICE HUB & DIRECTORY',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 4 Directory Columns in a 2x2 Grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Column 1: Initiative
                        Expanded(
                          child: _buildColumnSection(
                            title: 'Initiative',
                            links: [
                              _LinkItem('About CIVIC',
                                  () => _navigateTo(const AboutCivicScreen())),
                              _LinkItem('Constitution & BNS',
                                  () => _navigateTo(const ConstitutionBnsScreen())),
                              _LinkItem('Legal Clinics',
                                  () => _navigateTo(const LegalClinicsScreen())),
                              _LinkItem('Verified Advocates',
                                  () => _navigateTo(const VerifiedAdvocatesScreen())),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Column 2: Protocols
                        Expanded(
                          child: _buildColumnSection(
                            title: 'Protocols',
                            links: [
                              _LinkItem('Police Encounter',
                                  () => _navigateTo(const PoliceEncounterScreen())),
                              _LinkItem('FIR Registration',
                                  () => _navigateTo(const FirRegistrationScreen())),
                              _LinkItem('Arrest Safeguards',
                                  () => _navigateTo(const ArrestSafeguardsScreen())),
                              _LinkItem('Digital Rights',
                                  () => _navigateTo(const DigitalRightsScreen())),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Column 3: Resources
                        Expanded(
                          child: _buildColumnSection(
                            title: 'Resources',
                            links: [
                              _LinkItem('Offline Legal Archive',
                                  () => _navigateTo(const OfflineArchiveScreen())),
                              _LinkItem('Court Directories',
                                  () => _navigateTo(const CourtDirectoriesScreen())),
                              _LinkItem('Emergency 112 / NALSA',
                                  () => _navigateTo(const EmergencyDispatchScreen())),
                              _LinkItem('Whitepaper',
                                  () => _navigateTo(const WhitepaperScreen())),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Column 4: Legal & Trust
                        Expanded(
                          child: _buildColumnSection(
                            title: 'Legal & Trust',
                            links: [
                              _LinkItem('Privacy (Zero Telemetry)',
                                  () => _navigateTo(const PrivacyPolicyScreen())),
                              _LinkItem('Citizen Rights',
                                  () => _navigateTo(const CitizenRightsScreen())),
                              _LinkItem('CrPC Compliance',
                                  () => _navigateTo(const CrpcBnssComplianceScreen())),
                              _LinkItem('Terms of Use',
                                  () => _navigateTo(const TermsOfUseScreen())),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Helpline & Support Highlight Block
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161922),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1E293B)),
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
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '24/7 ACTIVE',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _showCopiedToast('help@civicapp.in'),
                            child: Row(
                              children: [
                                const Icon(Icons.email_outlined,
                                    size: 13, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 6),
                                Text(
                                  'help@civicapp.in',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => _showCopiedToast('1800-11-2026'),
                            child: Row(
                              children: [
                                const Icon(Icons.phone_outlined,
                                    size: 13, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 6),
                                Text(
                                  '+91 1800-11-2026 (Toll-Free National Directory)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    const Divider(color: Color(0xFF1E293B), height: 1),
                    const SizedBox(height: 18),

                    // Social Channels
                    Row(
                      children: [
                        _buildSocialCircle(
                          label: 'X',
                          icon: Icons.tag,
                          onTap: () => _showCopiedToast('https://x.com/civicapp_in'),
                        ),
                        const SizedBox(width: 8),
                        _buildSocialCircle(
                          label: 'GitHub',
                          icon: Icons.code_rounded,
                          onTap: () => _showCopiedToast('https://github.com/civic-legal/civic'),
                        ),
                        const SizedBox(width: 8),
                        _buildSocialCircle(
                          label: 'LinkedIn',
                          icon: Icons.business_center_rounded,
                          onTap: () => _showCopiedToast('https://linkedin.com/company/civic-legal'),
                        ),
                        const SizedBox(width: 8),
                        _buildSocialCircle(
                          label: 'Security',
                          icon: Icons.security_rounded,
                          onTap: () => _showCopiedToast('security@civicapp.in'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Office Location & Legal Notice
                    Text(
                      'CIVIC Central Repository, Legal Defense Hub, New Delhi, India.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE2E8F0),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© 2026 CIVIC. Open Civic Infrastructure. All rights reserved under Constitution of India Art 39A.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: const Color(0xFF64748B),
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
    );
  }

  Widget _buildColumnSection({
    required String title,
    required List<_LinkItem> links,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 7.0),
              child: InkWell(
                onTap: link.onTap,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: Text(
                    link.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSocialCircle({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Center(
          child: Icon(icon, size: 14, color: Colors.white70),
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
