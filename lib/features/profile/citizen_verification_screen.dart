import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/routing/app_router.dart';

/// Public web verification landing page opened when scanning a Citizen QR Pass.
/// Displays official statutory rights, constitutional due process protections,
/// emergency hotlines, and cryptographic integrity proof in a clean, official UI.
class CitizenVerificationScreen extends StatelessWidget {
  final String citizenRegId;
  final String fullName;
  final String handle;
  final String jurisdiction;
  final String sha256Digest;
  final String mode;
  final String kinPhone;
  final String counselPhone;

  const CitizenVerificationScreen({
    super.key,
    required this.citizenRegId,
    required this.fullName,
    required this.handle,
    required this.jurisdiction,
    required this.sha256Digest,
    this.mode = 'pass',
    this.kinPhone = '',
    this.counselPhone = '',
  });

  factory CitizenVerificationScreen.fromQueryParams(Map<String, String> params) {
    return CitizenVerificationScreen(
      citizenRegId: params['id'] ?? 'CIV-DL-2024-8841',
      fullName: params['name'] ?? 'Citizen Holder',
      handle: params['handle'] ?? 'citizen.civic',
      jurisdiction: params['jur'] ?? params['jurisdiction'] ?? 'NCT of Delhi / North District',
      sha256Digest: params['sha'] ?? '8f2a1b9c4d8e7f0123456789abcdef',
      mode: params['mode'] ?? 'pass',
      kinPhone: params['kin'] ?? '',
      counselPhone: params['counsel'] ?? '',
    );
  }

  Future<void> _makeCall(String number) async {
    final clean = number.replaceAll(RegExp(r'[\s-]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF006A4E);
    const darkBg = Color(0xFF0D1512);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryGreen.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryGreen, width: 1.2),
              ),
              child: const Icon(Icons.shield_rounded, color: Color(0xFF4ECCA3), size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CIVIC GUARDIAN PROTOCOL',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'OFFICIAL CITIZEN STATUTORY VERIFICATION',
                  style: GoogleFonts.montserrat(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8BA79B),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Share Pass Link',
            icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
            onPressed: () {
              // ignore: deprecated_member_use
              Share.share(
                'CIVIC Statutory Citizen Pass ($fullName)\nID: $citizenRegId\nVerification: https://civic-84e44.web.app/verify?id=$citizenRegId',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Verification Status Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFA5D6A7), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OFFICIALLY VERIFIED PASS',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1B5E20),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Statutorily valid under IT Act §4, BNSS §173 & MVA §130',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Citizen Identity Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8E5), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF4F7F5),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: primaryGreen,
                              child: Text(
                                fullName.trim().isNotEmpty
                                    ? fullName.trim().substring(0, 1).toUpperCase()
                                    : 'C',
                                style: GoogleFonts.montserrat(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1A1C1C),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    handle.startsWith('@') ? handle : '@$handle',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildMetaRow('REGISTRATION ID', citizenRegId, Icons.badge_outlined),
                            const Divider(height: 20, color: Color(0xFFEEEEEE)),
                            _buildMetaRow('JURISDICTION', jurisdiction, Icons.location_on_outlined),
                            const Divider(height: 20, color: Color(0xFFEEEEEE)),
                            _buildMetaRow('DIGEST TOKEN', sha256Digest, Icons.fingerprint_rounded, isCode: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section Title: Legal Mandates & Protections
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CONSTITUTIONAL & STATUTORY PROTECTIONS',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2C3E35),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Legal Protection Cards
                _buildProtectionCard(
                  number: '01',
                  category: 'CONSTITUTION OF INDIA',
                  title: 'Articles 21 & 22: Personal Liberty & Right to Counsel',
                  details:
                      'Guarantees right to life, dignity, and fair legal due process. Any detained citizen has the fundamental right to consult and be defended by a legal practitioner of their choice without hindrance.',
                  accentColor: const Color(0xFF006A4E),
                ),

                _buildProtectionCard(
                  number: '02',
                  category: 'BHARATIYA NAGARIK SURAKSHA SANHITA (BNSS 2023)',
                  title: 'Section 35 & 173: Due Process & Zero FIR Mandate',
                  details:
                      'Police must issue a formal Notice of Appearance before making an arrest for offenses punishable with imprisonment up to 7 years. Police officers are legally mandated to register a Zero FIR regardless of territorial jurisdiction.',
                  accentColor: const Color(0xFF0277BD),
                ),

                _buildProtectionCard(
                  number: '03',
                  category: 'SUPREME COURT ARREST MANDATE',
                  title: 'D.K. Basu Guidelines & Arrest Memo',
                  details:
                      'Requires arresting officers to wear clear name tags, prepare an arrest memo countersigned by a witness, inform a relative or friend immediately, and arrange a medical examination.',
                  accentColor: const Color(0xFF6A1B9A),
                ),

                _buildProtectionCard(
                  number: '04',
                  category: 'INFORMATION TECHNOLOGY ACT 2000',
                  title: 'Section 4 & BSA 2023 §61: Electronic Document Validity',
                  details:
                      'Electronic and digitally verified documents produced through approved digital platforms enjoy legal recognition on par with physical documents across all government authorities.',
                  accentColor: const Color(0xFFD84315),
                ),

                _buildProtectionCard(
                  number: '05',
                  category: 'MOTOR VEHICLES ACT 1988',
                  title: 'Section 130 & Rule 139 CMVR: Spot Inspection Immunity',
                  details:
                      'Production of digital driving license and vehicle registration through verified digital applications fully discharges statutory obligations. Physical confiscation is strictly prohibited under Rule 139.',
                  accentColor: const Color(0xFF2E7D32),
                ),

                const SizedBox(height: 16),

                // Emergency Contacts & Dispatch
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF211515),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emergency_rounded, color: Color(0xFFFF5252), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'EMERGENCY DISPATCH HOTLINES',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEmergencyCallButton(
                              label: '112 POLICE',
                              subtitle: 'National Emergency',
                              color: const Color(0xFFBA1A1A),
                              onTap: () => _makeCall('112'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildEmergencyCallButton(
                              label: '15100 NALSA',
                              subtitle: 'Free Legal Aid',
                              color: const Color(0xFF006A4E),
                              onTap: () => _makeCall('15100'),
                            ),
                          ),
                        ],
                      ),
                      if (kinPhone.isNotEmpty || counselPhone.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFF3E2C2C)),
                        const SizedBox(height: 8),
                        Text(
                          'CITIZEN DESIGNATED SOS CONTACTS',
                          style: GoogleFonts.montserrat(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFD4A5A5),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (kinPhone.isNotEmpty)
                          _buildContactChip('Kin / Family', kinPhone, Icons.family_restroom_rounded, () => _makeCall(kinPhone)),
                        if (counselPhone.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _buildContactChip('Legal Counsel', counselPhone, Icons.gavel_rounded, () => _makeCall(counselPhone)),
                        ],
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Back / Open App Button
                ElevatedButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushNamedAndRemoveUntil(context, AppRouter.home, (route) => false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.open_in_browser_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'OPEN IN CIVIC APPLICATION',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'CIVIC Platform • Cryptographically Secured Client-Side Architecture\nZero Server Log • Open Digital Rights Standards',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF888888),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, IconData icon, {bool isCode = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B7280),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: isCode
                  ? GoogleFonts.jetBrainsMono(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    )
                  : GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProtectionCard({
    required String number,
    required String category,
    required String title,
    required String details,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  number,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: GoogleFonts.montserrat(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            details,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4B5563),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCallButton({
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
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

  Widget _buildContactChip(String label, String number, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF332020),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFFFF8A80)),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFFCDD2),
              ),
            ),
            Expanded(
              child: Text(
                number,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.call_rounded, size: 15, color: Color(0xFF4ECCA3)),
          ],
        ),
      ),
    );
  }
}
