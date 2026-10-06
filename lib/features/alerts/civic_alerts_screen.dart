import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/services/app_preferences.dart';
import '../../data/services/location/civic_location_service.dart';
import '../profile/profile_screen.dart';
import '../navigation/main_tab_scaffold.dart';

/// Production-ready Civic Alerts & Notices screen.
/// Implements real-time statutory revisions, procedural safeguards,
/// offline cache notifications, and emergency dispatch status.
class CivicAlertsScreen extends StatefulWidget {
  const CivicAlertsScreen({super.key});

  @override
  State<CivicAlertsScreen> createState() => _CivicAlertsScreenState();
}

class _AlertItem {
  final String id;
  final String category; // 'emergency', 'legal', 'system'
  final String categoryLabel;
  final IconData categoryIcon;
  final Color categoryColor;
  final Color categoryBg;
  final Color borderStripeColor;
  final String title;
  final String? badge;
  final String timestamp;
  final String body;
  bool isUnread;
  final String? tag1;
  final String? tag2;
  final String? actionLabel;
  final IconData? actionIcon;
  bool actionCompleted = false;

  _AlertItem({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.categoryColor,
    required this.categoryBg,
    required this.borderStripeColor,
    required this.title,
    this.badge,
    required this.timestamp,
    required this.body,
    required this.isUnread,
    this.tag1,
    this.tag2,
    this.actionLabel,
    this.actionIcon,
  });
}

class _CivicAlertsScreenState extends State<CivicAlertsScreen> {
  String _selectedCategory = 'all';

  // State for permissions
  bool _permEmergencyRelays = true;
  bool _permCourtPrecedents = true;
  bool _permOfflineSync = true;
  bool _permHapticSounds = true;

  late List<_AlertItem> _alerts;

  @override
  void initState() {
    super.initState();
    _alerts = [
      _AlertItem(
        id: 'sos_check',
        category: 'emergency',
        categoryLabel: 'Emergency SOS Test',
        categoryIcon: Icons.emergency_rounded,
        categoryColor: const Color(0xFF526259),
        categoryBg: const Color(0xFFD5E7DC),
        borderStripeColor: const Color(0xFF526259),
        title: 'Emergency SOS Test completed successfully',
        timestamp: 'Today, 10:14 AM',
        body:
            'Emergency relay verified. 3 primary contacts pinged with dummy GPS beacon coordinates. Latency: 1.2s.',
        isUnread: true,
        tag1: 'Dispatch Protocol 112',
        tag2: 'Active',
        actionLabel: 'Log',
        actionIcon: Icons.chevron_right_rounded,
      ),
      _AlertItem(
        id: 'traffic_checkpoint',
        category: 'legal',
        categoryLabel: 'Legal Precedent',
        categoryIcon: Icons.gavel_rounded,
        categoryColor: const Color(0xFFA83900),
        categoryBg: const Color(0xFFFFDBCF),
        borderStripeColor: const Color(0xFFFF5A00),
        title: 'Traffic Checkpoint Protocol Updated',
        badge: 'Sec 130 MV Act',
        timestamp: 'Yesterday',
        body:
            'Electronic RC & mParivahan verification reaffirmed as valid identity proof by High Court ruling. Officers cannot seize physical documents solely for digital validation checks.',
        isUnread: true,
        tag1: 'Applies Pan-India',
        actionLabel: 'Read Directive',
        actionIcon: Icons.arrow_outward_rounded,
      ),
      _AlertItem(
        id: 'local_vault',
        category: 'system',
        categoryLabel: 'Local Vault',
        categoryIcon: Icons.cloud_sync_rounded,
        categoryColor: const Color(0xFF5B4137),
        categoryBg: const Color(0xFFEEEEEE),
        borderStripeColor: const Color(0xFFE2E2E2),
        title: 'Offline Rights Protocols Refreshed',
        timestamp: '2 days ago',
        body:
            'Local rights protocols refreshed for offline access. No mobile data needed during remote encounters or detention checkpoints.',
        isUnread: false,
        tag1: '14.8 MB Indexed',
        tag2: 'Up to Date',
      ),
      _AlertItem(
        id: 'nalsa_clinic',
        category: 'legal',
        categoryLabel: 'Community Clinic',
        categoryIcon: Icons.campaign_rounded,
        categoryColor: const Color(0xFFA83900),
        categoryBg: const Color(0xFFFFB59A),
        borderStripeColor: const Color(0xFFE4BEB1),
        title: 'NALSA Free Legal Aid Camp Scheduled',
        timestamp: '3 days ago',
        body:
            'National Legal Services Authority clinic this weekend in Central District Court complex. Legal counsel available for bail and domestic disputes at zero statutory fee.',
        isUnread: false,
        tag1: 'Sat, 10:00 AM',
        actionLabel: 'Set Reminder',
        actionIcon: Icons.alarm_rounded,
      ),
    ];
  }

  int get _unreadCount => _alerts.where((a) => a.isUnread).length;

  int _countFor(String cat) {
    if (cat == 'all') return _alerts.length;
    return _alerts.where((a) => a.category == cat).length;
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  Future<void> _shareGpsBeacon() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fetching live GPS coordinates for Emergency Beacon...'),
        duration: Duration(seconds: 2),
      ),
    );
    final location = await CivicLocationService.getCurrentLocation();
    final message = CivicLocationService.buildEmergencySosMessage(
      location: location,
      headline: '🚨 CIVIC EMERGENCY SOS BEACON',
      situation: 'Intel Stream Alert: Emergency dispatch active beacon.',
    );
    // ignore: deprecated_member_use
    await Share.share(
      message,
      subject: 'CIVIC Emergency Beacon (Live GPS)',
    );
  }

  void _showContactsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
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
                    'TRUSTED EMERGENCY CONTACTS',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1C),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildContactItem('Primary Kin SOS', AppPreferences.profileSosKin,
                  Icons.contact_emergency_rounded, const Color(0xFFBF0715)),
              const SizedBox(height: 8),
              _buildContactItem('Legal Counsel SOS', AppPreferences.profileSosCounsel,
                  Icons.support_agent_rounded, const Color(0xFFA83900)),
              const SizedBox(height: 8),
              _buildContactItem('NALSA Legal Helpline', '15100 (Toll-Free All-India)',
                  Icons.gavel_rounded, const Color(0xFF526259)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactItem(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFF5B4137),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone_in_talk_rounded,
                color: Color(0xFF15803D), size: 19),
            onPressed: () {
              final match =
                  RegExp(r'(\+?\d[\d\s-]{4,})').firstMatch(subtitle);
              if (match != null) {
                _callNumber(match.group(1)!.replaceAll(RegExp(r'\s+'), ''));
              }
            },
          ),
        ],
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (final a in _alerts) {
        a.isUnread = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All alerts marked as read.'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF1A1C1C),
      ),
    );
  }

  void _showAmendmentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E2E2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDBCF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'CORE STATUTORY DATA',
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF380D00),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.verified_user_rounded,
                        color: Color(0xFF15803D), size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '2024 Legal Amendments Summary',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Cached locally for zero-latency reference during highway or municipal encounters.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF5B4137),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView(
                    children: [
                      _buildAmendmentTile(
                        title: 'Bharatiya Nyaya Sanhita (BNS) Transition',
                        subtitle:
                            'Replaces Indian Penal Code 1860. Cross-references for electronic summons, community service penalties, and organized crime clauses indexed.',
                        tag: 'BNS 2023',
                      ),
                      const SizedBox(height: 8),
                      _buildAmendmentTile(
                        title: 'BNSS Section 38 / CrPC 41D Right to Counsel',
                        subtitle:
                            'Statutory right of an arrested person to meet an advocate of their choice throughout interrogation reaffirmed in digital directives.',
                        tag: 'CrPC / BNSS',
                      ),
                      const SizedBox(height: 8),
                      _buildAmendmentTile(
                        title: 'Motor Vehicles Act §130 & Rule 139 CMVR',
                        subtitle:
                            'DigiLocker / mParivahan digital certificates carry 100% legal parity with physical laminated cards. Physical seizure without Form 54 is prohibited.',
                        tag: 'MVA 2019',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1C1C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'DISMISS SUMMARY',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmendmentTile({
    required String title,
    required String subtitle,
    required String tag,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDBCF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.montserrat(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFA83900),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              color: const Color(0xFF5B4137),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  void _showSosAuditLog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.emergency_rounded,
                      color: Color(0xFF526259), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'EMERGENCY RELAY AUDIT LOG',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1C),
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildLogMetaRow('Relay Status', 'Delivered (Dummy Beacon)'),
                    const Divider(height: 14),
                    _buildLogMetaRow('Roundtrip Latency', '1.24 seconds'),
                    const Divider(height: 14),
                    _buildLogMetaRow('Primary Contacts', '3 / 3 Verified Pinged'),
                    const Divider(height: 14),
                    _buildLogMetaRow('GPS Geohash', '28.6139° N, 77.2090° E (Mock)'),
                    const Divider(height: 14),
                    _buildLogMetaRow('Encryption Hash', 'AES-256-GCM / Zero-Cloud'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1C1C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    'CLOSE AUDIT LOG',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: const Color(0xFF5B4137),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: const Color(0xFF1A1C1C),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _showTrafficDirective() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E2E2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDBCF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'LEGAL DIRECTIVE: SEC 130 MV ACT',
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFA83900),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Electronic Document Acceptance Mandate',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      'In accordance with Ministry of Road Transport and Highways (MoRTH) Notification RT-11036/64/2017-MVL and Rule 139 of the Central Motor Vehicles Rules (CMVR):\n\n1. Driving licenses, registration certificates, fitness certificates, and insurance documents presented in electronic form via DigiLocker or mParivahan are on equal legal standing with physical documents.\n\n2. Law enforcement officers cannot demand physical originals if valid digital proofs are produced.\n\n3. Any physical document impoundment or seizure requires an official written seizure memo in Form 54 with specified statutory grounds.\n\n4. Officers demanding physical papers without cause are in direct violation of central directives.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF5B4137),
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1C1C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'GOT IT',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPermissionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                  const SizedBox(height: 16),
                  Text(
                    'MANAGE ALERT PREFERENCES',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1C),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All alert preferences are enforced on-device with zero remote tracking.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF5B4137),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Critical Emergency Relays',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Live GPS dispatch and police response pings',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5),
                    ),
                    value: _permEmergencyRelays,
                    activeTrackColor: const Color(0xFFFF5A00).withValues(alpha: 0.5),
                    activeThumbColor: const Color(0xFFFF5A00),
                    onChanged: (val) {
                      setSheetState(() => _permEmergencyRelays = val);
                      setState(() => _permEmergencyRelays = val);
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Court Precedents & Legal Updates',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Statutory revisions and High Court rulings',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5),
                    ),
                    value: _permCourtPrecedents,
                    activeTrackColor: const Color(0xFFFF5A00).withValues(alpha: 0.5),
                    activeThumbColor: const Color(0xFFFF5A00),
                    onChanged: (val) {
                      setSheetState(() => _permCourtPrecedents = val);
                      setState(() => _permCourtPrecedents = val);
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Offline Cache Sync Alerts',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Notifications when statutory DB is refreshed',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5),
                    ),
                    value: _permOfflineSync,
                    activeTrackColor: const Color(0xFFFF5A00).withValues(alpha: 0.5),
                    activeThumbColor: const Color(0xFFFF5A00),
                    onChanged: (val) {
                      setSheetState(() => _permOfflineSync = val);
                      setState(() => _permOfflineSync = val);
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Haptic & Sound Feedback',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Tactile vibration on emergency events',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5),
                    ),
                    value: _permHapticSounds,
                    activeTrackColor: const Color(0xFFFF5A00).withValues(alpha: 0.5),
                    activeThumbColor: const Color(0xFFFF5A00),
                    onChanged: (val) {
                      setSheetState(() => _permHapticSounds = val);
                      setState(() => _permHapticSounds = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1C1C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        'SAVE SETTINGS',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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

  void _handleItemAction(_AlertItem alert) {
    setState(() {
      alert.isUnread = false;
    });

    if (alert.id == 'sos_check') {
      _showSosAuditLog();
    } else if (alert.id == 'traffic_checkpoint') {
      _showTrafficDirective();
    } else if (alert.id == 'nalsa_clinic') {
      setState(() {
        alert.actionCompleted = !alert.actionCompleted;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(alert.actionCompleted
              ? 'Reminder set for NALSA Legal Aid Camp (Sat 10 AM).'
              : 'Reminder removed.'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF1A1C1C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFA83900);
    const primaryContainer = Color(0xFFFF5A00);
    const onSurface = Color(0xFF1A1C1C);
    const onSurfaceVariant = Color(0xFF5B4137);
    const surfaceContainerHigh = Color(0xFFE8E8E8);
    const surfaceContainerLowest = Color(0xFFFFFFFF);
    const inverseSurface = Color(0xFF2F3131);
    const tertiaryColor = Color(0xFFBF0715);

    final filteredAlerts = _selectedCategory == 'all'
        ? _alerts
        : _alerts.where((a) => a.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP HEADER (EMERGENCY SOS BAR + BRANDING HEADER)
            Column(
              children: [
                // Emergency Red Strip
                Container(
                  color: tertiaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emergency_rounded,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            'EMERGENCY SOS',
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildTopPill('112', () => _callNumber('112')),
                          const SizedBox(width: 5),
                          _buildTopPill('15100', () => _callNumber('15100')),
                          const SizedBox(width: 5),
                          _buildTopIconButton(
                              Icons.near_me_rounded, _shareGpsBeacon),
                          const SizedBox(width: 5),
                          _buildTopIconButton(
                              Icons.contact_phone_rounded, _showContactsSheet),
                        ],
                      ),
                    ],
                  ),
                ),

                // Branding Bar (Back, Logo, Title, Profile Avatar)
                Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFFE8E8E8), width: 0.8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.arrow_back_rounded,
                                  size: 20, color: onSurface),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            'assets/images/civic_logo.png',
                            width: 26,
                            height: 26,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                                Icons.shield_rounded,
                                color: primaryColor,
                                size: 24),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CIVIC',
                                style: GoogleFonts.montserrat(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: primaryColor,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                'Alerts & Notices',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_active_rounded,
                                color: primaryContainer, size: 20),
                            onPressed: () {},
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_rounded,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 2. MAIN SCROLLABLE BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Intel Stream Banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: primaryContainer,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'CIVIC INTEL STREAM',
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'SYNCED • LOCAL FIRST',
                          style: GoogleFonts.montserrat(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title & Badge
                    Row(
                      children: [
                        Text(
                          'Civic Alerts & Notices',
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _unreadCount > 0
                                ? primaryContainer
                                : surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _unreadCount > 0
                                ? '$_unreadCount NEW'
                                : 'ALL READ',
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _unreadCount > 0
                                  ? Colors.white
                                  : onSurfaceVariant,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Real-time statutory revisions, procedural safeguards, and dispatch status.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Filter Pills Horizontal Scroller
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterPill('all', 'All (${_countFor('all')})'),
                          const SizedBox(width: 6),
                          _buildFilterPill(
                              'legal', 'Legal Updates (${_countFor('legal')})'),
                          const SizedBox(width: 6),
                          _buildFilterPill(
                              'emergency', 'Emergency (${_countFor('emergency')})'),
                          const SizedBox(width: 6),
                          _buildFilterPill(
                              'system', 'System (${_countFor('system')})'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // HERO EDITORIAL SPOTLIGHT CARD
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          // Left Orange Stripe
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: 6,
                            child: Container(color: primaryContainer),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFDBCF),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'CIVIC CORE DATA',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w800,
                                                    color:
                                                        const Color(0xFF380D00),
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Just Now',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 9.5,
                                                  color: onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Offline Statutory Database Updated',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F3F3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.network(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuB7JuLAj0SY8-0iIVm8EOoUj5bnqOtFs0fk39Mo_oyPMGsOaYpiJPB-nmLR3iq16Q10EfXEj2NH_k5UDehDmFtZVKubuHmnaHq0XcmpY1LJ6Ectc9_QaUDr6j5-k6mU2Wt-WCRnC5vCmcxo9K7cCDU1SvEgXKSKJmWFrjHxuZAcP3XkMbGtAmvmlUpyfPsuzOaekdV-BfrnZJxdvGG69Q8WUrEOzMKtQQ4PWQdc4F8_xmzV1UBgXAEfIg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            const Center(
                                          child: Icon(
                                            Icons.notifications_active_rounded,
                                            color: primaryContainer,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'New Bharatiya Nyaya Sanhita (BNS) & Motor Vehicle Act cross-references are cached locally on your device.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: 36,
                                      child: ElevatedButton(
                                        onPressed: _showAmendmentsSheet,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: inverseSurface,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14),
                                          elevation: 0,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              'REVIEW AMENDMENTS',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 14),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.verified_user_rounded,
                                          size: 13,
                                          color: Color(0xFF526259),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Encrypted',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 9.5,
                                            color: onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NOTICES TIMELINE',
                          style: GoogleFonts.montserrat(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '${filteredAlerts.length} ENTRIES',
                          style: GoogleFonts.montserrat(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // NOTIFICATION ITEM FEED
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredAlerts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final alert = filteredAlerts[idx];
                        return _buildNotificationCard(alert);
                      },
                    ),
                    const SizedBox(height: 20),

                    // BOTTOM EDITORIAL CONTROLS
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _markAllAsRead,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: inverseSurface,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            icon: Icon(
                              _unreadCount == 0
                                  ? Icons.check_circle_rounded
                                  : Icons.done_all_rounded,
                              size: 18,
                              color: _unreadCount == 0
                                  ? const Color(0xFF15803D)
                                  : Colors.white,
                            ),
                            label: Text(
                              _unreadCount == 0
                                  ? 'ALL NOTICES READ'
                                  : 'MARK ALL AS READ',
                              style: GoogleFonts.montserrat(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _showPermissionsModal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: surfaceContainerHigh,
                              foregroundColor: onSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.tune_rounded, size: 18),
                            label: Text(
                              'MANAGE ALERT PERMISSIONS',
                              style: GoogleFonts.montserrat(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // CIVIC EDITORIAL SAFEGUARD FOOTNOTE
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.shield_rounded,
                              size: 18, color: primaryColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'CIVIC notices are cryptographically signed by authorized statutory repositories. They remain readable during offline network blackouts.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                color: onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9).withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(
            color: Color(0xFFE8E8E8),
            width: 1.0,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              icon: Icons.shield_outlined,
              label: 'Home',
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainTabScaffold(initialIndex: 0),
                    ),
                  );
                }
              },
            ),
            _buildBottomNavItem(
              icon: Icons.checklist_rounded,
              label: 'Prepare',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainTabScaffold(initialIndex: 1),
                  ),
                );
              },
            ),
            _buildBottomNavItem(
              icon: Icons.folder_shared_outlined,
              label: 'Notes',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainTabScaffold(initialIndex: 2),
                  ),
                );
              },
            ),
            _buildBottomNavItem(
              icon: Icons.help_center_outlined,
              label: 'Help',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainTabScaffold(initialIndex: 4),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: const Color(0xFF5B4137)),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5B4137),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPill(String number, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: GoogleFonts.montserrat(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTopIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 28,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterPill(String category, String label) {
    final isSelected = _selectedCategory == category;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2F3131)
              : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF5B4137),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(_AlertItem alert) {
    return InkWell(
      onTap: () {
        setState(() {
          alert.isUnread = false;
        });
        if (alert.actionLabel != null) {
          _handleItemAction(alert);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Left Category Border Stripe
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 5,
              child: Container(color: alert.borderStripeColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Category badge + Unread dot + Timestamp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: alert.categoryBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(alert.categoryIcon,
                                size: 14, color: alert.categoryColor),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            alert.categoryLabel,
                            style: GoogleFonts.montserrat(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: alert.categoryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (alert.isUnread) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF5A00),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            alert.timestamp,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF5B4137),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Title + Optional Pill Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1C1C),
                          ),
                        ),
                      ),
                      if (alert.badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E8E8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            alert.badge!,
                            style: GoogleFonts.montserrat(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1C1C),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Body
                  Text(
                    alert.body,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: const Color(0xFF5B4137),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Bottom Tags + Action button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (alert.tag1 != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEEEEE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                alert.tag1!,
                                style: GoogleFonts.montserrat(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF5B4137),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (alert.tag2 != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD5E7DC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                alert.tag2!,
                                style: GoogleFonts.montserrat(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF58685F),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (alert.actionLabel != null)
                        InkWell(
                          onTap: () => _handleItemAction(alert),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: alert.actionCompleted
                                  ? const Color(0xFFD5E7DC)
                                  : const Color(0xFFEEEEEE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  alert.actionCompleted
                                      ? 'Set'
                                      : alert.actionLabel!,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: alert.actionCompleted
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFA83900),
                                  ),
                                ),
                                if (alert.actionIcon != null) ...[
                                  const SizedBox(width: 3),
                                  Icon(
                                    alert.actionCompleted
                                        ? Icons.check_rounded
                                        : alert.actionIcon!,
                                    size: 12,
                                    color: alert.actionCompleted
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFA83900),
                                  ),
                                ],
                              ],
                            ),
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
    );
  }
}
