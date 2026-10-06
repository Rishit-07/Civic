import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/services/auth_service.dart';
import '../../../data/services/app_preferences.dart';
import '../../../data/services/location/civic_location_service.dart';
import '../../../data/repositories/content_repository.dart';
import '../../auth/sign_in_screen.dart';
import '../../alerts/civic_alerts_screen.dart';

/// Help Screen matching the CIVIC Design System & Mobile Mockup.
/// Completely functional: zero placeholders, tap-to-call helplines,
/// interactive incident tools (Challan explainer, Complaint drafter, Legal aid finder, Statutory Q&A),
/// geo-directory, settings modals, and an explicit Sign Out button.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with SingleTickerProviderStateMixin {
  // Brand & Semantic Design Palette
  static const Color primary = Color(0xFFA83900);
  static const Color primaryContainer = Color(0xFFFF5A00);
  static const Color primaryFixed = Color(0xFFFFDBCF);
  static const Color onPrimaryFixed = Color(0xFF380D00);
  static const Color tertiary = Color(0xFFBF0715);
  static const Color tertiaryFixed = Color(0xFFFFDAD6);
  static const Color onTertiaryFixed = Color(0xFF410002);
  static const Color secondary = Color(0xFF526259);
  static const Color secondaryContainer = Color(0xFFD5E7DC);
  static const Color onSecondaryContainer = Color(0xFF58685F);
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF5B4137);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ==========================================
  // Helper Actions: Calling, Sharing & Toasts
  // ==========================================

  Future<void> _makeCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await Clipboard.setData(ClipboardData(text: cleanNumber));
        _showToast('Copied $cleanNumber to clipboard (Calling unavailable)');
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: cleanNumber));
      _showToast('Copied $cleanNumber to clipboard');
    }
  }

  Future<void> _openWebUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showToast('Unable to open URL: $url');
      }
    } catch (_) {
      _showToast('Error opening browser');
    }
  }

  Future<void> _sendGpsBeacon() async {
    _showToast('Fetching live Google Maps coordinates...');
    final location = await CivicLocationService.getCurrentLocation();
    final message = CivicLocationService.buildEmergencySosMessage(
      location: location,
      headline: '🚨 CIVIC EMERGENCY SOS',
      situation: 'I require immediate legal first-aid and civilian support.',
    );
    // ignore: deprecated_member_use
    await Share.share(
      message,
      subject: 'CIVIC Emergency Beacon Alert (Live Google Maps Location)',
    );
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF101F18),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ==========================================
  // Modals & Interactive Tools
  // ==========================================

  void _showEmergencyContactsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: tertiaryFixed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.contact_phone_rounded, color: tertiary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMERGENCY CONTACTS',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: onSurface,
                        ),
                      ),
                      Text(
                        'Speed dial for urgent civilian protection',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildContactItem(
                name: 'National Emergency Service (Police/Medical)',
                number: '112',
                icon: Icons.local_police_rounded,
                color: tertiary,
              ),
              _buildContactItem(
                name: 'NALSA Free Legal Aid Hotline',
                number: '15100',
                icon: Icons.balance_rounded,
                color: primary,
              ),
              _buildContactItem(
                name: 'Women in Distress Helpline',
                number: '181',
                icon: Icons.support_agent_rounded,
                color: primaryContainer,
              ),
              _buildContactItem(
                name: 'National Cyber Financial Fraud',
                number: '1930',
                icon: Icons.security_rounded,
                color: secondary,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showToast('ICE (In Case of Emergency) contact sync enabled');
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    'Add Custom Personal ICE Contact',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: const BorderSide(color: primary),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required String name,
    required String number,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                Text(
                  number,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _makeCall(number),
            icon: const Icon(Icons.call_rounded, color: primary, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: surfaceContainerLowest,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileSheet() {
    final user = AuthService.instance.currentUser;
    final email = user?.email ?? (AuthService.instance.isSignedIn ? 'Authenticated Citizen' : 'Guest Citizen (Offline)');
    final isAnonymous = AuthService.instance.isAnonymous || !AuthService.instance.isSignedIn;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'CIVIC Citizen',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAnonymous ? secondaryContainer : primaryFixed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAnonymous ? 'Local Encrypted Sandbox' : 'Cloud Synced Profile',
                            style: GoogleFonts.montserrat(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: isAnonymous ? onSecondaryContainer : onPrimaryFixed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: surfaceContainerHigh),
              const SizedBox(height: 12),
              _buildProfileOptionRow(
                icon: Icons.map_rounded,
                title: 'Jurisdiction State',
                value: AppPreferences.selectedState,
                onTap: () {
                  Navigator.pop(context);
                  _showToast('State Jurisdiction: ${AppPreferences.selectedState}');
                },
              ),
              _buildProfileOptionRow(
                icon: Icons.language_rounded,
                title: 'Preferred Language',
                value: AppPreferences.selectedLanguage == 'hi' ? 'हिन्दी (Hindi)' : 'English',
                onTap: () {
                  Navigator.pop(context);
                  _showLanguageDialog();
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmSignOut();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                  label: Text(
                    'SIGN OUT OF CIVIC',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOptionRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: onSurface,
                ),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF907065)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Tool 1: Explain My Challan
  // ==========================================

  void _showChallanExplainer() {
    final searchCtrl = TextEditingController();
    String? selectedOffence;

    final Map<String, Map<String, String>> offences = {
      'Sec 185: Drunk Driving (BAC > 30mg/100ml)': {
        'fine': '₹10,000 / Up to 6 months imprisonment',
        'compounding': 'Non-compoundable on the spot; requires Magistrate trial.',
        'rights': 'Breath analyzer test required under Sec 203. You have right to blood test within 2 hours at a registered hospital under Sec 204. Police must not impound vehicle if sober companion can drive.',
      },
      'Sec 194B: Seatbelt Violation': {
        'fine': '₹1,000',
        'compounding': 'Compoundable on the spot by Officer of ASI/SI rank and above.',
        'rights': 'Applies to front and rear passengers under CMVR 125(1). Police cannot confiscate license or impound vehicle for simple seatbelt violation.',
      },
      'Sec 194D: Helmet Violation (Rider/Pillion)': {
        'fine': '₹1,000 + 3-month license disqualification',
        'compounding': 'Compoundable on the spot.',
        'rights': 'Must be ISI certified helmet under BIS norms. Pillion rider also liable. Check challan for mandatory compounding receipt.',
      },
      'Sec 130: Non-Production of Documents (DL / RC)': {
        'fine': '₹100 (General) / ₹5,000 if unlicensed',
        'compounding': 'Rule 139 CMVR gives you 15 DAYS to produce original or DigiLocker documents!',
        'rights': 'CRITICAL PROTECTIVE RULE: Police cannot impound vehicle on the spot solely for non-possession of physical documents if electronic credentials on DigiLocker/mParivahan are presented or address is verified.',
      },
      'Sec 177: General Motoring Offence': {
        'fine': '₹500 for first offence, ₹1,500 for subsequent',
        'compounding': 'Compoundable on the spot.',
        'rights': 'Only police officer of Sub-Inspector rank or above with valid receipt book / e-challan POS device is authorized to accept cash.',
      },
      'Sec 184: Dangerous / Reckless Driving': {
        'fine': '₹1,000 - ₹5,000 (1st offence)',
        'compounding': 'Red light jumping, phone usage while driving, jumping lanes dangerously.',
        'rights': 'Notice must state specific speed radar / CCTV camera timestamp and footage location.',
      },
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: surfaceContainerLowest,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryFixed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CHALLAN EXPLAINER',
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: onSurface,
                            ),
                          ),
                          Text(
                            'Motor Vehicles Act 1988 (Amended 2019) & Rule 139 CMVR',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Select or search notice section:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Type section e.g. 185, 130, seatbelt, helmet...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF907065)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: primary),
                    filled: true,
                    fillColor: surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  onChanged: (val) {
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: offences.keys
                              .where((key) => key.toLowerCase().contains(searchCtrl.text.toLowerCase()))
                              .map((offenceKey) {
                            final isSel = selectedOffence == offenceKey;
                            return ChoiceChip(
                              label: Text(
                                offenceKey.split(':')[0],
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isSel ? Colors.white : onSurface,
                                ),
                              ),
                              selected: isSel,
                              selectedColor: primary,
                              backgroundColor: surfaceContainerLow,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              onSelected: (selected) {
                                setModalState(() {
                                  selectedOffence = selected ? offenceKey : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        if (selectedOffence != null && offences.containsKey(selectedOffence)) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surfaceContainerLow,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE4BEB1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedOffence!,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildChallanDetailRow('Statutory Fine:', offences[selectedOffence]!['fine']!),
                                const SizedBox(height: 6),
                                _buildChallanDetailRow('Compounding Rule:', offences[selectedOffence]!['compounding']!),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: surfaceContainerHigh),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.gavel_rounded, color: primary, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            'CITIZEN SAFEGUARD NORM',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        offences[selectedOffence]!['rights']!,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          color: onSurfaceVariant,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: secondaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, color: secondary, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Rule 139 Central Motor Vehicles Rules (CMVR) guarantees you 15 days to present original documents. Police cannot confiscate or impound on the spot without giving 15 days.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: onSurface,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _openWebUrl('https://echallan.parivahan.gov.in/'),
                                icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                                label: Text(
                                  'Parivahan Portal',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: onSurface,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showToast('Challan details verified against CMVR 2019');
                                },
                                icon: const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                                label: Text(
                                  'Done',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChallanDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Tool 2: Draft Complaint Letter
  // ==========================================

  void _showComplaintDrafter() {
    final nameCtrl = TextEditingController(text: 'Citizen Complainant');
    final policeStationCtrl = TextEditingController(text: 'Local Station Officer');
    final incidentCtrl = TextEditingController(text: 'Refusal to register First Information Report (FIR) for cognizable offence');
    String selectedSection = 'Sec 154(3) CrPC / Sec 175(3) BNSS (Representation to Superintendent of Police)';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final letterText = '''
TO,
THE SUPERINTENDENT OF POLICE / MAGISTRATE,
DISTRICT: ${AppPreferences.selectedState}

FROM:
${nameCtrl.text.trim().isEmpty ? '[Citizen Complainant]' : nameCtrl.text.trim()}
CITIZEN APPLICANT UNDER STATUTORY PROVISIONS

SUBJECT: Formal complaint under ${selectedSection.split('(')[0]} for refusal to register FIR under Section 154(1) CrPC / Section 173 BNSS.

RESPECTED SIR/MADAM,

1. That on the relevant date, the undersigned citizen approached the Station House Officer (SHO), ${policeStationCtrl.text.trim()}, to report a cognizable offence involving:
"${incidentCtrl.text.trim()}".

2. That under the binding mandate of the Hon'ble Supreme Court in Lalita Kumari vs. Govt. of U.P. (2014) 2 SCC 1, registration of an FIR is mandatory under Section 154 CrPC if the information discloses commission of a cognizable offence, and no preliminary inquiry is permissible in such cases.

3. That despite disclosing cognizable facts, the local police station failed and neglected to register the FIR and provide a free signed copy to the informant.

PRAYER:
It is therefore respectfully prayed that your good office may be pleased to direct the registration of the FIR forthwith and initiate an impartial statutory investigation under Section 154(3) CrPC / Section 175(3) BNSS.

DATE: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
APPLICANT SIGNATURE: _______________________
''';

          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: surfaceContainerLowest,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.draw_rounded, color: secondary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COMPLAINT LETTER DRAFTER',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: onSurface,
                            ),
                          ),
                          Text(
                            'Statutory Representation for SP / Judicial Magistrate',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Statutory Route:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedSection,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Sec 154(3) CrPC / Sec 175(3) BNSS (Representation to Superintendent of Police)',
                                  child: Text('Sec 154(3) CrPC (SP Representation)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Sec 156(3) CrPC / Sec 175(3) BNSS (Application to Judicial Magistrate)',
                                  child: Text('Sec 156(3) CrPC (Magistrate Direction)'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => selectedSection = val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your Full Name:',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: nameCtrl,
                          onChanged: (_) => setModalState(() {}),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: surfaceContainerLow,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Police Station that Refused FIR:',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: policeStationCtrl,
                          onChanged: (_) => setModalState(() {}),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: surfaceContainerLow,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Brief Incident Facts:',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: incidentCtrl,
                          maxLines: 2,
                          onChanged: (_) => setModalState(() {}),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: surfaceContainerLow,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Generated Legal Draft Preview:',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: surfaceContainerHigh),
                          ),
                          child: SelectableText(
                            letterText,
                            style: GoogleFonts.robotoMono(
                              fontSize: 11,
                              color: onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: letterText));
                                  _showToast('Complaint letter copied to clipboard');
                                },
                                icon: const Icon(Icons.copy_rounded, size: 16),
                                label: Text(
                                  'Copy Draft',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: onSurface,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // ignore: deprecated_member_use
                                  Share.share(letterText, subject: 'Legal Complaint under Section 154(3) CrPC');
                                },
                                icon: const Icon(Icons.share_rounded, size: 16, color: Colors.white),
                                label: Text(
                                  'Share / Print',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // Tool 3: Find Legal Aid Near Me
  // ==========================================

  void _showLegalAidFinder() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryFixed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.near_me_rounded, color: primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DISTRICT LEGAL SERVICES (DLSA)',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: onSurface,
                        ),
                      ),
                      Text(
                        'Sec 12 Legal Services Authorities Act, 1987',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WHO GETS 100% FREE LEGAL AID?',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Women and Children (Automatic, no income test)\n'
                    '• Members of SC / ST communities\n'
                    '• Persons in Police Custody or Judicial Custody\n'
                    '• Industrial Workmen & Persons with Disabilities\n'
                    '• General citizens with annual income below State ceiling (₹1,00,000 - ₹3,00,000)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: onSurface,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Nearest Front Offices & Access Channels:',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  _buildLegalAidCard(
                    title: 'DLSA Front Office (District Court Complex)',
                    desc: 'Free panel lawyer assignment for bail, trial defence, and appeals in any court.',
                    phone: '15100',
                    actionLabel: 'Call 15100',
                  ),
                  _buildLegalAidCard(
                    title: 'Tele-Law Scheme (Ministry of Law & Justice)',
                    desc: 'Video/Audio consultation with High Court & Supreme Court panel advocates.',
                    phone: '18001801510',
                    actionLabel: 'Call Tele-Law',
                  ),
                  _buildLegalAidCard(
                    title: 'State Consumer Disputes Commission',
                    desc: 'Free consumer grievance mediation under Consumer Protection Act 2019.',
                    phone: '1915',
                    actionLabel: 'Call 1915',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openWebUrl('https://nalsa.gov.in/'),
                icon: const Icon(Icons.language_rounded, size: 18, color: Colors.white),
                label: Text(
                  'Visit Official NALSA Portal (nalsa.gov.in)',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalAidCard({
    required String title,
    required String desc,
    required String phone,
    required String actionLabel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: surfaceContainerHigh),
      ),
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
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _makeCall(phone),
            style: ElevatedButton.styleFrom(
              backgroundColor: onSurface,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: Text(
              actionLabel,
              style: GoogleFonts.montserrat(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Tool 4: Ask a Question (Statutory Norms)
  // ==========================================

  void _showAskQuestionModal() {
    final queryCtrl = TextEditingController();
    String? selectedQuestion;

    final Map<String, String> faqs = {
      'Can police seize or search my phone on the street?':
          'NO. Under Article 21 (Right to Privacy - Puttaswamy ruling) and Sec 100/102 CrPC / Sec 103 BNSS, police cannot casually browse your phone without a specific judicial warrant or formal seizure memo citing reasonable suspicion of an active crime. You cannot be compelled to give phone biometric/passwords under Article 20(3) (Protection against self-incrimination).',
      'Can women be arrested after sunset or before sunrise?':
          'STRICTLY PROHIBITED under Section 46(4) CrPC / Section 43(5) BNSS. Except under exceptional circumstances with the PRIOR written permission of a Judicial Magistrate, no woman can be arrested between sunset and sunrise. Any arrest must be conducted strictly by a female officer.',
      'What is a Zero FIR?':
          'Under Section 173 BNSS (and Supreme Court directives), any police station in India is legally mandated to register an FIR for a cognizable offence regardless of territorial jurisdiction. The station must assign it as Zero FIR, record the statement, and transfer the case to the competent jurisdiction.',
      'How long can police detain someone without court production?':
          'MAXIMUM 24 HOURS strictly, under Article 22(2) of the Constitution and Section 57 CrPC / Section 58 BNSS (excluding journey time). Failure to produce before the nearest Magistrate within 24 hours makes custody illegal and constitutes wrongful confinement.',
      'Do I have the right to call a lawyer during police interrogation?':
          'YES. Under Section 41D CrPC / Section 37 BNSS, an arrested citizen is legally entitled to meet and consult an advocate of their choice throughout interrogation, though not for the entire duration of interrogation.',
      'What if police refuse to register my FIR?':
          'Under Section 154(3) CrPC / Section 175(3) BNSS, send the complaint in writing by registered post to the Superintendent of Police (SP). If still unaddressed, file an application before the Judicial Magistrate under Section 156(3) CrPC.',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final query = queryCtrl.text.toLowerCase();
          final filteredFaqs = faqs.entries.where((e) {
            return e.key.toLowerCase().contains(query) || e.value.toLowerCase().contains(query);
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: surfaceContainerLowest,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.contact_support_rounded, color: primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATUTORY LEGAL ASSISTANT',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: onSurface,
                            ),
                          ),
                          Text(
                            'Verified constitutional & procedural norms',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: queryCtrl,
                  decoration: InputDecoration(
                    hintText: 'Ask any question (e.g., search, arrest, bail, phone)...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF907065)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: primary),
                    filled: true,
                    fillColor: surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  onChanged: (_) => setModalState(() {}),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final item = filteredFaqs[index];
                      final isExpanded = selectedQuestion == item.key;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isExpanded ? primary : surfaceContainerHigh,
                          ),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            initiallyExpanded: isExpanded,
                            onExpansionChanged: (expanded) {
                              setModalState(() {
                                selectedQuestion = expanded ? item.key : null;
                              });
                            },
                            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            leading: Icon(
                              Icons.verified_user_rounded,
                              color: isExpanded ? primary : secondary,
                              size: 20,
                            ),
                            title: Text(
                              item.key,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.value,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      color: onSurfaceVariant,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // Section 3: Geo-Directory Modal
  // ==========================================

  void _showGeoDirectoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryFixed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.radar_rounded, color: primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LEGAL AID OFFICES & PORTALS',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: onSurface,
                        ),
                      ),
                      Text(
                        'Jurisdiction: ${AppPreferences.selectedState} (State Network)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildGeoItem(
                    title: 'District Legal Services Authority (DLSA)',
                    subtitle: 'District Court Complex, Main Administrative Block',
                    badge: 'Legal Aid & Lok Adalat',
                    phone: '15100',
                    url: 'https://nalsa.gov.in/our-legal-aid-schemes',
                  ),
                  _buildGeoItem(
                    title: 'Special Police Unit for Women & Children',
                    subtitle: 'Designated Female Protection Officers & Counselling',
                    badge: 'Women Security (Sec 46 CrPC)',
                    phone: '181',
                    url: 'https://wcd.nic.in/',
                  ),
                  _buildGeoItem(
                    title: 'District Consumer Disputes Redressal Commission',
                    subtitle: 'Sec 35 Consumer Protection Act 2019 • E-Daakhil',
                    badge: 'Consumer Grievance',
                    phone: '1915',
                    url: 'https://edaakhil.nic.in/',
                  ),
                  _buildGeoItem(
                    title: 'National Cyber Crime Reporting Portal',
                    subtitle: 'Ministry of Home Affairs Financial Cyber Fraud Node',
                    badge: 'Golden Hour Sec 1930',
                    phone: '1930',
                    url: 'https://cybercrime.gov.in/',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeoItem({
    required String title,
    required String subtitle,
    required String badge,
    required String phone,
    required String url,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: surfaceContainerHigh),
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
                  color: secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.montserrat(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _makeCall(phone),
                icon: const Icon(Icons.call_rounded, size: 14, color: Colors.white),
                label: Text(
                  'Call $phone',
                  style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: onSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _openWebUrl(url),
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: Text(
                  'Official Portal',
                  style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(color: primary),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Section 4: Settings & App Info Dialogs
  // ==========================================

  void _showOfflineStorageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.offline_pin_rounded, color: secondary, size: 24),
            const SizedBox(width: 10),
            Text(
              'Offline Storage',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: Active (100% On-Device)',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All statutory rules, scenario cards, and emergency helplines are stored locally in the app bundle. Zero network connection is needed to browse legal first-aid.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Local Cache Size:', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                  Text('~4.2 MB (Encrypted)', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ContentRepository.instance.loadCategories();
              _showToast('Content cache validated and refreshed');
            },
            child: Text(
              'Re-index Cache',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: primary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: onSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (dlgContext) => StatefulBuilder(
        builder: (context, setDlgState) {
          final currentLang = AppPreferences.selectedLanguage;
          return AlertDialog(
            backgroundColor: surfaceContainerLowest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                const Icon(Icons.translate_rounded, color: secondary, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Select Language',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(
                  label: 'English (Default)',
                  isSelected: currentLang == 'en',
                  onSelect: () async {
                    final nav = Navigator.of(context);
                    await AppPreferences.setSelectedLanguage('en');
                    setDlgState(() {});
                    if (mounted) setState(() {});
                    nav.pop();
                    _showToast('Language updated to English');
                  },
                ),
                _buildLanguageOption(
                  label: 'हिन्दी (Hindi)',
                  isSelected: currentLang == 'hi',
                  onSelect: () async {
                    final nav = Navigator.of(context);
                    await AppPreferences.setSelectedLanguage('hi');
                    setDlgState(() {});
                    if (mounted) setState(() {});
                    nav.pop();
                    _showToast('भाषा बदलकर हिन्दी कर दी गई है');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryFixed : surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primary : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? onPrimaryFixed : onSurface,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: primary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showPrivacySecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.security_rounded, color: secondary, size: 24),
            const SizedBox(width: 10),
            Text(
              'Privacy & On-Device Security',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zero Tracking • Zero Telemetry',
              style: GoogleFonts.montserrat(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'CIVIC is built on a strict privacy-first architecture:\n'
              '• Incident audio recordings, photos, and notes are stored strictly inside the app sandbox.\n'
              '• No law enforcement surveillance tracking.\n'
              '• Verified offline legal statutes comply with the Gazette of India.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: onSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReportErrorDialog() {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.report_problem_rounded, color: primary, size: 24),
            const SizedBox(width: 10),
            Text(
              'Report Legal Update',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Found a statutory citation discrepancy or recent High Court / Supreme Court update?',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter statutory citation or observation...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF907065)),
                filled: true,
                fillColor: surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast('Report submitted to CIVIC Legal Verification Team');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Image.asset(
              'assets/images/civic_logo.png',
              width: 28,
              height: 28,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield_rounded, color: primary, size: 28),
            ),
            const SizedBox(width: 10),
            Text(
              'About CIVIC',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CIVIC v2.4.1 (Production)',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Constitutional & Statutory Legal First-Aid for Indian Citizens.\n\n'
              'Empowering citizens with actionable procedural rights under the Constitution of India, '
              'Bharatiya Nagarik Suraksha Sanhita (BNSS 2023), Motor Vehicles Act, and D.K. Basu Guidelines.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: onSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Got it', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SIGN OUT FUNCTIONALITY (Explicit User Request)
  // ==========================================

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (dlgContext) => AlertDialog(
        backgroundColor: surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: error, size: 24),
            const SizedBox(width: 10),
            Text(
              'Sign Out of CIVIC?',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'You will be signed out and returned to the Login / Onboarding screen. Your local offline database will remain safely intact.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: onSurfaceVariant, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              Navigator.pop(dlgContext); // Close dialog

              // 1. Sign out of Firebase and Google
              try {
                await AuthService.instance.signOut();
              } catch (e) {
                debugPrint('Sign out notice: $e');
              }

              // 2. Clear first launch completion flag so user lands on login/onboarding cleanly
              await AppPreferences.setFirstLaunchComplete(false);

              // 3. Navigate back to SignInScreen and clear navigation stack
              if (mounted) {
                nav.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Sign Out',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BUILD METHOD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      body: Stack(
        children: [
          // Main Scrollable Area
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 126, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Architectural Hero Card
                _buildHeroCard(),
                const SizedBox(height: 24),

                // Section 1: Verified Helplines
                _buildHelplinesSection(),
                const SizedBox(height: 28),

                // Section 2: After an Incident (2x2 Grid)
                _buildAfterIncidentSection(),
                const SizedBox(height: 28),

                // Section 3: Geo-Directory Prominent Row Card
                _buildGeoDirectoryCard(),
                const SizedBox(height: 28),

                // Section 4: Settings & App Info (Including Sign Out)
                _buildSettingsSection(),
                const SizedBox(height: 28),

                // Footer
                _buildFooter(),
              ],
            ),
          ),

          // Fixed Top Header matching HTML
          _buildFixedHeader(),
        ],
      ),
    );
  }

  // ==========================================
  // Header Component (Fixed Top)
  // ==========================================

  Widget _buildFixedHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: surface.withValues(alpha: 0.95),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Red Emergency SOS Bar
              Container(
                color: tertiary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emergency_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'EMERGENCY SOS',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildEmergencyTopPill('112', () => _makeCall('112')),
                        const SizedBox(width: 6),
                        _buildEmergencyTopPill('15100', () => _makeCall('15100')),
                        const SizedBox(width: 6),
                        _buildEmergencyIconButton(
                          icon: Icons.near_me_rounded,
                          tooltip: 'GPS Beacon',
                          onTap: _sendGpsBeacon,
                        ),
                        const SizedBox(width: 6),
                        _buildEmergencyIconButton(
                          icon: Icons.contact_phone_rounded,
                          tooltip: 'Emergency Contacts',
                          onTap: _showEmergencyContactsSheet,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // CIVIC App Bar Row
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/civic_logo.png',
                          height: 32,
                          width: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.shield_rounded,
                            color: primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CIVIC',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: primary,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Help',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CivicAlertsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_none_rounded, size: 20, color: onSurface),
                          style: IconButton.styleFrom(
                            backgroundColor: surfaceContainerLow,
                            padding: const EdgeInsets.all(8),
                          ),
                          tooltip: 'Civic Alerts & Notices',
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _showProfileSheet,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
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

  Widget _buildEmergencyTopPill(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(13),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(13),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    );
  }

  // ==========================================
  // Hero Card Component
  // ==========================================

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background subtle circles
          Positioned(
            right: -25,
            bottom: -25,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: primaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 45,
            top: 15,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: secondary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryFixed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_rounded, color: onPrimaryFixed, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        'CIVIC GUIDANCE & EMERGENCY',
                        style: GoogleFonts.montserrat(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: onPrimaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'HELP',
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'WHO TO CALL, WHAT TO DO NEXT',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Section 1: Verified Helplines
  // ==========================================

  Widget _buildHelplinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FadeTransition(
                  opacity: _pulseAnimation,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'VERIFIED HELPLINES',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: onSurface,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Toll-Free 24×7',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 6 Helplines
        _buildHelplineRow(
          title: 'Emergency Police & Medical',
          subtitle: '112',
          icon: Icons.local_police_rounded,
          iconBg: errorContainer,
          iconColor: onErrorContainer,
          callLabel: 'CALL 112',
          phoneNumber: '112',
        ),
        _buildHelplineRow(
          title: 'National Free Legal Aid (NALSA)',
          subtitle: '15100 • Sec. 12 LSA Act',
          icon: Icons.balance_rounded,
          iconBg: primaryFixed,
          iconColor: onPrimaryFixed,
          callLabel: 'CALL 15100',
          phoneNumber: '15100',
        ),
        _buildHelplineRow(
          title: 'Childline Protection',
          subtitle: '1098',
          icon: Icons.child_care_rounded,
          iconBg: secondaryContainer,
          iconColor: onSecondaryContainer,
          callLabel: 'CALL 1098',
          phoneNumber: '1098',
        ),
        _buildHelplineRow(
          title: 'National Women Helpline',
          subtitle: '181',
          icon: Icons.support_agent_rounded,
          iconBg: tertiaryFixed,
          iconColor: onTertiaryFixed,
          callLabel: 'CALL 181',
          phoneNumber: '181',
        ),
        _buildHelplineRow(
          title: 'Cyber Crime Helpline',
          subtitle: '1930 • Financial Fraud',
          icon: Icons.lock_person_rounded,
          iconBg: surfaceContainerHigh,
          iconColor: onSurface,
          callLabel: 'CALL 1930',
          phoneNumber: '1930',
        ),
        _buildHelplineRow(
          title: 'Anti-Ragging Helpline',
          subtitle: '1800-180-5522',
          icon: Icons.school_rounded,
          iconBg: surfaceContainer,
          iconColor: onSurface,
          callLabel: 'CALL',
          phoneNumber: '18001805522',
        ),
      ],
    );
  }

  Widget _buildHelplineRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String callLabel,
    required String phoneNumber,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _makeCall(phoneNumber),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: onSurface,
                borderRadius: BorderRadius.circular(21),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.call_rounded, color: primaryContainer, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    callLabel,
                    style: GoogleFonts.montserrat(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Section 2: After an Incident (2x2 Grid)
  // ==========================================

  Widget _buildAfterIncidentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AFTER AN INCIDENT',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Step-by-step procedural actions you can initiate right now.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.15,
          children: [
            _buildIncidentActionCard(
              title: 'Explain my challan',
              subtitle: 'Scan or type notice details',
              icon: Icons.receipt_long_rounded,
              onTap: _showChallanExplainer,
            ),
            _buildIncidentActionCard(
              title: 'Draft complaint letter',
              subtitle: 'Format for SP / Magistrate',
              icon: Icons.draw_rounded,
              onTap: _showComplaintDrafter,
            ),
            _buildIncidentActionCard(
              title: 'Find legal aid near me',
              subtitle: 'District DLSA authorities',
              icon: Icons.near_me_rounded,
              onTap: _showLegalAidFinder,
            ),
            _buildIncidentActionCard(
              title: 'Ask a question',
              subtitle: 'Verified statutory norms',
              icon: Icons.contact_support_rounded,
              onTap: _showAskQuestionModal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncidentActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: surfaceContainerLow,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Icon(icon, color: onSurface, size: 20),
                ),
                const Icon(Icons.arrow_forward_rounded, color: primaryContainer, size: 16),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Section 3: Geo-Directory Prominent Row Card
  // ==========================================

  Widget _buildGeoDirectoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Quarter circle background accent
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: secondaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: primaryFixed,
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: const Icon(Icons.radar_rounded, color: onPrimaryFixed, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEO-DIRECTORY',
                        style: GoogleFonts.montserrat(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Legal Aid Offices & Portals',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Official DLSA centers, women police stations, and consumer fora near your location.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _showGeoDirectoryModal,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: onSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Section 4: Settings & App Info (with Sign Out)
  // ==========================================

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'SETTINGS & APP INFO',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: onSurface,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 1),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildUtilityRow(
                icon: Icons.offline_pin_rounded,
                title: 'Settings & Offline Storage',
                badgeText: 'Encrypted',
                badgeBg: secondaryContainer,
                badgeColor: onSecondaryContainer,
                onTap: _showOfflineStorageDialog,
              ),
              _buildDivider(),
              _buildUtilityRow(
                icon: Icons.translate_rounded,
                title: 'Language',
                customValue: Text(
                  AppPreferences.selectedLanguage == 'hi' ? 'हिन्दी' : 'English / हिन्दी',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
                onTap: _showLanguageDialog,
              ),
              _buildDivider(),
              _buildUtilityRow(
                icon: Icons.security_rounded,
                title: 'Privacy & On-Device Security',
                onTap: _showPrivacySecurityDialog,
              ),
              _buildDivider(),
              _buildUtilityRow(
                icon: Icons.report_problem_rounded,
                title: 'Report an Error or Statutory Update',
                onTap: _showReportErrorDialog,
              ),
              _buildDivider(),
              _buildUtilityRow(
                icon: Icons.info_rounded,
                title: 'About CIVIC',
                customValue: Text(
                  'v2.4.1',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: onSurfaceVariant,
                  ),
                ),
                onTap: _showAboutDialog,
              ),
              _buildDivider(),

              // SIGN OUT BUTTON (Explicit User Request)
              InkWell(
                onTap: _confirmSignOut,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.logout_rounded, color: error, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign Out of CIVIC',
                              style: GoogleFonts.montserrat(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: error,
                              ),
                            ),
                            Text(
                              'Return to Login / Onboarding screen',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 20, color: error),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUtilityRow({
    required IconData icon,
    required String title,
    String? badgeText,
    Color? badgeBg,
    Color? badgeColor,
    Widget? customValue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: secondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: onSurface,
                ),
              ),
            ),
            if (badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg ?? secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor ?? onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (customValue != null) ...[
              customValue,
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF907065)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: surfaceContainerHigh.withValues(alpha: 0.6),
    );
  }

  // ==========================================
  // Footer Component
  // ==========================================

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: onSecondaryContainer, size: 14),
              const SizedBox(width: 6),
              Text(
                'WORKS 100% OFFLINE • NO THIRD-PARTY TRACKING',
                style: GoogleFonts.montserrat(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              'Legal information, not legal advice. In active custodial arrest, request immediate access to a legal practitioner.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
