import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_radii.dart';

/// Modal sheets and dialogs for CIVIC Legal, Privacy, Safety, and Governance compliance.
class LegalSafetySheets {
  LegalSafetySheets._();

  /// 1. Legal Terms Modal
  static void showLegalTerms(BuildContext context) {
    _showLegalModal(
      context: context,
      title: 'Legal Terms & Statutory Disclaimers',
      subtitle: 'Statutory basis and operational boundaries under Indian Law',
      children: [
        _buildSectionHeader('1. Educational Legal First-Aid Resource'),
        _buildParagraph(
          'CIVIC is an automated legal first-aid and civic rights education platform designed to provide instant, plain-language statutory guidance. All information is sourced directly from codified legislation in India, including the Bharatiya Nagarik Suraksha Sanhita 2023 (BNSS), the Bharatiya Nyaya Sanhita 2023 (BNS), the Bharatiya Sakshya Adhiniyam 2023 (BSA), and the Constitution of India.',
        ),
        _buildSectionHeader('2. No Attorney-Client Relationship'),
        _buildParagraph(
          'Under the Advocates Act, 1961 and the Bar Council of India Rules, CIVIC does not practice law, solicit clients, or provide licensed legal representation. Accessing CIVIC guides, using AI assistance, or generating checklists does not constitute an attorney-client relationship or formal legal counsel.',
        ),
        _buildSectionHeader('3. Emergency & Active Peril Protocol'),
        _buildParagraph(
          'If you or anyone around you is in immediate physical danger, experiencing violent assault, or facing acute medical distress, immediately call the National Emergency Helpline 112. Do not rely on digital applications during active life-threatening physical emergencies.',
        ),
        _buildSectionHeader('4. Statutory Jurisdiction & Updates'),
        _buildParagraph(
          'Statutory frameworks and court precedents are subject to legislative amendment and judicial interpretation by the Supreme Court of India and State High Courts. CIVIC makes diligent efforts to keep legal references current with active gazette notifications.',
        ),
      ],
    );
  }

  /// 2. Privacy Policy Modal
  static void showPrivacyPolicy(BuildContext context) {
    _showLegalModal(
      context: context,
      title: 'Privacy Policy & Data Sovereignty',
      subtitle: 'Compliant with the Digital Personal Data Protection Act (DPDP), 2023',
      children: [
        _buildSectionHeader('1. Zero-Tracking Statutory Access'),
        _buildParagraph(
          'CIVIC is built on a "local-first, emergency-accessible" principle. You can access all emergency scenario cards, legal rights guides, and helpline directories completely anonymously without creating an account or providing phone/email identifiers.',
        ),
        _buildSectionHeader('2. Incident Vault & End-to-End Privacy'),
        _buildParagraph(
          'Notes, timestamps, badge numbers, and audio memos recorded in your Incident Notes Vault remain encrypted. Local copies are stored securely in on-device storage. When synced with Google Cloud/Firebase, records are protected with industry-standard AES-256 encryption.',
        ),
        _buildSectionHeader('3. No Commercial Data Monetization'),
        _buildParagraph(
          'CIVIC does not sell, rent, monetize, or broker personal user data, location telemetry, or search queries to commercial data brokers, advertising networks, or third-party marketers.',
        ),
        _buildSectionHeader('4. Your Rights Under DPDP Act 2023'),
        _buildParagraph(
          'Under Section 11-13 of the Digital Personal Data Protection Act 2023, you hold the legal right to access a summary of personal data processed, request correction of inaccurate data, withdraw consent, and request complete account and data erasure at any time.',
        ),
      ],
    );
  }

  /// 3. Terms of Service Modal
  static void showTermsOfService(BuildContext context) {
    _showLegalModal(
      context: context,
      title: 'Terms of Service',
      subtitle: 'Terms governing citizen access and application use',
      children: [
        _buildSectionHeader('1. Acceptance of Terms'),
        _buildParagraph(
          'By accessing or using CIVIC on web or mobile platforms, you agree to comply with and be bound by these Terms of Service. If you disagree with any portion of these terms, please discontinue use.',
        ),
        _buildSectionHeader('2. Permitted Lawful Use'),
        _buildParagraph(
          'CIVIC is licensed solely for personal civic preparedness, legal awareness, and non-commercial defense of citizen rights. You agree not to misuse the platform to obstruct legitimate public duties, transmit malicious payloads, or falsify police reports.',
        ),
        _buildSectionHeader('3. User-Generated Content & Ownership'),
        _buildParagraph(
          'All notes, observations, witness accounts, and audio transcripts recorded within your local vault belong entirely to you. CIVIC claims no copyright or proprietary interest in your incident records.',
        ),
        _buildSectionHeader('4. Governing Law & Dispute Resolution'),
        _buildParagraph(
          'These terms are governed by and construed in accordance with the substantive laws of India. Any legal dispute or claim arising hereunder shall fall within the exclusive jurisdiction of the competent courts in New Delhi, India.',
        ),
      ],
    );
  }

  /// 4. Safety Blog Modal
  static void showSafetyBlog(BuildContext context) {
    _showLegalModal(
      context: context,
      title: 'CIVIC Safety & Rights Blog',
      subtitle: 'Field guides on modern citizen rights and scam prevention',
      children: [
        _buildBlogCard(
          context,
          tag: 'CYBER SAFETY',
          title: 'The "Digital Arrest" Scam: What Every Citizen Must Know',
          readTime: '4 MIN READ',
          date: 'OCTOBER 2026',
          summary:
              'Scammers impersonating CBI, Cyber Police, or the Supreme Court are calling citizens over WhatsApp video calls claiming money laundering or drug parcels. Learn why legitimate law enforcement NEVER conducts arrests over Skype or WhatsApp.',
          content:
              'Law enforcement agencies in India (CBI, ED, State Police, Customs) never conduct investigations or place anyone under "Digital Arrest" via WhatsApp, Skype, or Zoom. Under BNSS 2023, any lawful summons must be served officially in writing with verified officer identification. If you receive such a call, disconnect immediately and report to 1930 or cybercrime.gov.in.',
        ),
        const SizedBox(height: 16),
        _buildBlogCard(
          context,
          tag: 'STREET RIGHTS',
          title: 'Can Traffic Police Confiscate Your Ignition Keys or Phone?',
          readTime: '3 MIN READ',
          date: 'SEPTEMBER 2026',
          summary:
              'Examining Sections 130 and 206 of the Motor Vehicles Act: why snatching vehicle keys or forcing phone unlocks at traffic checkpoints is strictly unlawful.',
          content:
              'Under the Central Motor Vehicles Rules and landmark High Court judgments, traffic personnel do not have the power to forcibly snatch ignition keys from vehicles or deflate tires. Only an officer of the rank of Sub-Inspector or above has compounding authority. You are legally entitled to display digital driving licenses via DigiLocker or mParivahan.',
        ),
        const SizedBox(height: 16),
        _buildBlogCard(
          context,
          tag: 'WOMEN RIGHTS',
          title: 'Arrest of Women at Night: Statutory BNSS Safeguards',
          readTime: '5 MIN READ',
          date: 'AUGUST 2026',
          summary:
              'Section 43 BNSS 2023 guarantees that no woman can be arrested between sunset and sunrise except under exceptional circumstances with prior Judicial Magistrate sanction.',
          content:
              'Section 43 of the Bharatiya Nagarik Suraksha Sanhita (replacing Section 46(4) CrPC) establishes that women can only be touched and arrested by female police officers. Arrest between sunset and sunrise is strictly prohibited without an explicit written order from a Judicial Magistrate First Class.',
        ),
      ],
    );
  }

  /// 5. Safety Center Modal
  static void showSafetyCenter(BuildContext context) {
    _showLegalModal(
      context: context,
      title: 'CIVIC Safety Center & SOS Directory',
      subtitle: '24/7 Verified National Helplines & Legal Aid Emergency Access',
      children: [
        _buildHelplineCard(
          context,
          number: '112',
          title: 'National Emergency Response (Police / Fire / Medical)',
          desc: 'Pan-India single emergency response support system with GPS dispatch.',
          isPrimary: true,
        ),
        const SizedBox(height: 12),
        _buildHelplineCard(
          context,
          number: '1930',
          title: 'National Cyber Financial Fraud & Extortion Helpline',
          desc: 'Immediate freezing of fraudulent bank transactions and extortion report.',
          isPrimary: false,
        ),
        const SizedBox(height: 12),
        _buildHelplineCard(
          context,
          number: '15100',
          title: 'NALSA Free Legal Aid Helpline (24/7)',
          desc: 'National Legal Services Authority statutory counsel for eligible citizens.',
          isPrimary: false,
        ),
        const SizedBox(height: 12),
        _buildHelplineCard(
          context,
          number: '1091',
          title: 'Women in Distress National Helpline',
          desc: '24-hour dedicated helpline for women safety and domestic protection.',
          isPrimary: false,
        ),
        const SizedBox(height: 12),
        _buildHelplineCard(
          context,
          number: '1098',
          title: 'Childline Emergency Service',
          desc: 'Dedicated round-the-clock emergency support for children in peril.',
          isPrimary: false,
        ),
      ],
    );
  }

  /// 6. Cookie & Consent Preferences Modal
  static void showCookiePreferences(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CookiePreferencesSheet(),
    );
  }

  // --- Internal Helper Widgets ---

  static void _showLegalModal({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 30,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(top: 14, bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF17261F),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFF5A00),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF17261F)),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFEEEEEE),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Color(0xFFECEEF2), height: 1),

                  // Body Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      children: children,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF17261F),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          height: 1.6,
          color: const Color(0xFF374151),
        ),
      ),
    );
  }

  static Widget _buildBlogCard(
    BuildContext context, {
    required String tag,
    required String title,
    required String readTime,
    required String date,
    required String summary,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5A00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: const Color(0xFFFF5A00),
                  ),
                ),
              ),
              Text(
                '$date · $readTime',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8A8A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF17261F),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              height: 1.5,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFFFAFAFA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text(
                    title,
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  content: Text(
                    content,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.6),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'CLOSE',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFF5A00),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'READ COMPLETE GUIDE',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: const Color(0xFFFF5A00),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFFFF5A00)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildHelplineCard(
    BuildContext context, {
    required String number,
    required String title,
    required String desc,
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF17261F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? const Color(0xFF17261F) : const Color(0xFFECEEF2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isPrimary ? const Color(0xFFFF5A00) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              number,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isPrimary ? Colors.white : const Color(0xFF17261F),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isPrimary ? Colors.white : const Color(0xFF17261F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    height: 1.4,
                    color: isPrimary ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: number));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Helpline number $number copied to clipboard'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(
              Icons.copy_rounded,
              size: 18,
              color: isPrimary ? Colors.white : const Color(0xFF17261F),
            ),
            tooltip: 'Copy Number',
          ),
        ],
      ),
    );
  }
}

class _CookiePreferencesSheet extends StatefulWidget {
  const _CookiePreferencesSheet();

  @override
  State<_CookiePreferencesSheet> createState() => _CookiePreferencesSheetState();
}

class _CookiePreferencesSheetState extends State<_CookiePreferencesSheet> {
  bool _offlineCache = true;
  bool _anonymousDiagnostics = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.cookie_outlined, color: Color(0xFFFF5A00), size: 24),
              const SizedBox(width: 10),
              Text(
                'Data & Storage Preferences',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF17261F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'CIVIC utilizes localized browser storage (cookies & SharedPreferences) strictly for rapid offline guide indexing and language preferences under India DPDP Act 2023. We never track advertising cookies.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              height: 1.5,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 20),
          _buildToggle(
            title: 'Essential Platform Storage',
            subtitle: 'Retains active language, jurisdiction state, and auth session token.',
            value: true,
            isLocked: true,
            onChanged: null,
          ),
          const Divider(height: 20),
          _buildToggle(
            title: 'Statutory Offline Cache',
            subtitle: 'Stores legal scenario cards locally on device for zero-connectivity emergencies.',
            value: _offlineCache,
            isLocked: false,
            onChanged: (v) => setState(() => _offlineCache = v),
          ),
          const Divider(height: 20),
          _buildToggle(
            title: 'Anonymous Performance Diagnostics',
            subtitle: 'Anonymized client render performance to detect web crashing.',
            value: _anonymousDiagnostics,
            isLocked: false,
            onChanged: (v) => setState(() => _anonymousDiagnostics = v),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE2E4EB)),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.pillBorder),
                  ),
                  child: Text(
                    'REJECT OPTIONAL',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: const Color(0xFF17261F),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preferences saved successfully.'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17261F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.pillBorder),
                  ),
                  child: Text(
                    'SAVE PREFERENCES',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required bool value,
    required bool isLocked,
    required ValueChanged<bool>? onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF17261F),
                    ),
                  ),
                  if (isLocked) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'REQUIRED',
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF8A8A8A),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: isLocked ? null : onChanged,
          activeThumbColor: const Color(0xFFFF5A00),
          activeTrackColor: const Color(0xFFFFDBCE),
        ),
      ],
    );
  }
}
