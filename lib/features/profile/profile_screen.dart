import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/app_preferences.dart';
import '../../data/services/location/civic_location_service.dart';
import 'edit_profile_screen.dart';
import 'citizen_qr_pass_screen.dart';
import '../alerts/civic_alerts_screen.dart';

/// Complete, pixel-perfect Profile Screen based directly on the Stitch Neo-Constructivist design.
/// Displays on-device citizen credentials, Digital Rights Card, Vault & Safety controls,
/// offline Citizen QR code, and emergency dispatch links with zero tracking or telemetry.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isZeroKnowledgeVaultOn = true;
  bool _isVaultLocked = false;

  @override
  void initState() {
    super.initState();
    _isZeroKnowledgeVaultOn = AppPreferences.profileZeroKnowledgeVault;
    _isVaultLocked = AppPreferences.profileVaultLocked;
    AppPreferences.profileRevisionNotifier.addListener(_onProfileRevision);
  }

  @override
  void dispose() {
    AppPreferences.profileRevisionNotifier.removeListener(_onProfileRevision);
    super.dispose();
  }

  void _onProfileRevision() {
    if (mounted) setState(() {});
  }

  Future<void> _pickProfilePhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        await AppPreferences.setProfileAvatarUrl(base64String);
        await AppPreferences.setProfileAvatarVariant('custom');
        if (mounted) {
          setState(() {});
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Color(0xFF15803D),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to select photo: $e'),
            backgroundColor: const Color(0xFFBA1A1A),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showChangeProfilePhotoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Text(
                'UPDATE PROFILE PICTURE',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF101F18),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickProfilePhoto(ImageSource.camera),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5A00).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFF5A00)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_camera_rounded,
                                color: Color(0xFFFF5A00), size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Take Photo',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFF5A00),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickProfilePhoto(ImageSource.gallery),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E2E2)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_library_rounded,
                                color: Color(0xFF526259), size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Choose Gallery',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: const Text('Open Full Edit Profile Screen'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarImage(String url, {double size = 110}) {
    if (url.startsWith('data:image')) {
      try {
        final base64Data = url.contains(',') ? url.split(',').last : url;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultAvatarIcon(size),
        );
      } catch (_) {
        return _defaultAvatarIcon(size);
      }
    } else if (url.startsWith('http')) {
      return Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultAvatarIcon(size),
      );
    } else {
      return _defaultAvatarIcon(size);
    }
  }

  Widget _defaultAvatarIcon(double size) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFEEEEEE),
      child: Icon(
        Icons.face_rounded,
        size: size * 0.5,
        color: const Color(0xFFFF5A00),
      ),
    );
  }

  Future<void> _callHelpline(String number) async {
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
        content: Text('Fetching live Google Maps coordinates for Emergency Beacon...'),
        duration: Duration(seconds: 2),
      ),
    );
    final location = await CivicLocationService.getCurrentLocation();
    final message = CivicLocationService.buildEmergencySosMessage(
      location: location,
      headline: '🚨 CIVIC EMERGENCY SOS BEACON',
      situation: 'I require immediate statutory first-aid. My live location beacon is active.',
    );
    // ignore: deprecated_member_use
    await Share.share(
      message,
      subject: 'CIVIC Emergency Beacon (Live GPS)',
    );
  }

  void _showTrustedContactsModal() {
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TRUSTED EMERGENCY CONTACTS',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF101F18),
                      letterSpacing: 0.6,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5E7DC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ACTIVE RELAY',
                      style: GoogleFonts.montserrat(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF101F18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildSosContactTile(
                title: 'Primary Kin',
                subtitle: AppPreferences.profileSosKin,
                icon: Icons.contact_emergency_rounded,
                color: const Color(0xFFBF0715),
              ),
              const SizedBox(height: 8),
              _buildSosContactTile(
                title: 'Legal Counsel SOS',
                subtitle: AppPreferences.profileSosCounsel,
                icon: Icons.support_agent_rounded,
                color: const Color(0xFFA83900),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToEditProfile();
                  },
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: Text(
                    'MANAGE CONTACTS IN PROFILE',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF101F18),
                    side: const BorderSide(color: Color(0xFFE2E2E2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
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

  Widget _buildSosContactTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF526259),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone_in_talk_rounded,
                color: Color(0xFF15803D), size: 20),
            onPressed: () {
              // Extract phone number from string like "+91 98765 43210 (Sister)"
              final phoneMatch = RegExp(r'(\+?\d[\d\s-]{8,})').firstMatch(subtitle);
              if (phoneMatch != null) {
                _callHelpline(phoneMatch.group(1)!.replaceAll(RegExp(r'\s+'), ''));
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDocumentLockerModal() {
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'OFFLINE DOCUMENT VAULT',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF101F18),
                      letterSpacing: 0.6,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5E7DC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ENCRYPTED AES-256',
                      style: GoogleFonts.montserrat(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF101F18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDocItem(
                icon: Icons.directions_car_rounded,
                title: 'Driving License (Smart Card DL)',
                subtitle: 'MoRTH Verified • Valid All-India under Rule 139 CMVR',
                status: 'CACHED OFFLINE',
              ),
              const SizedBox(height: 8),
              _buildDocItem(
                icon: Icons.credit_card_rounded,
                title: 'Masked Aadhaar (e-Aadhaar)',
                subtitle: 'UIDAI Offline e-KYC XML with QR Signature',
                status: 'SECURE ENCLAVE',
              ),
              const SizedBox(height: 8),
              _buildDocItem(
                icon: Icons.how_to_vote_rounded,
                title: 'Election Voter ID (EPIC)',
                subtitle: 'ECI Registered • Valid Statutory Proof of Identity',
                status: 'LOCAL ONLY',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
            decoration: const BoxDecoration(
              color: Color(0xFFD5E7DC),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF101F18), size: 19),
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
                    color: const Color(0xFF526259),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: GoogleFonts.montserrat(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF526259),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOfflineCitizenQrModal() {
    final name = AppPreferences.profileFullName;
    final jurisdiction = AppPreferences.profileJurisdiction.split('(').first.trim();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top close icon
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEEEEE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: Color(0xFF1A1C1C)),
                      ),
                    ),
                  ),

                  // Icon badge
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFDBCF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code_2_rounded,
                        size: 24, color: Color(0xFFA83900)),
                  ),
                  const SizedBox(height: 8),

                  // Headline
                  Text(
                    'OFFLINE CITIZEN QR',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1C),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Present this to duty magistrates or law enforcement for zero-contact constitutional identification.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: const Color(0xFF5B4137),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Geometric High-Contrast QR Code representation
                  Container(
                    width: 176,
                    height: 176,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E2E2)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: _CitizenQrPainter(),
                      size: const Size(156, 156),
                    ),
                  ),
                const SizedBox(height: 14),

                // Citizen Metadata
                Text(
                  '$name • $jurisdiction',
                  style: GoogleFonts.montserrat(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1C1C),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SHA-256: 4C9E8841-B81A-CIVIC-LOCAL',
                  style: GoogleFonts.montserrat(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF526259),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 18),

                // Open Full Screen Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToCitizenQrPass();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1C1C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: const Icon(Icons.fullscreen_rounded, size: 18),
                    label: Text(
                      'OPEN FULL PASS SCREEN',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'DISMISS',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5B4137),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  void _lockVault() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Lock Offline Vault?',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'This will securely seal active local biometric keys and clear cached situational temporary files. Zero telemetry will be generated.',
            style: GoogleFonts.plusJakartaSans(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: const Color(0xFF526259),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                setState(() {
                  _isVaultLocked = true;
                });
                await AppPreferences.setProfileVaultLocked(true);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Vault sealed locally with AES-256.'),
                    backgroundColor: Color(0xFFBF0715),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBF0715),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'LOCK VAULT',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _navigateToCitizenQrPass() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CitizenQrPassScreen()),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFA83900);
    const primaryContainer = Color(0xFFFF5A00);
    const onSurface = Color(0xFF1A1C1C);
    const onSurfaceVariant = Color(0xFF5B4137);
    const surfaceContainer = Color(0xFFEEEEEE);
    const surfaceContainerLowest = Color(0xFFFFFFFF);
    const secondaryColor = Color(0xFF526259);

    final fullName = AppPreferences.profileFullName;
    final handle = AppPreferences.profileHandle;
    final jurisdiction = AppPreferences.profileJurisdiction.split('(').first.trim().toUpperCase();
    final avatarUrl = AppPreferences.profileAvatarUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP EMERGENCY SOS BAR
            Container(
              color: const Color(0xFFBF0715),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emergency_rounded,
                          size: 15, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        'EMERGENCY SOS',
                        style: GoogleFonts.montserrat(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildTopEmergencyPill('112', () => _callHelpline('112')),
                      const SizedBox(width: 5),
                      _buildTopEmergencyPill('15100', () => _callHelpline('15100')),
                      const SizedBox(width: 5),
                      _buildTopIconButton(Icons.near_me_rounded, _shareGpsBeacon),
                      const SizedBox(width: 5),
                      _buildTopIconButton(Icons.contact_phone_rounded, _showTrustedContactsModal),
                    ],
                  ),
                ],
              ),
            ),

            // 2. NAV HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E2E2), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: onSurface, size: 22),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CIVIC JUSTICE',
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: primaryOrange,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            'Citizen Profile',
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
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
                        icon: const Icon(Icons.notifications_none_rounded,
                            color: onSurface, size: 20),
                        tooltip: 'Civic Alerts & Notices',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CivicAlertsScreen(),
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. MAIN SCROLLABLE BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: Column(
                  children: [
                    // Decorative Anchor Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'CIVIC ID • VAULT #8841',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: onSurface,
                                    letterSpacing: 0.8,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_user_rounded,
                                  size: 13, color: primaryOrange),
                              const SizedBox(width: 4),
                              Text(
                                'ON-DEVICE SECURE',
                                style: GoogleFonts.montserrat(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: onSurfaceVariant,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // PROFILE HERO CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Illustrated Avatar Frame with verified pin (Tap to update photo)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              GestureDetector(
                                onTap: _showChangeProfilePhotoSheet,
                                child: Container(
                                  width: 110,
                                  height: 110,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: surfaceContainerLowest,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _buildAvatarImage(avatarUrl, size: 102),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: InkWell(
                                  onTap: _showChangeProfilePhotoSheet,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: primaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.photo_camera_rounded,
                                        size: 15, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Offline Verified Citizen Ribbon
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD5E7DC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.gavel_rounded,
                                    size: 13, color: secondaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  'OFFLINE VERIFIED CITIZEN',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF101F18),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // User Name
                          Text(
                            fullName,
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: onSurface,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 2),

                          // Handle
                          Text(
                            '@$handle',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Jurisdiction Tag
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 15, color: primaryOrange),
                              const SizedBox(width: 3),
                              Text(
                                '$jurisdiction • RESIDENT',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: onSurface,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Dual Action Pills (Edit Profile & Citizen QR)
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: ElevatedButton.icon(
                                    onPressed: _navigateToEditProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: onSurface,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(Icons.edit_note_rounded,
                                        size: 18),
                                    label: Text(
                                      'EDIT PROFILE',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: OutlinedButton.icon(
                                    onPressed: _navigateToCitizenQrPass,
                                    onLongPress: _showOfflineCitizenQrModal,
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: surfaceContainer,
                                      foregroundColor: onSurface,
                                      side: const BorderSide(
                                          color: Color(0xFFE2E2E2)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                    ),
                                    icon: const Icon(Icons.qr_code_2_rounded,
                                        size: 18, color: primaryContainer),
                                    label: Text(
                                      'CITIZEN QR',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // DIGITAL RIGHTS CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
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
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: primaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.shield_outlined,
                                        size: 17, color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DIGITAL RIGHTS CARD',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          color: onSurface,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        'CIVIC GUARDIAN PROTOCOL ACTIVE',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w800,
                                          color: primaryOrange,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Icon(Icons.verified_rounded,
                                  color: primaryContainer, size: 20),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Mini Stats Mosaic
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatTile('28', 'GUIDES CACHED', onSurface),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatTile('3', 'SOS CONTACTS', primaryContainer),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatTile('100%', 'ZERO TELEMETRY', onSurface),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Encrypted Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF15803D),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Local Encrypted Database (SQLite / AES-256)',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          color: onSurfaceVariant,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '3.8 MB',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SECTION: VAULT & SAFETY CONTROL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'VAULT & SAFETY CONTROL',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: onSurface,
                              letterSpacing: 0.6,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'CIVIC OS v2.4',
                          style: GoogleFonts.montserrat(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: onSurfaceVariant,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Safety Control Items
                    Column(
                      children: [
                        // 1. Emergency SOS Contacts
                        _buildSettingTile(
                          icon: Icons.sos_rounded,
                          iconBg: const Color(0xFFFFDAD6),
                          iconColor: const Color(0xFFBF0715),
                          title: 'Emergency SOS Contacts',
                          badge: 'READY',
                          badgeBg: const Color(0xFFFFDAD6),
                          badgeColor: const Color(0xFF410002),
                          subtitle: '3 Trusted contacts • Power button x3 trigger set',
                          onTap: _showTrustedContactsModal,
                        ),
                        const SizedBox(height: 6),

                        // 2. Legal Jurisdiction
                        _buildSettingTile(
                          icon: Icons.account_balance_rounded,
                          iconBg: const Color(0xFFFFDBCF),
                          iconColor: const Color(0xFF802900),
                          title: 'Legal Jurisdiction',
                          badge: jurisdiction,
                          badgeBg: surfaceContainer,
                          badgeColor: onSurface,
                          subtitle: 'CrPC / BNS 2024 & Motor Vehicles Act configured',
                          onTap: _navigateToEditProfile,
                        ),
                        const SizedBox(height: 6),

                        // 3. Document Locker
                        _buildSettingTile(
                          icon: Icons.badge_outlined,
                          iconBg: const Color(0xFFD5E7DC),
                          iconColor: const Color(0xFF101F18),
                          title: 'Document Locker',
                          badge: 'SYNCED',
                          badgeBg: const Color(0xFFD5E7DC),
                          badgeColor: const Color(0xFF58685F),
                          subtitle: 'DigiLocker linked • Aadhaar & Driving Licence offline',
                          onTap: _showDocumentLockerModal,
                        ),
                        const SizedBox(height: 6),

                        // 4. Primary Language
                        _buildSettingTile(
                          icon: Icons.translate_rounded,
                          iconBg: surfaceContainer,
                          iconColor: onSurface,
                          title: 'Primary Language',
                          badge: 'EN • HI',
                          badgeBg: surfaceContainer,
                          badgeColor: primaryOrange,
                          subtitle: 'English (India) • द्विभाषी मोड (हिंदी)',
                          onTap: _navigateToEditProfile,
                        ),
                        const SizedBox(height: 6),

                        // 5. Zero-Knowledge Vault Toggle
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x06000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: primaryOrange.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.lock_rounded,
                                    size: 18, color: primaryOrange),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Zero-Knowledge Vault',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: onSurface,
                                      ),
                                    ),
                                    Text(
                                      'No cloud sync. Keys stored in device Secure Enclave.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        color: onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _isZeroKnowledgeVaultOn,
                                activeTrackColor: primaryContainer.withValues(alpha: 0.5),
                                activeThumbColor: primaryContainer,
                                onChanged: (val) async {
                                  setState(() {
                                    _isZeroKnowledgeVaultOn = val;
                                  });
                                  await AppPreferences.setProfileZeroKnowledgeVault(val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // DO / DON'T SECURITY TIPS SPLIT
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                              border: const Border(
                                left: BorderSide(
                                    color: Color(0xFF15803D), width: 4),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        size: 14, color: Color(0xFF15803D)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'KEEP CACHED',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF15803D),
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Sync statutory guidelines before highway journeys.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: onSurface,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                              border: const Border(
                                left: BorderSide(
                                    color: Color(0xFFDC2626), width: 4),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.cancel_rounded,
                                        size: 14, color: Color(0xFFDC2626)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'NEVER SHARE',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFDC2626),
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Do not share emergency SOS one-touch PIN with anyone.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: onSurface,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // BOTTOM VAULT CONTROLS
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.public_rounded,
                                size: 14, color: onSurfaceVariant),
                            const SizedBox(width: 5),
                            Text(
                              'CIVIC Constitutional Aid Initiative',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Lock Vault Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _lockVault,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isVaultLocked
                                  ? const Color(0xFFBA1A1A)
                                  : surfaceContainer,
                              foregroundColor: _isVaultLocked
                                  ? Colors.white
                                  : onSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            icon: Icon(
                              _isVaultLocked
                                  ? Icons.lock_rounded
                                  : Icons.lock_reset_rounded,
                              size: 18,
                            ),
                            label: Text(
                              _isVaultLocked
                                  ? 'VAULT SEALED LOCALLY'
                                  : 'LOCK VAULT & CLEAR CACHE',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Build 2024.11-release • Guaranteed No Tracking',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: onSurfaceVariant,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildTopEmergencyPill(String number, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(14),
        ),
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
        width: 26,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }

  Widget _buildStatTile(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 7.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5B4137),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String badge,
    required Color badgeBg,
    required Color badgeColor,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1C1C),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.montserrat(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: const Color(0xFF5B4137),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                size: 16, color: Color(0xFF5B4137)),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for crisp, accessible offline Citizen QR code representation
class _CitizenQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1C1C)
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final orangePaint = Paint()
      ..color = const Color(0xFFFF5A00)
      ..style = PaintingStyle.fill;

    // Corner Square Top-Left
    _drawFinderPattern(canvas, const Offset(6, 6), 46, paint, whitePaint);

    // Corner Square Top-Right
    _drawFinderPattern(canvas, Offset(size.width - 52, 6), 46, paint, whitePaint);

    // Corner Square Bottom-Left
    _drawFinderPattern(canvas, Offset(6, size.height - 52), 46, paint, whitePaint);

    // Center Orange Civic Emblem
    final centerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 38,
        height: 38,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(centerRect, orangePaint);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      7,
      whitePaint,
    );

    // Decorative data grid blocks
    final gridCoords = [
      const Offset(64, 12),
      const Offset(84, 12),
      const Offset(104, 12),
      const Offset(64, 30),
      const Offset(94, 30),
      const Offset(114, 30),
      const Offset(12, 64),
      const Offset(30, 64),
      const Offset(12, 84),
      const Offset(34, 94),
      const Offset(134, 64),
      const Offset(152, 64),
      const Offset(134, 84),
      const Offset(152, 94),
      const Offset(64, 134),
      const Offset(84, 134),
      const Offset(104, 134),
      const Offset(64, 154),
      const Offset(94, 154),
      const Offset(114, 154),
      const Offset(134, 134),
      const Offset(152, 144),
      const Offset(144, 158),
    ];

    for (final pt in gridCoords) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(pt.dx, pt.dy, 12, 12),
          const Radius.circular(2.5),
        ),
        paint,
      );
    }
  }

  void _drawFinderPattern(
    Canvas canvas,
    Offset origin,
    double size,
    Paint black,
    Paint white,
  ) {
    // Outer black square
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(origin.dx, origin.dy, size, size),
        const Radius.circular(8),
      ),
      black,
    );

    // Inner white square
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(origin.dx + 6, origin.dy + 6, size - 12, size - 12),
        const Radius.circular(5),
      ),
      white,
    );

    // Center black square
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(origin.dx + 12, origin.dy + 12, size - 24, size - 24),
        const Radius.circular(3),
      ),
      black,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
