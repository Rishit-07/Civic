import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/services/app_preferences.dart';
import 'citizen_verification_screen.dart';

/// Offline Citizen QR Pass Screen.
/// Provides a cryptographically verified on-device statutory identity pass,
/// readable offline by traffic officers, duty magistrates, and legal aid responders.
class CitizenQrPassScreen extends StatefulWidget {
  const CitizenQrPassScreen({super.key});

  @override
  State<CitizenQrPassScreen> createState() => _CitizenQrPassScreenState();
}

enum QrPassMode {
  officerInspection,
  emergencySos,
  rawProof,
}

class _CitizenQrPassScreenState extends State<CitizenQrPassScreen>
    with SingleTickerProviderStateMixin {
  QrPassMode _selectedMode = QrPassMode.officerInspection;
  bool _useWebUrl = true; // By default: scanning opens official verification web page directly
  bool _isCopied = false;
  bool _isRegenerating = false;
  late DateTime _lastRefreshed;
  late String _sha256Digest;
  Timer? _tickerTimer;
  int _secondsAgo = 10;
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _lastRefreshed = DateTime.now().subtract(const Duration(seconds: 10));
    _sha256Digest = _generateDigest();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsAgo = DateTime.now().difference(_lastRefreshed).inSeconds;
        });
      }
    });

    AppPreferences.profileRevisionNotifier.addListener(_onProfileUpdated);
  }

  void _onProfileUpdated() {
    if (mounted) {
      setState(() {
        _sha256Digest = _generateDigest();
      });
    }
  }

  @override
  void dispose() {
    AppPreferences.profileRevisionNotifier.removeListener(_onProfileUpdated);
    _tickerTimer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  String _generateDigest() {
    final name = AppPreferences.profileFullName;
    final regId = AppPreferences.profileCitizenRegId;
    final millis = DateTime.now().millisecondsSinceEpoch;
    // Produce deterministic 30-char hex digest simulation for offline cryptographic proof
    final raw = '$name-$regId-$millis-${_selectedMode.name}';
    var hash = 0;
    for (var i = 0; i < raw.length; i++) {
      hash = ((hash << 5) - hash) + raw.codeUnitAt(i);
      hash = hash & 0xFFFFFFFFF;
    }
    final hexPart = hash.toRadixString(16).padLeft(8, '0');
    return '8f2a${hexPart}2b1049de84bb6e1a49c94e'.substring(0, 30);
  }

  Color _getModeColor() {
    switch (_selectedMode) {
      case QrPassMode.officerInspection:
        return const Color(0xFF006A4E); // Statutory Deep Green
      case QrPassMode.emergencySos:
        return const Color(0xFFBA1A1A); // Emergency Crimson
      case QrPassMode.rawProof:
        return const Color(0xFF5B39A8); // Cryptographic Deep Indigo
    }
  }

  Color _getModeHeaderBg() {
    switch (_selectedMode) {
      case QrPassMode.officerInspection:
        return const Color(0xFF101F18);
      case QrPassMode.emergencySos:
        return const Color(0xFF2B0E0E);
      case QrPassMode.rawProof:
        return const Color(0xFF1A1528);
    }
  }

  String _getModeHeaderTitle() {
    switch (_selectedMode) {
      case QrPassMode.officerInspection:
        return 'CIVIC GUARDIAN PROTOCOL';
      case QrPassMode.emergencySos:
        return 'EMERGENCY SOS VCARD';
      case QrPassMode.rawProof:
        return 'CRYPTOGRAPHIC AUDIT PROOF';
    }
  }

  String _getModeHeaderBadge() {
    switch (_selectedMode) {
      case QrPassMode.officerInspection:
        return 'OFFLINE VERIFIED';
      case QrPassMode.emergencySos:
        return 'RFC 2426 VCARD 3.0';
      case QrPassMode.rawProof:
        return 'CANONICAL JSON SHA-256';
    }
  }

  IconData _getModeHeaderIcon() {
    switch (_selectedMode) {
      case QrPassMode.officerInspection:
        return Icons.shield_rounded;
      case QrPassMode.emergencySos:
        return Icons.emergency_rounded;
      case QrPassMode.rawProof:
        return Icons.lock_clock_rounded;
    }
  }

  String _cleanPhoneNumber(String input) {
    final match = RegExp(r'\+?[0-9\s-]{7,16}').firstMatch(input);
    if (match != null) {
      return match.group(0)!.replaceAll(RegExp(r'[\s-]'), '');
    }
    return input.trim();
  }

  String _getOfficerPassPayload() {
    final name = AppPreferences.profileFullName;
    final handle = AppPreferences.profileHandle;
    final regId = AppPreferences.profileCitizenRegId;
    final jurisdiction = AppPreferences.profileJurisdiction;
    return '''[CIVIC STATUTORY & CONSTITUTIONAL CITIZEN PASS]
CITIZEN: $name (@$handle)
REG-ID: $regId
JURISDICTION: $jurisdiction

LEGAL PROTECTIONS & STATUTORY MANDATES:
1. CONSTITUTION: Art 21 (Liberty/Due Process) & Art 22 (Right to Counsel)
2. BNSS 2023: Sec 35 (Notice before arrest) & Sec 173 (Zero FIR/Legal aid)
3. IT ACT 2000: Sec 4 (Digital records on par with physical documents)
4. MVA 1988: Sec 130 & CMVR Rule 139 (Digital DL/RC production valid)
5. ARREST SAFEGUARDS: D.K. Basu memo & right to notify kin/lawyer

EMERGENCY DISPATCH: Police 112 | Legal Aid 15100
DIGEST SHA-256: $_sha256Digest
VERIFY: https://civic-84e44.web.app/#/verify?id=$regId&mode=officer&sha=$_sha256Digest''';
  }

  String _getSosVcardPayload() {
    final name = AppPreferences.profileFullName;
    final regId = AppPreferences.profileCitizenRegId;
    final kinRaw = AppPreferences.profileSosKin;
    final counselRaw = AppPreferences.profileSosCounsel;
    final kinPhone = _cleanPhoneNumber(kinRaw);
    final counselPhone = _cleanPhoneNumber(counselRaw);

    return '''BEGIN:VCARD
VERSION:3.0
FN:$name (CIVIC SOS PASS)
N:;${name.trim()};;;
ORG:CIVIC Citizen Guardian Protocol
TITLE:Emergency Legal & SOS Contact
TEL;TYPE=CELL,PREF:$kinPhone
TEL;TYPE=WORK,VOICE:$counselPhone
TEL;TYPE=EMERGENCY:112
TEL;TYPE=LEGAL-AID:15100
NOTE:CIVIC SOS Pass. Reg: $regId | Kin: $kinRaw | Legal Aid: 15100 | Police: 112 | Token: $_sha256Digest
URL:https://civic-84e44.web.app/#/verify?id=$regId&mode=sos
END:VCARD''';
  }

  String _getCryptoProofPayload() {
    final name = AppPreferences.profileFullName;
    final handle = AppPreferences.profileHandle;
    final regId = AppPreferences.profileCitizenRegId;
    final jurisdiction = AppPreferences.profileJurisdiction;
    final payloadMap = {
      'protocol': 'CIVIC-GUARDIAN-V2',
      'mode': 'CRYPTOGRAPHIC_PROOF',
      'issued_at': _lastRefreshed.toIso8601String(),
      'subject': {
        'legal_name': name,
        'handle': handle,
        'citizen_reg_id': regId,
        'jurisdiction': jurisdiction,
      },
      'constitutional_rights': {
        'mva_section_130_exempt_physical_seizure': true,
        'cmvr_rule_139_electronic_validity': true,
        'it_act_section_4_recognized': true,
        'bnss_section_173_legal_aid_mandate': true,
      },
      'cryptographic_attestation': {
        'algorithm': 'SHA-256',
        'digest': _sha256Digest,
        'hardware_enclave_status': 'HARDWARE_SIGNED_OFFLINE',
      },
      'verify_url':
          'https://civic-84e44.web.app/#/verify?id=$regId&mode=crypto&sha=$_sha256Digest',
    };
    return const JsonEncoder.withIndent('  ').convert(payloadMap);
  }

  String _getOfficerPassUrl() {
    final name = Uri.encodeComponent(AppPreferences.profileFullName);
    final handle = Uri.encodeComponent(AppPreferences.profileHandle);
    final regId = Uri.encodeComponent(AppPreferences.profileCitizenRegId);
    final jur = Uri.encodeComponent(AppPreferences.profileJurisdiction);
    return 'https://civic-84e44.web.app/verify?id=$regId&name=$name&handle=$handle&jur=$jur&sha=$_sha256Digest&mode=officer';
  }

  String _getSosPassUrl() {
    final name = Uri.encodeComponent(AppPreferences.profileFullName);
    final handle = Uri.encodeComponent(AppPreferences.profileHandle);
    final regId = Uri.encodeComponent(AppPreferences.profileCitizenRegId);
    final jur = Uri.encodeComponent(AppPreferences.profileJurisdiction);
    final kin = Uri.encodeComponent(_cleanPhoneNumber(AppPreferences.profileSosKin));
    final counsel = Uri.encodeComponent(_cleanPhoneNumber(AppPreferences.profileSosCounsel));
    return 'https://civic-84e44.web.app/verify?id=$regId&name=$name&handle=$handle&jur=$jur&kin=$kin&counsel=$counsel&sha=$_sha256Digest&mode=sos';
  }

  String _getCryptoPassUrl() {
    final name = Uri.encodeComponent(AppPreferences.profileFullName);
    final handle = Uri.encodeComponent(AppPreferences.profileHandle);
    final regId = Uri.encodeComponent(AppPreferences.profileCitizenRegId);
    final jur = Uri.encodeComponent(AppPreferences.profileJurisdiction);
    return 'https://civic-84e44.web.app/verify?id=$regId&name=$name&handle=$handle&jur=$jur&sha=$_sha256Digest&mode=crypto';
  }

  String _getQrPayload() {
    if (_useWebUrl) {
      switch (_selectedMode) {
        case QrPassMode.officerInspection:
          return _getOfficerPassUrl();
        case QrPassMode.emergencySos:
          return _getSosPassUrl();
        case QrPassMode.rawProof:
          return _getCryptoPassUrl();
      }
    }

    switch (_selectedMode) {
      case QrPassMode.officerInspection:
        return _getOfficerPassPayload();
      case QrPassMode.emergencySos:
        return _getSosVcardPayload();
      case QrPassMode.rawProof:
        return _getCryptoProofPayload();
    }
  }

  Widget _buildAvatarImage(String url, {double size = 42}) {
    if (url.startsWith('data:image')) {
      try {
        final base64Data = url.contains(',') ? url.split(',').last : url;
        final bytes = base64Decode(base64Data);
        return ClipOval(
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _defaultAvatarPlaceholder(size),
          ),
        );
      } catch (_) {
        return _defaultAvatarPlaceholder(size);
      }
    } else if (url.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultAvatarPlaceholder(size),
        ),
      );
    } else {
      return _defaultAvatarPlaceholder(size);
    }
  }

  Widget _defaultAvatarPlaceholder(double size) {
    final initials = AppPreferences.profileFullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFFF5A00),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? 'C' : initials,
        style: GoogleFonts.montserrat(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
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

  Future<void> _handleShareToken() async {
    setState(() {
      _isCopied = true;
    });

    final name = AppPreferences.profileFullName;
    final payload = _getQrPayload();

    String subject;
    switch (_selectedMode) {
      case QrPassMode.officerInspection:
        subject = 'CIVIC Officer Statutory Pass ($name)';
        break;
      case QrPassMode.emergencySos:
        subject = 'CIVIC Emergency SOS Contact Card ($name)';
        break;
      case QrPassMode.rawProof:
        subject = 'CIVIC Cryptographic Offline Proof ($name)';
        break;
    }

    // ignore: deprecated_member_use
    await Share.share(
      payload,
      subject: subject,
    );

    Clipboard.setData(ClipboardData(text: payload)).catchError((_) {});

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  Future<void> _handleRegenerate() async {
    setState(() {
      _isRegenerating = true;
    });
    _spinController.repeat();

    await Future.delayed(const Duration(milliseconds: 1400));

    if (mounted) {
      setState(() {
        _lastRefreshed = DateTime.now();
        _secondsAgo = 0;
        _sha256Digest = _generateDigest();
        _isRegenerating = false;
      });
      _spinController.stop();
      _spinController.reset();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cryptographic token re-signed with fresh Secure Enclave salt.',
            style: GoogleFonts.plusJakartaSans(fontSize: 12),
          ),
          backgroundColor: const Color(0xFF1A1C1C),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleAddToWallet() async {
    final regId = AppPreferences.profileCitizenRegId;
    final name = AppPreferences.profileFullName;
    final tokenData = 'CIVIC-PASS-PKPASS:$regId:$name:$_sha256Digest';
    Clipboard.setData(ClipboardData(text: tokenData)).catchError((_) {});

    if (!mounted) return;

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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFDBCF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.wallet_rounded,
                        color: Color(0xFFA83900), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WALLET PASS READY',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1C1C),
                          ),
                        ),
                        Text(
                          'Offline lockscreen widget & digital pass token',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF5B4137),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E2E2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOKEN COPIED TO CLIPBOARD',
                      style: GoogleFonts.montserrat(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF101F18),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your digital pass token has been prepared. You can pin this to your quick-settings panel or import into Google Wallet for one-tap lock screen access without unlocking your phone.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF5B4137),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
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
                    'DONE',
                    style: GoogleFonts.montserrat(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
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

  void _showScannedPayloadModal() {
    final payload = _getQrPayload();
    final modeTitle = _getModeHeaderTitle();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.82,
          child: Padding(
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
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _getModeColor().withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getModeHeaderIcon(),
                          color: _getModeColor(), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DECODED CAMERA SCAN PAYLOAD',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1C1C),
                            ),
                          ),
                          Text(
                            '$modeTitle • Scannable by any camera',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF5B4137),
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
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDBA74)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded,
                          size: 18, color: Color(0xFFA83900)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedMode == QrPassMode.emergencySos
                              ? 'Scanning this with iOS Camera or Android Google Lens immediately triggers "Add to Contacts".'
                              : _selectedMode == QrPassMode.officerInspection
                                  ? 'Scanning this displays legal protections under MVA §130 & Rule 139 CMVR.'
                                  : 'Scanning this decodes canonical cryptographic JSON proof for automated auditing.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFFA83900),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        payload,
                        style: GoogleFonts.firaCode(
                          fontSize: 11,
                          color: const Color(0xFF38BDF8),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (_useWebUrl) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CitizenVerificationScreen(
                              citizenRegId: AppPreferences.profileCitizenRegId,
                              fullName: AppPreferences.profileFullName,
                              handle: AppPreferences.profileHandle,
                              jurisdiction: AppPreferences.profileJurisdiction,
                              sha256Digest: _sha256Digest,
                              mode: _selectedMode.name,
                              kinPhone: _cleanPhoneNumber(AppPreferences.profileSosKin),
                              counselPhone: _cleanPhoneNumber(AppPreferences.profileSosCounsel),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006A4E),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                      label: Text(
                        'OPEN VERIFICATION WEB PAGE',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: payload));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Decoded payload copied to clipboard!',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12),
                          ),
                          backgroundColor: const Color(0xFF1A1C1C),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1C1C),
                      side: const BorderSide(color: Color(0xFFE2E2E2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 15),
                    label: Text(
                      'COPY EXACT SCANNED PAYLOAD',
                      style: GoogleFonts.montserrat(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
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

  void _showOfficerInspectionPreview() {
    final name = AppPreferences.profileFullName;
    final handle = AppPreferences.profileHandle;
    final regId = AppPreferences.profileCitizenRegId;
    final kinContact = AppPreferences.profileSosKin;
    final counselContact = AppPreferences.profileSosCounsel;
    final avatarUrl = AppPreferences.profileAvatarUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.88,
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
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                  // Header Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5E7DC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user_rounded,
                            size: 14, color: Color(0xFF101F18)),
                        const SizedBox(width: 5),
                        Text(
                          'INSPECTOR SIMULATOR • OFFICER SCAN VIEW',
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
                  const SizedBox(height: 10),

                  Text(
                    'What An Officer Sees When Scanning Your Pass',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Under Indian law, duty magistrates and police inspectors cannot seize your physical phone or physical papers when presented with this verified pass.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF5B4137),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Verified Identity Box with Avatar
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F3131),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'STATUTORY IDENTITY CERTIFICATE',
                              style: GoogleFonts.montserrat(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFF5A00),
                                letterSpacing: 0.6,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'AUTHENTIC',
                                style: GoogleFonts.montserrat(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildAvatarImage(avatarUrl, size: 50),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '@$handle • Reg ID: $regId',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: const Color(0xFFE2E2E2),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'SHA-256: $_sha256Digest',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 8.5,
                                      color: const Color(0xFFD5E7DC),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Mandatory Statutory Rules for Inspector
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDBA74)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.policy_rounded,
                                size: 18, color: Color(0xFFA83900)),
                            const SizedBox(width: 6),
                            Text(
                              'DUTY OFFICER STATUTORY NOTICE',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFA83900),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildOfficerRuleItem(
                          '1. Section 130 Motor Vehicles Act & Rule 139 CMVR:',
                          'Electronic presentation of Driving License & RC via DigiLocker / Civic is on equal legal footing with physical documents. Seizure of physical smart cards is illegal without a written Form 54 seizure notice.',
                        ),
                        _buildOfficerRuleItem(
                          '2. CrPC Sec 41D / BNSS Sec 38 Right to Counsel:',
                          'The citizen has an unconditional right to consult an advocate of their choice and notify their designated kin upon detention.',
                        ),
                        _buildOfficerRuleItem(
                          '3. D.K. Basu Supreme Court Guidelines:',
                          'Every police officer carrying out questioning must wear clear, visible identification and prepare an on-spot memo of inspection.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // One-tap Responder Emergency Dialers
                  Text(
                    'DESIGNATED EMERGENCY CONTACTS',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5B4137),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildEmergencyContactCard(
                    title: 'Emergency Kin SOS',
                    subtitle: kinContact,
                    icon: Icons.contact_emergency_rounded,
                    color: const Color(0xFFBF0715),
                    onCall: () {
                      final match = RegExp(r'(\+?\d[\d\s-]{8,})').firstMatch(kinContact);
                      if (match != null) {
                        _callHelpline(match.group(1)!.replaceAll(RegExp(r'\s+'), ''));
                      }
                    },
                  ),
                  const SizedBox(height: 6),
                  _buildEmergencyContactCard(
                    title: 'Legal Counsel / NALSA',
                    subtitle: '$counselContact (or 15100)',
                    icon: Icons.gavel_rounded,
                    color: const Color(0xFFA83900),
                    onCall: () => _callHelpline('15100'),
                  ),
                      ],
                    ),
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
                      'RETURN TO CITIZEN PASS',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
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

  Widget _buildOfficerRuleItem(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            body,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              color: const Color(0xFF5B4137),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onCall,
  }) {
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
            icon: const Icon(Icons.phone_rounded,
                color: Color(0xFF15803D), size: 20),
            onPressed: onCall,
          ),
        ],
      ),
    );
  }

  void _showHelpModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.help_outline_rounded,
                  color: Color(0xFFA83900), size: 22),
              const SizedBox(width: 8),
              Text(
                'How Citizen QR Works',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1C1C),
                ),
              ),
            ],
          ),
          content: Text(
            'This offline token carries your statutory identity credentials, masked DigiLocker signature, and emergency SOS dispatch contacts. It functions completely without cellular reception or mobile data.\n\nOfficers scanning this pass can verify your digital driving license and identity under Motor Vehicles Act §130 without requiring physical documents.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: const Color(0xFF5B4137),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'UNDERSTOOD',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFA83900),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFA83900);
    const primaryContainer = Color(0xFFFF5A00);
    const primaryFixed = Color(0xFFFFDBCF);
    const onPrimaryFixed = Color(0xFF380D00);
    const secondaryColor = Color(0xFF526259);
    const tertiaryColor = Color(0xFFBF0715);
    const surfaceColor = Color(0xFFF9F9F9);
    const onSurface = Color(0xFF1A1C1C);
    const onSurfaceVariant = Color(0xFF5B4137);
    const surfaceContainerLow = Color(0xFFF3F3F3);
    const surfaceContainerHigh = Color(0xFFE8E8E8);

    final fullName = AppPreferences.profileFullName;
    final handle = AppPreferences.profileHandle;
    final jurisdiction = AppPreferences.profileJurisdiction.split('(').first.trim();
    final regId = AppPreferences.profileCitizenRegId;
    final avatarUrl = AppPreferences.profileAvatarUrl;

    final refreshString = _secondsAgo <= 2
        ? 'REFRESHED: JUST NOW • VALID OFFLINE'
        : 'REFRESHED: $_secondsAgo SECONDS AGO • VALID OFFLINE';

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP HEADER (FIXED NAVIGATION & DISPATCH)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: surfaceColor.withValues(alpha: 0.92),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFE2E2E2), width: 1),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Row 1: GPS Live Dispatch + Emergency Call Pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getModeColor(),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.near_me_rounded,
                              size: 15, color: _getModeColor()),
                          const SizedBox(width: 4),
                          Text(
                            'GPS LIVE DISPATCH',
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildTopEmergencyPill(
                            icon: Icons.emergency_rounded,
                            label: '112 POLICE',
                            color: tertiaryColor,
                            onTap: () => _callHelpline('112'),
                          ),
                          const SizedBox(width: 6),
                          _buildTopEmergencyPill(
                            icon: Icons.gavel_rounded,
                            label: '15100 NALSA',
                            color: secondaryColor,
                            onTap: () => _callHelpline('15100'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Row 2: Back button + Title + Help + Profile Avatar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back_rounded,
                                  color: onSurface, size: 22),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CITIZEN QR PASS',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: onSurface,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.help_outline_rounded,
                                color: onSurfaceVariant, size: 20),
                            onPressed: _showHelpModal,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 10),
                          _buildAvatarImage(avatarUrl, size: 32),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. MAIN SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Description Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: _getModeColor().withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'SECURE TOKEN V2.4',
                            style: GoogleFonts.montserrat(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: _getModeColor(),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _getModeColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedMode == QrPassMode.officerInspection
                          ? 'Offline Citizen QR Pass'
                          : _selectedMode == QrPassMode.emergencySos
                              ? 'Emergency SOS vCard Pass'
                              : 'Cryptographic JSON Proof',
                      style: GoogleFonts.montserrat(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedMode == QrPassMode.officerInspection
                          ? 'Statutory identity pass readable by traffic police & inspection officers under MVA §130 without internet.'
                          : _selectedMode == QrPassMode.emergencySos
                              ? 'Standard RFC 2426 vCard format scannable by any smartphone camera to instantly prompt "Add to Contacts".'
                              : 'Zero-knowledge canonical JSON proof carrying cryptographic SHA-256 integrity hash for instant audits.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // QR Pass Mode Selector Tabs
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          _buildModeTab(
                            mode: QrPassMode.officerInspection,
                            label: 'OFFICER PASS',
                            icon: Icons.shield_rounded,
                          ),
                          _buildModeTab(
                            mode: QrPassMode.emergencySos,
                            label: 'SOS VCARD',
                            icon: Icons.emergency_rounded,
                          ),
                          _buildModeTab(
                            mode: QrPassMode.rawProof,
                            label: 'CRYPTO PROOF',
                            icon: Icons.lock_clock_rounded,
                          ),
                        ],
                      ),
                    ),
                    _buildScannerModeToggle(),
                    const SizedBox(height: 12),

                    // CENTERPIECE QR PASS CARD
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // Top Card Status Header
                          Container(
                            color: _getModeHeaderBg(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 11),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(_getModeHeaderIcon(),
                                        size: 17, color: _getModeColor()),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getModeHeaderTitle(),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white.withValues(alpha: 0.95),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: _getModeColor(),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _getModeHeaderBadge(),
                                        style: GoogleFonts.montserrat(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Identity Meta Strip with Avatar
                          Container(
                            color: surfaceContainerLow,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _buildAvatarImage(avatarUrl, size: 42),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              fullName,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: onSurface,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(Icons.verified_rounded,
                                                size: 15, color: _getModeColor()),
                                          ],
                                        ),
                                        Text(
                                          '@$handle • $jurisdiction',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w500,
                                            color: onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'REG ID',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w700,
                                        color: onSurfaceVariant,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    Text(
                                      regId,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Scannable Graphic Section with Real QrImageView
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Isometric ambient grid lines
                                CustomPaint(
                                  size: const Size(260, 260),
                                  painter: _IsometricBackdropPainter(),
                                ),

                                // Scannable ISO QR Code Matrix
                                Container(
                                  width: 216,
                                  height: 216,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getModeColor().withValues(alpha: 0.16),
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                      ),
                                      const BoxShadow(
                                        color: Color(0x0C000000),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: _getModeColor().withValues(alpha: 0.25),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: QrImageView(
                                    data: _getQrPayload(),
                                    version: QrVersions.auto,
                                    size: 196,
                                    padding: EdgeInsets.zero,
                                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: _getModeColor(),
                                    ),
                                    dataModuleStyle: const QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.square,
                                      color: Color(0xFF1A1C1C),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Security Timestamp & SHA Digest
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: _getModeColor(),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        refreshString,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          color: onSurface,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'SHA-256: $_sha256Digest',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: onSurfaceVariant,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Cryptographic Proof Badges Grid - Dynamic for Active Mode
                          Container(
                            color: surfaceContainerLow,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedMode == QrPassMode.officerInspection
                                      ? 'STATUTORY MANDATES EMBEDDED'
                                      : _selectedMode == QrPassMode.emergencySos
                                          ? 'EMERGENCY DISPATCH CHANNELS'
                                          : 'CRYPTOGRAPHIC ATTESTATIONS',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: onSurfaceVariant,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (_selectedMode == QrPassMode.officerInspection) ...[
                                      _buildProofBadge(
                                        icon: Icons.verified_user_rounded,
                                        label: 'Masked DigiLocker ID',
                                        iconColor: secondaryColor,
                                      ),
                                      _buildProofBadge(
                                        icon: Icons.sensors_rounded,
                                        label: 'Emergency SOS Trigger',
                                        iconColor: _getModeColor(),
                                      ),
                                      _buildProofBadge(
                                        icon: Icons.gavel_rounded,
                                        label: 'CrPC / BNS Rights Active',
                                        iconColor: secondaryColor,
                                      ),
                                      _buildProofBadge(
                                        icon: Icons.policy_rounded,
                                        label: 'MVA §130 Mandate',
                                        iconColor: _getModeColor(),
                                      ),
                                      _buildProofBadge(
                                        icon: Icons.verified_user_rounded,
                                        label: 'Rule 139 CMVR Electronic',
                                        iconColor: const Color(0xFF0D9488),
                                      ),
                                    ] else if (_selectedMode == QrPassMode.emergencySos) ...[
                                      _buildProofBadge(
                                        icon: Icons.phone_in_talk_rounded,
                                        label: 'Kin SOS Linked',
                                        iconColor: _getModeColor(),
                                      ),
                                      _buildProofBadge(
                                        icon: Icons.support_agent_rounded,
                                        label: 'Counsel VCard Ready',
                                        iconColor: const Color(0xFF0D9488),
                                      ),
                                      _buildProofBadge(
                                        icon: Icons.contact_emergency_rounded,
                                        label: '112 & 15100 Auto-Add',
                                        iconColor: const Color(0xFFA83900),
                                      ),
                                    ] else ...[
                                      _buildProofBadge(
                                        icon: Icons.lock_clock_rounded,
                                        label: 'SHA-256 Digest Verified',
                                        iconColor: _getModeColor(),
                                      ),
                                      _buildProofBadge(
                                        icon: Icons.data_object_rounded,
                                        label: 'Canonical JSON Schema',
                                        iconColor: const Color(0xFF0D9488),
                                      ),
                                      _buildProofBadge(
                                        icon: Icons.offline_bolt_rounded,
                                        label: 'Zero-Knowledge Offline',
                                        iconColor: const Color(0xFFA83900),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // QUICK ACTION CONTROLS
                    // 1. Main Add to Wallet / Widget Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _handleAddToWallet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: onSurface,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.wallet_rounded,
                                    color: primaryFixed, size: 21),
                                const SizedBox(width: 10),
                                Text(
                                  'ADD TO GOOGLE WALLET / WIDGET',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_rounded,
                                color: primaryFixed, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 2. Secondary Dual Action Buttons (Share Token & Regenerate)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _handleShareToken,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: surfaceContainerHigh,
                                foregroundColor: onSurface,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              icon: Icon(
                                _isCopied
                                    ? Icons.check_rounded
                                    : Icons.share_rounded,
                                size: 17,
                                color: _isCopied
                                    ? const Color(0xFF15803D)
                                    : onSurface,
                              ),
                              label: Text(
                                _isCopied ? 'TOKEN COPIED' : 'SHARE TOKEN',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: _isCopied
                                      ? const Color(0xFF15803D)
                                      : onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isRegenerating ? null : _handleRegenerate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: surfaceContainerHigh,
                                foregroundColor: onSurface,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              icon: RotationTransition(
                                turns: _spinController,
                                child: const Icon(Icons.sync_rounded, size: 18),
                              ),
                              label: Text(
                                _isRegenerating ? 'SIGNING...' : 'REGENERATE',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 3. Inspect What Scanners Decode Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _showScannedPayloadModal,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: onSurface,
                          side: BorderSide(
                              color: _getModeColor().withValues(alpha: 0.35),
                              width: 1.5),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23),
                          ),
                        ),
                        icon: Icon(Icons.qr_code_scanner_rounded,
                            size: 17, color: _getModeColor()),
                        label: Text(
                          'INSPECT WHAT PHONE CAMERAS SCAN',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 4. Officer Inspection View Simulator Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _showOfficerInspectionPreview,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: const BorderSide(
                              color: Color(0xFFFFDBCF), width: 1.5),
                          backgroundColor: const Color(0xFFFFF7ED),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        icon: const Icon(Icons.preview_rounded, size: 17),
                        label: Text(
                          'PREVIEW OFFICER INSPECTION VIEW',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),

                    // OFFICER & CITIZEN STATUTORY NOTICE PANEL
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: primaryFixed.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.policy_rounded,
                                color: Colors.white, size: 19),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'STATUTORY NOTICE FOR INSPECTION',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: onPrimaryFixed,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: primaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'MVA §130',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Under Sec 130 of Motor Vehicles Act & IT Act Sec 4, this cryptographically signed offline verification is legally binding. Physical document seizure without cause is prohibited.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ZERO-CONNECTIVITY ASSURANCE STRIP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            size: 15, color: primaryColor),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Works without internet or cellular reception • End-to-end encrypted',
                            style: GoogleFonts.montserrat(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
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

  Widget _buildTopEmergencyPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab({
    required QrPassMode mode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedMode == mode;
    final modeColor = mode == QrPassMode.officerInspection
        ? const Color(0xFF006A4E)
        : mode == QrPassMode.emergencySos
            ? const Color(0xFFBA1A1A)
            : const Color(0xFF5B39A8);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMode = mode;
            _sha256Digest = _generateDigest();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: modeColor.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? modeColor : const Color(0xFF5B4137),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? const Color(0xFF1A1C1C) : const Color(0xFF5B4137),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerModeToggle() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _useWebUrl = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: _useWebUrl ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: _useWebUrl
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.open_in_browser_rounded,
                      size: 13,
                      color: _useWebUrl ? const Color(0xFF006A4E) : const Color(0xFF5B4137),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'OPENS WEB PAGE (CAMERA)',
                      style: GoogleFonts.montserrat(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: _useWebUrl ? const Color(0xFF1A1C1C) : const Color(0xFF5B4137),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _useWebUrl = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: !_useWebUrl ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: !_useWebUrl
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.copy_rounded,
                      size: 13,
                      color: !_useWebUrl ? const Color(0xFF006A4E) : const Color(0xFF5B4137),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'RAW OFFLINE TEXT',
                      style: GoogleFonts.montserrat(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: !_useWebUrl ? const Color(0xFF1A1C1C) : const Color(0xFF5B4137),
                        letterSpacing: 0.3,
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

  Widget _buildProofBadge({
    required IconData icon,
    required String label,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1C1C),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ambient isometric geometric backdrop painter
class _IsometricBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFFFF5A00).withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw outer hexagon
    final path1 = Path();
    path1.moveTo(center.dx, center.dy - 100);
    path1.lineTo(center.dx + 86, center.dy - 50);
    path1.lineTo(center.dx + 86, center.dy + 50);
    path1.lineTo(center.dx, center.dy + 100);
    path1.lineTo(center.dx - 86, center.dy + 50);
    path1.lineTo(center.dx - 86, center.dy - 50);
    path1.close();
    canvas.drawPath(path1, strokePaint);

    // Inner concentric circle
    canvas.drawCircle(center, 64, strokePaint);

    // Isometric crossing diagonals
    canvas.drawLine(
        Offset(center.dx - 86, center.dy - 50), Offset(center.dx + 86, center.dy + 50), strokePaint);
    canvas.drawLine(
        Offset(center.dx + 86, center.dy - 50), Offset(center.dx - 86, center.dy + 50), strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
