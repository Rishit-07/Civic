import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/content_models.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/services/app_preferences.dart';
import '../../../data/services/location/civic_location_service.dart';
import '../../scenarios/situation_card_screen.dart';
import '../../scenarios/situation_list_screen.dart';
import '../../scenarios/triage_screen.dart';
import '../../navigation/widgets/civic_dynamic_footer.dart';
import '../../showcase/civic_scroll_gallery_screen.dart';
import '../../profile/profile_screen.dart';
import '../../alerts/civic_alerts_screen.dart';

/// Complete, pixel-perfect CIVIC Home Screen based directly on
/// the Neo-Constructivist Stitch design system with full offline legal assistance,
/// quick SOS dispatcher, scenario discovery grid, and DK Basu rights highlight.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedMode = 'now'; // 'now', 'prepare', 'after'
  String _selectedState = 'ALL';
  bool _isMicActive = false;
  String _searchQuery = '';
  List<Category> _allCategories = [];

  static const Map<String, String> _indianStates = {
    'ALL': 'All-India (National Rules)',
    'DL': 'Delhi NCT',
    'AP': 'Andhra Pradesh',
    'AR': 'Arunachal Pradesh',
    'AS': 'Assam',
    'BR': 'Bihar',
    'CG': 'Chhattisgarh',
    'GA': 'Goa',
    'GJ': 'Gujarat',
    'HR': 'Haryana',
    'HP': 'Himachal Pradesh',
    'JH': 'Jharkhand',
    'KA': 'Karnataka',
    'KL': 'Kerala',
    'MP': 'Madhya Pradesh',
    'MH': 'Maharashtra',
    'MN': 'Manipur',
    'ML': 'Meghalaya',
    'MZ': 'Mizoram',
    'NL': 'Nagaland',
    'OD': 'Odisha',
    'PB': 'Punjab',
    'RJ': 'Rajasthan',
    'SK': 'Sikkim',
    'TN': 'Tamil Nadu',
    'TG': 'Telangana',
    'TR': 'Tripura',
    'UP': 'Uttar Pradesh',
    'UT': 'Uttarakhand',
    'WB': 'West Bengal',
    // Union Territories
    'AN': 'Andaman & Nicobar Islands',
    'CH': 'Chandigarh',
    'DN': 'Dadra & Nagar Haveli and Daman & Diu',
    'JK': 'Jammu & Kashmir',
    'LA': 'Ladakh',
    'LD': 'Lakshadweep',
    'PY': 'Puducherry',
  };

  @override
  void initState() {
    super.initState();
    _selectedState = AppPreferences.selectedState;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ContentRepository.instance.loadCategories();
      if (mounted) {
        setState(() {
          _allCategories = cats;
        });
      }
    } catch (_) {}
  }

  List<Map<String, dynamic>> get _matchingScenarios {
    if (_searchQuery.isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    final results = <Map<String, dynamic>>[];

    for (final cat in _allCategories) {
      for (final sc in cat.scenarios) {
        final matches = sc.label.toLowerCase().contains(q) ||
            sc.description.toLowerCase().contains(q) ||
            cat.label.toLowerCase().contains(q) ||
            sc.id.toLowerCase().contains(q);
        if (matches) {
          results.add({
            'scenario': sc,
            'category': cat,
          });
        }
      }
    }
    return results;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showToast('Calling $number...');
      }
    } catch (_) {
      _showToast('Calling $number...');
    }
  }

  Future<void> _shareGpsBeacon() async {
    _showToast('Fetching live Google Maps coordinates...');
    final location = await CivicLocationService.getCurrentLocation();
    final message = CivicLocationService.buildEmergencySosMessage(
      location: location,
      headline: '🚨 CIVIC EMERGENCY SOS',
      situation: 'I require immediate legal first-aid. My emergency beacon has been activated.',
    );
    // ignore: deprecated_member_use
    await Share.share(
      message,
      subject: 'CIVIC Emergency Beacon (Live Google Maps Location)',
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
          ),
        ),
        backgroundColor: const Color(0xFF101F18),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _toggleMic() {
    setState(() {
      _isMicActive = !_isMicActive;
      if (_isMicActive) {
        _searchController.text = 'police traffic stop';
        _searchQuery = 'police traffic stop';
      } else {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _openSituationList({String? categoryId, String? searchQuery}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SituationListScreen(
          initialCategoryId: categoryId,
          initialSearchQuery: searchQuery,
        ),
      ),
    );
  }

  void _showContactsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E2E2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.contacts_rounded,
                      color: Color(0xFFBF0715), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'EMERGENCY DIRECTORY',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1C),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildContactTile(
                  '112', 'National Emergency Police / Ambulance', Icons.call),
              _buildContactTile(
                  '15100', 'NALSA Free Legal Aid Helpline', Icons.gavel),
              _buildContactTile(
                  '1091', 'Women in Distress Helpline', Icons.security),
              _buildContactTile(
                  '1930', 'National Cyber Crime Reporting', Icons.lock),
              _buildContactTile(
                  '1098', 'Childline Emergency Assistance', Icons.child_care),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactTile(String number, String label, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF101F18), size: 20),
      ),
      title: Text(
        number,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w800,
          fontSize: 15,
          color: const Color(0xFF101F18),
        ),
      ),
      subtitle: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: const Color(0xFF5B4137),
        ),
      ),
      trailing: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          _callNumber(number);
        },
        icon: const Icon(Icons.phone, size: 14, color: Colors.white),
        label: Text('CALL',
            style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBF0715),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  void _showStatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E2E2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'SELECT JURISDICTION',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1C1C),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Prioritizes local state police manuals, rent control acts & campus guidelines.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF5B4137),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: _indianStates.entries.map((entry) {
                    final isSelected = entry.key == _selectedState;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isSelected
                            ? const Color(0xFFFF5A00)
                            : const Color(0xFF907065),
                        size: 20,
                      ),
                      title: Text(
                        entry.value,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF101F18)
                              : const Color(0xFF1A1C1C),
                        ),
                      ),
                      trailing: isSelected
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFDBCF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFA83900),
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedState = entry.key;
                        });
                        AppPreferences.setSelectedState(entry.key);
                        Navigator.pop(context);
                        _showToast('Jurisdiction set to ${entry.value}');
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Emergency SOS Bar (Red)
            _buildTopEmergencyBar(),

            // 2. Main App Header Bar (Logo, Title, State Chip & Profile)
            _buildAppHeader(),

            // 3. Scrollable Home Content Body
            Expanded(
              child: Stack(
                children: [
                  // Ambient Neo-Constructivist Background Accents
                  _buildAmbientBackground(),

                  // Scrollable Body Content
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18.0, 12.0, 18.0, 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // A. Emergency Quick-Action Card (High Priority SOS Tray)
                        _buildEmergencySosCard(),
                        const SizedBox(height: 20),

                        // B. Reassuring Greeting Header Section
                        _buildGreetingSection(),
                        const SizedBox(height: 18),

                        // C. High-Contrast Search & Speech Input Field
                        _buildSearchBar(),
                        const SizedBox(height: 16),

                        // D. Procedural Mode Chips Filter (Segmented Flow Selector)
                        _buildModeChipsFilter(),
                        const SizedBox(height: 22),

                        // E. 2-Column Grid of 6 Situation Cards or Live Search Results
                        if (_searchQuery.isNotEmpty) ...[
                          _buildSearchResults(),
                          const SizedBox(height: 22),
                        ] else ...[
                          _buildScenarioGridHeader(),
                          const SizedBox(height: 12),
                          _buildScenarioGrid(),
                          const SizedBox(height: 22),
                        ],

                        // F. Interactive Quick Rights Highlight (DK Basu Verdict)
                        _buildDkBasuCard(),
                        const SizedBox(height: 20),

                        // Visual Horizontal Scroll Gallery Showcase Banner
                        _buildVisualGalleryBanner(),
                        const SizedBox(height: 20),

                        // G. Offline Assurance Guarantee Badge
                        _buildOfflineGuaranteeBadge(),
                        const SizedBox(height: 16),

                        // H. Dynamic Footer Showcase Block
                        const CivicDynamicFooter(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Emergency Red SOS Header Strip
  Widget _buildTopEmergencyBar() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFBF0715),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TriageScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                const Icon(
                  Icons.crisis_alert_rounded,
                  color: Colors.white,
                  size: 17,
                ),
                const SizedBox(width: 6),
                Text(
                  'EMERGENCY SOS',
                  style: GoogleFonts.montserrat(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
          Row(
            children: [
              // 112 Direct Dial Pill
              InkWell(
                onTap: () => _callNumber('112'),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '112',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 15100 Direct Dial Pill
              InkWell(
                onTap: () => _callNumber('15100'),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '15100',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Share Location Button
              InkWell(
                onTap: _shareGpsBeacon,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 30,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.near_me_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Trusted Contacts Button
              InkWell(
                onTap: _showContactsSheet,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 30,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.contact_phone_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// App Header Bar (Logo, CIVIC title, State chip, Notifications & Profile)
  Widget _buildAppHeader() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9).withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE8E8E8), width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/civic_logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
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
                      color: const Color(0xFFA83900),
                      letterSpacing: 1.4,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Home',
                    style: GoogleFonts.montserrat(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1C),
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Jurisdiction Selector Chip
              GestureDetector(
                onTap: _showStatePicker,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E2E2)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: Color(0xFFA83900)),
                      const SizedBox(width: 4),
                      Text(
                        _selectedState == 'ALL' ? 'ALL-INDIA' : _selectedState,
                        style: GoogleFonts.montserrat(
                          color: const Color(0xFFA83900),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Notification Icon Button
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF1A1C1C),
                        size: 19,
                      ),
                      tooltip: 'Civic Alerts & Notices',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CivicAlertsScreen(),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5A00),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Profile Avatar Circle
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    ).then((_) {
                      if (mounted) setState(() {});
                    });
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFFA83900),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      AppPreferences.profileAvatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 19,
                        );
                      },
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

  /// Neo-Constructivist Background Decorative Floating Accents
  Widget _buildAmbientBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Top Right Soft Orange Ambient Circle
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF5A00).withValues(alpha: 0.08),
                ),
              ),
            ),
            // Left Middle Subtle Grey Circle
            Positioned(
              top: 140,
              left: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8E8E8).withValues(alpha: 0.5),
                ),
              ),
            ),
            // Dashed Constructivist Ring with Orange Accent Dot
            Positioned(
              top: 80,
              right: 14,
              child: SizedBox(
                width: 70,
                height: 70,
                child: CustomPaint(
                  painter: _DashedCirclePainter(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Emergency Quick-Action Card (High Priority SOS Tray)
  Widget _buildEmergencySosCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFBF0715),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33BF0715),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Translucent Decorative Arch
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.crisis_alert_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'CRITICAL EMERGENCY DISPATCH',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Direct Dial',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4 Quick-Tap SOS Buttons
                Row(
                  children: [
                    _buildSosActionTile(
                      icon: Icons.call_rounded,
                      title: '112 Police',
                      onTap: () => _callNumber('112'),
                    ),
                    const SizedBox(width: 8),
                    _buildSosActionTile(
                      icon: Icons.gavel_rounded,
                      title: '15100 Aid',
                      onTap: () => _callNumber('15100'),
                    ),
                    const SizedBox(width: 8),
                    _buildSosActionTile(
                      icon: Icons.my_location_rounded,
                      title: 'GPS Beacon',
                      onTap: _shareGpsBeacon,
                    ),
                    const SizedBox(width: 8),
                    _buildSosActionTile(
                      icon: Icons.contacts_rounded,
                      title: 'Contacts',
                      onTap: _showContactsSheet,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Reassuring Greeting Section
  Widget _buildGreetingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5A00),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'OFFLINE LEGAL FIRST-AID GUIDE',
                    style: GoogleFonts.montserrat(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5B4137),
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.montserrat(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF101F18),
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                  children: const [
                    TextSpan(text: 'Stay calm.\n'),
                    TextSpan(
                      text: "We've got you.",
                      style: TextStyle(color: Color(0xFFA83900)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Isometric Decorative Motif Container
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFFFDBCF),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0E000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Transform.rotate(
            angle: -0.04,
            child: Center(
              child: SvgPicture.string(
                '''<svg width="44" height="44" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M14 50 L50 50 L46 56 L10 56 Z" fill="#101F18"/>
                  <path d="M22 48 C22 28, 42 28, 42 48 Z" fill="#FF5A00"/>
                  <circle cx="32" cy="22" fill="#101F18" r="8"/>
                  <path d="M24 22 L40 22" stroke="#FFFFFF" stroke-linecap="round" stroke-width="2"/>
                  <path d="M32 14 L32 22" stroke="#FFFFFF" stroke-linecap="round" stroke-width="2"/>
                  <circle cx="48" cy="16" fill="#FF5A00" r="3"/>
                </svg>''',
                width: 44,
                height: 44,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// High-Contrast Search & Speech Input Field
  Widget _buildSearchBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C101F18),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF5B4137),
              size: 22,
            ),
            onPressed: () => _openSituationList(searchQuery: _searchController.text.trim()),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              onSubmitted: (value) => _openSituationList(searchQuery: value),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1C1C),
              ),
              decoration: InputDecoration(
                hintText: "What's happening right now?",
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5B4137).withValues(alpha: 0.65),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.clear_rounded,
                size: 20,
                color: Color(0xFF5B4137),
              ),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
          GestureDetector(
            onTap: _toggleMic,
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _isMicActive
                    ? const Color(0xFFFF5A00)
                    : const Color(0xFFEEEEEE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic_rounded,
                size: 19,
                color: _isMicActive ? Colors.white : const Color(0xFF1A1C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Live Search Results Overlay View
  Widget _buildSearchResults() {
    final matches = _matchingScenarios;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MATCHING SCENARIOS (${matches.length})',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF5B4137),
                letterSpacing: 1.4,
              ),
            ),
            InkWell(
              onTap: () => _openSituationList(searchQuery: _searchQuery),
              child: Text(
                'Open Full Directory ➔',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF5A00),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (matches.isEmpty)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded, size: 36, color: Color(0xFF907065)),
                const SizedBox(height: 10),
                Text(
                  'No direct scenario matched "$_searchQuery"',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1C1C),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Try searching for traffic, police, rent, landlord, hospital, cheque, or browse the complete legal directory.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF5B4137),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () => _openSituationList(searchQuery: _searchQuery),
                  icon: const Icon(Icons.menu_book_rounded, size: 16),
                  label: const Text('EXPLORE ALL 65 SCENARIOS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF101F18),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: matches.length > 8 ? 8 : matches.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = matches[index];
              final sc = item['scenario'] as Scenario;
              final cat = item['category'] as Category;
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                elevation: 0,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SituationCardScreen(
                          cardId: '${sc.id}_default',
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5A00).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            sc.urgency == 1 ? Icons.warning_rounded : Icons.gavel_rounded,
                            color: sc.urgency == 1 ? const Color(0xFFBA1A1A) : const Color(0xFFFF5A00),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEEEEE),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      cat.label,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF5B4137),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (sc.urgency == 1)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFDAD6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'URGENT',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF93000A),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sc.label,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A1C1C),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sc.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  color: const Color(0xFF5B4137),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF907065)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  /// Procedural Mode Chips Filter (Segmented Flow Selector)
  Widget _buildModeChipsFilter() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildModePill('now', 'Right Now'),
          _buildModePill('prepare', 'Prepare'),
          _buildModePill('after', 'After Event'),
        ],
      ),
    );
  }

  Widget _buildModePill(String modeKey, String label) {
    final isSelected = _selectedMode == modeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMode = modeKey;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF101F18) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF5B4137),
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }

  /// Scenario Section Header
  Widget _buildScenarioGridHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _selectedMode == 'prepare'
              ? 'PREVENTATIVE SAFEGUARDS'
              : _selectedMode == 'after'
                  ? 'POST-INCIDENT REMEDIES'
                  : 'SELECT SCENARIO',
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF5B4137),
            letterSpacing: 1.4,
          ),
        ),
        Text(
          'CrPC & BNS Verified',
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFA83900),
          ),
        ),
      ],
    );
  }

  /// 2-Column Grid of 6 Situation Cards matching exact mode
  Widget _buildScenarioGrid() {
    if (_selectedMode == 'prepare') {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSituationCard(
                  title: 'Contract Check',
                  description: 'Exit bonds, non-competes & notice period traps.',
                  badgeText: 'BOND CHECK',
                  badgeBg: const Color(0xFFFFDBCF),
                  badgeTextCol: const Color(0xFF802900),
                  footerText: 'SEC 27 CONTRACT',
                  footerCol: const Color(0xFFA83900),
                  svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                    <path d="M14 2H6C4.9 2 4 2.9 4 4V20C4 21.1 4.9 22 6 22H18C19.1 22 20 21.1 20 20V8L14 2Z" fill="#101F18"/>
                    <path d="M14 2V8H20" fill="#FF5A00"/>
                  </svg>''',
                  onTap: () => _openSituationList(searchQuery: 'contract'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSituationCard(
                  title: 'Tenant Shield',
                  description: 'Model Tenancy rules, deposit cap & wear/tear.',
                  badgeText: 'RENT ACT',
                  badgeBg: const Color(0xFFD5E7DC),
                  badgeTextCol: const Color(0xFF3B4A42),
                  footerText: 'DEPOSIT RULES',
                  footerCol: const Color(0xFF526259),
                  svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                    <path d="M12 2L2 9L5 11V20C5 20.5 5.5 21 6 21H18C18.5 21 19 20.5 19 20V11L22 9L12 2Z" fill="#101F18"/>
                    <path d="M10 21V12C10 10.9 10.9 10 12 10C13.1 10 14 10.9 14 12V21H10Z" fill="#FF5A00"/>
                  </svg>''',
                  onTap: () => _openSituationList(searchQuery: 'deposit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSituationCard(
                  title: 'Vehicle Rights',
                  description: '11-month out-of-state rule & BH series norms.',
                  badgeText: 'MV ACT',
                  badgeBg: const Color(0xFFE8E8E8),
                  badgeTextCol: const Color(0xFF5B4137),
                  footerText: 'SEC 47 MV ACT',
                  footerCol: const Color(0xFFA83900),
                  svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                    <rect fill="#101F18" height="11" rx="2" width="18" x="3" y="9"/>
                    <circle cx="7" cy="18" fill="#FF5A00" r="2.5"/>
                    <circle cx="17" cy="18" fill="#FF5A00" r="2.5"/>
                  </svg>''',
                  onTap: () => _openSituationList(searchQuery: 'interstate'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSituationCard(
                  title: 'Fee Refund',
                  description: 'Mandatory 100% college fee refund timelines.',
                  badgeText: 'UGC NORMS',
                  badgeBg: const Color(0xFFFFDAD6),
                  badgeTextCol: const Color(0xFF93000A),
                  footerText: '15-DAY MANDATE',
                  footerCol: const Color(0xFFA83900),
                  svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                    <path d="M3 6L12 2L21 6L12 10L3 6Z" fill="#FF5A00"/>
                    <path d="M3 8V16L12 20L21 16V8L12 12L3 8Z" fill="#101F18"/>
                  </svg>''',
                  onTap: () => _openSituationList(searchQuery: 'fee refund'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSituationCard(
                  title: 'RTI Filing',
                  description: 'Demand delayed government files & exam sheets.',
                  badgeText: 'RTI 2005',
                  badgeBg: const Color(0xFFD5E7DC),
                  badgeTextCol: const Color(0xFF3B4A42),
                  footerText: '30-DAY DISPOSAL',
                  footerCol: const Color(0xFF526259),
                  svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="12" fill="#101F18" r="10"/>
                    <path d="M12 8V12L15 15" stroke="#FF5A00" stroke-width="2"/>
                  </svg>''',
                  onTap: () => _openSituationList(searchQuery: 'rti'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSituationCard(
                  title: 'What to Sign',
                  description: 'What to inspect before signing police/legal forms.',
                  badgeText: 'SAFE SIGN',
                  badgeBg: const Color(0xFFE8E8E8),
                  badgeTextCol: const Color(0xFF5B4137),
                  footerText: 'ART. 20(3) SAFE',
                  footerCol: const Color(0xFFA83900),
                  svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                    <path d="M3 17.25V21H6.75L17.81 9.94L14.06 6.19L3 17.25Z" fill="#101F18"/>
                    <path d="M20.71 7.04C21.1 6.65 21.1 6.02 20.71 5.63L18.37 3.29C17.98 2.9 17.35 2.9 16.96 3.29L15.13 5.12L18.88 8.87L20.71 7.04Z" fill="#FF5A00"/>
                  </svg>''',
                  onTap: () => _openSituationList(searchQuery: 'what to sign'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_selectedMode == 'after') {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSituationCard(
                  title: 'FIR Refused',
                  description: 'Station refusing FIR; Zero FIR & SP petitions.',
                  badgeText: 'ZERO FIR',
                  badgeBg: const Color(0xFFFFDAD6),
                  badgeTextCol: const Color(0xFF93000A),
                  footerText: 'CRPC 154(3)',
                  footerCol: const Color(0xFFA83900),
                  svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                    <path d="M12 2L4 5V11C4 16.5 7.4 21.6 12 23C16.6 21.6 20 16.5 20 11V5L12 2Z" fill="#101F18"/>
                    <path d="M12 8V12M12 16H12.01" stroke="#FF5A00" stroke-width="2" stroke-linecap="round"/>
                  </svg>''',
                  onTap: () => _openSituationList(searchQuery: 'fir refused'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSituationCard(
                  title: 'RERA Delay',
                  description: 'Builder delayed flat possession monthly interest.',
                  badgeText: 'RERA ACT',
                  badgeBg: const Color(0xFFD5E7DC),
                  badgeTextCol: const Color(0xFF3B4A42),
                  footerText: 'SEC 18 RERA',
                  footerCol: const Color(0xFF526259),
                  svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                    <path d="M19 3H5C3.9 3 3 3.9 3 5V19C3 20.1 3.9 21 5 21H19C20.1 21 21 20.1 21 19V5C21 3.9 20.1 3 19 3Z" fill="#101F18"/>
                    <path d="M7 7H17V9H7V7ZM7 11H17V13H7V11ZM7 15H13V17H7V15Z" fill="#FF5A00"/>
                  </svg>''',
                  onTap: () => _openSituationList(searchQuery: 'rera'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSituationCard(
                  title: 'Unpaid Salary',
                  description: 'Salary withheld & FnF delay Labour recovery.',
                  badgeText: 'LABOUR LAW',
                  badgeBg: const Color(0xFFFFDBCF),
                  badgeTextCol: const Color(0xFF802900),
                  footerText: 'WAGES ACT',
                  footerCol: const Color(0xFFA83900),
                  svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                    <rect fill="#101F18" height="14" rx="2" width="20" x="2" y="5"/>
                    <circle cx="12" cy="12" fill="#FF5A00" r="3"/>
                  </svg>''',
                  onTap: () => _openSituationList(searchQuery: 'salary'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSituationCard(
                  title: 'Recovery Agents',
                  description: 'RBI ban on doorstep threats & untimely calls.',
                  badgeText: 'RBI CODE',
                  badgeBg: const Color(0xFFE8E8E8),
                  badgeTextCol: const Color(0xFF5B4137),
                  footerText: 'OMBUDSMAN 14448',
                  footerCol: const Color(0xFFA83900),
                  svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                    <rect fill="#101F18" height="13" rx="3" width="16" x="4" y="9"/>
                    <path d="M8 9V6C8 3.79 9.79 2 12 2C14.21 2 16 3.79 16 6V9" stroke="#FF5A00" stroke-width="2"/>
                  </svg>''',
                  onTap: () => _openSituationList(searchQuery: 'recovery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSituationCard(
                  title: 'Cheque Bounce',
                  description: 'Sec 138 notice reply within 15 statutory days.',
                  badgeText: 'NI ACT 138',
                  badgeBg: const Color(0xFFD5E7DC),
                  badgeTextCol: const Color(0xFF3B4A42),
                  footerText: '15-DAY WINDOW',
                  footerCol: const Color(0xFF526259),
                  svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                    <path d="M14 2H6C4.9 2 4 2.9 4 4V20C4 21.1 4.9 22 6 22H18C19.1 22 20 21.1 20 20V8L14 2Z" fill="#101F18"/>
                    <path d="M8 12H16M8 16H13" stroke="#FF5A00" stroke-width="2"/>
                  </svg>''',
                  onTap: () => _openSituationList(searchQuery: 'cheque'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSituationCard(
                  title: 'Police Misconduct',
                  description: 'Independent Police Complaints Authority (PCA).',
                  badgeText: 'PCA REFORM',
                  badgeBg: const Color(0xFFFFDAD6),
                  badgeTextCol: const Color(0xFF93000A),
                  footerText: 'SEC 199 BNS',
                  footerCol: const Color(0xFFA83900),
                  svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="12" fill="#101F18" r="10"/>
                    <path d="M12 6V12L16 14" stroke="#FF5A00" stroke-width="2"/>
                  </svg>''',
                  onTap: () => _openSituationList(searchQuery: 'misconduct'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Default 'now' mode
    return Column(
      children: [
        // Row 1: Police & Emergency Healthcare
        Row(
          children: [
            Expanded(
              child: _buildSituationCard(
                title: 'Police & Traffic',
                description: 'Traffic stops, vehicle keys, frisking & 41A notices.',
                badgeText: 'URGENT',
                badgeBg: const Color(0xFFFFDAD6),
                badgeTextCol: const Color(0xFF93000A),
                footerText: 'SECTION 41A',
                footerCol: const Color(0xFFA83900),
                svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                  <path d="M12 2L4 5V11C4 16.5 7.4 21.6 12 23C16.6 21.6 20 16.5 20 11V5L12 2Z" fill="#101F18"/>
                  <path d="M12 4.5L18 7.3V11C18 15 15.4 18.8 12 20.2V4.5Z" fill="#FF5A00"/>
                  <circle cx="12" cy="11" fill="#FFFFFF" r="2.5"/>
                </svg>''',
                onTap: () => _openSituationList(categoryId: 'police_criminal'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSituationCard(
                title: 'Emergency Care',
                description: 'Hospital emergency denial & patient bill hostage.',
                badgeText: 'ARTICLE 21',
                badgeBg: const Color(0xFFFFDAD6),
                badgeTextCol: const Color(0xFF93000A),
                footerText: 'PARMANAND KATARA',
                footerCol: const Color(0xFFA83900),
                svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                  <circle cx="12" cy="12" fill="#101F18" r="10"/>
                  <path d="M12 6V18M6 12H18" stroke="#FF5A00" stroke-width="3" stroke-linecap="round"/>
                </svg>''',
                onTap: () => _openSituationList(searchQuery: 'emergency'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 2: Couples & Online Fraud
        Row(
          children: [
            Expanded(
              child: _buildSituationCard(
                title: 'Couples',
                description:
                    'Hotel check-in rights, park moral policing defense.',
                badgeText: 'PRIVACY',
                badgeBg: const Color(0xFFE8E8E8),
                badgeTextCol: const Color(0xFF5B4137),
                footerText: 'ART. 21 SAFE',
                footerCol: const Color(0xFFA83900),
                svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                  <path d="M12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12C21 16.9706 16.9706 21 12 21Z" fill="#101F18"/>
                  <path d="M12 7C9.79086 7 8 8.79086 8 11C8 12.38 8.7 13.6 9.75 14.32L9 17H15L14.25 14.32C15.3 13.6 16 12.38 16 11C16 8.79086 14.21 7 12 7Z" fill="#FF5A00"/>
                </svg>''',
                onTap: () => _openSituationList(categoryId: 'couples_public'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSituationCard(
                title: 'Online Fraud',
                description:
                    'UPI scams, freeze bank requests, blackmail extortion.',
                badgeText: '1930',
                badgeBg: const Color(0xFFFFDBCF),
                badgeTextCol: const Color(0xFF802900),
                footerText: 'GOLD HOUR',
                footerCol: const Color(0xFFA83900),
                svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                  <rect fill="#101F18" height="13" rx="3" width="16" x="4" y="9"/>
                  <path d="M8 9V6C8 3.79 9.79 2 12 2C14.21 2 16 3.79 16 6V9" stroke="#FF5A00" stroke-linecap="round" stroke-width="2.5"/>
                  <circle cx="12" cy="15" fill="#FF5A00" r="2"/>
                </svg>''',
                onTap: () => _openSituationList(categoryId: 'online_money'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 3: Workplace & Housing
        Row(
          children: [
            Expanded(
              child: _buildSituationCard(
                title: 'Workplace',
                description:
                    'Salary withholding, instant firing, harassment relief.',
                badgeText: 'POSH',
                badgeBg: const Color(0xFFD5E7DC),
                badgeTextCol: const Color(0xFF3B4A42),
                footerText: 'NOTICE RULES',
                footerCol: const Color(0xFF526259),
                svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                  <path d="M4 7C4 5.89543 4.89543 5 6 5H18C19.1046 5 20 5.89543 20 7V19C20 20.1046 19.1046 21 18 21H6C4.89543 21 4 20.1046 4 19V7Z" fill="#101F18"/>
                  <path d="M9 5V3C9 2.44772 9.44772 2 10 2H14C14.5523 2 15 2.44772 15 3V5" stroke="#FF5A00" stroke-width="2"/>
                  <path d="M4 11H20" stroke="#FF5A00" stroke-width="2"/>
                </svg>''',
                onTap: () =>
                    _openSituationList(categoryId: 'work'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSituationCard(
                title: 'Housing',
                description:
                    'Illegal eviction, withholding deposit, electric cuts.',
                badgeText: 'TENANCY',
                badgeBg: const Color(0xFFE8E8E8),
                badgeTextCol: const Color(0xFF5B4137),
                footerText: 'RENT ACT',
                footerCol: const Color(0xFFA83900),
                svgIcon: '''<svg viewBox="0 0 24 24" fill="none">
                  <path d="M12 2L2 9L5 11V20C5 20.5523 5.44772 21 6 21H18C18.5523 21 19 20.5523 19 20V11L22 9L12 2Z" fill="#101F18"/>
                  <path d="M10 21V12C10 10.8954 10.8954 10 12 10C13.1046 10 14 10.8954 14 12V21H10Z" fill="#FF5A00"/>
                </svg>''',
                onTap: () => _openSituationList(categoryId: 'housing'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSituationCard({
    required String title,
    required String description,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextCol,
    required String footerText,
    required Color footerCol,
    required String svgIcon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Icon + Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(7),
                      child: SvgPicture.string(svgIcon),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.montserrat(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: badgeTextCol,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title & Subtitle
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF5B4137),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),

                // Footer: Tag + Arrow Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      footerText,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: footerCol,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFF101F18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Interactive Quick Rights Highlight (DK Basu Verdict)
  Widget _buildDkBasuCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Orange Decorative Peeking Circle
          Positioned(
            right: -24,
            bottom: -24,
            child: Container(
              width: 86,
              height: 86,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5A00),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openSituationList(
                  categoryId: 'police_criminal', searchQuery: 'arrest'),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD5E7DC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'DK BASU VERDICT',
                              style: GoogleFonts.montserrat(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF3B4A42),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Arrested or Detained?',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1C1C),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Learn your 11 inviolable rights under Supreme Court guidelines.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF5B4137),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Circular Menu Book Button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF101F18),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive Architectural Showcase Banner for the Framer-motion style gallery
  Widget _buildVisualGalleryBanner() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E4EB), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF5A00).withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5A00).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFFF5A00).withValues(alpha: 0.30),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          'FEATURED SHOWCASE',
                          style: GoogleFonts.montserrat(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: const Color(0xFFFF5A00),
                          ),
                        ),
                      ),
                      const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFF5A00), size: 16),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'VISUAL PROTOCOL GALLERY',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF17261F),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Glide through real statutory defense scenarios with architectural visuals & horizontal scroll motion.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CivicScrollGalleryScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5A00),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'LAUNCH HORIZONTAL GALLERY',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Offline Assurance Guarantee Badge
  Widget _buildOfflineGuaranteeBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF059669),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Works 100% Offline • Zero Data Leaves Device',
              style: GoogleFonts.montserrat(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5B4137),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter for ambient dashed constructivist decorative circle
class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF5A00).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * 3.1415926535 * radius;
    final count = (circumference / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < count; i++) {
      final startAngle = (i * (dashWidth + dashSpace) / circumference) * 2 * 3.1415926535;
      final sweepAngle = (dashWidth / circumference) * 2 * 3.1415926535;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // Accent orange dot
    final dotPaint = Paint()..color = const Color(0xFFFF5A00);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.24), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
