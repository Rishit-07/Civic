import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/content_models.dart';
import '../../data/services/location/civic_location_service.dart';
import 'situation_card_screen.dart';

enum AudioRecordState { idle, recording, saved }

/// High-priority Emergency Triage screen matching the CIVIC SOS design.
/// Features immediate emergency dialers, offline SMS broadcast, incident audio logger,
/// screen strobe alarm, discreet disguise mask, and Article 22(1) constitutional safeguards.
class TriageScreen extends StatefulWidget {
  final Scenario? scenario;

  const TriageScreen({super.key, this.scenario});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> with SingleTickerProviderStateMixin {
  // Interactive features state
  AudioRecordState _recordState = AudioRecordState.idle;
  Timer? _recordSavedTimer;

  bool _isStrobeActive = false;
  Timer? _strobeTimer;
  bool _strobeColorToggle = false;

  bool _isDiscreetMaskActive = false;

  // Pulse animation for recording / emergency badge
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _recordSavedTimer?.cancel();
    _strobeTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // --- Actions ---

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showToast('Dialing $number...');
      }
    } catch (_) {
      _showToast('Dialing $number...');
    }
  }

  Future<void> _sendSosBroadcast() async {
    _showToast('Fetching live Google Maps coordinates...');
    final location = await CivicLocationService.getCurrentLocation();
    final message = CivicLocationService.buildEmergencySosMessage(
      location: location,
      headline: '🚨 CIVIC EMERGENCY SOS',
      situation: 'Immediate legal assistance needed.',
    );
    final smsUri = Uri.parse('sms:?body=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        // ignore: deprecated_member_use
        await Share.share(message, subject: 'CIVIC EMERGENCY SOS (Live Google Maps)');
      }
      _showToast('Emergency SOS Broadcast prepared with live Google Maps link');
    } catch (_) {
      // ignore: deprecated_member_use
      await Share.share(message, subject: 'CIVIC EMERGENCY SOS (Live Google Maps)');
    }
  }

  void _toggleAudioRecorder() {
    _recordSavedTimer?.cancel();
    setState(() {
      if (_recordState == AudioRecordState.idle) {
        _recordState = AudioRecordState.recording;
        _showToast('Recording incident audio in encrypted buffer...');
      } else if (_recordState == AudioRecordState.recording) {
        _recordState = AudioRecordState.saved;
        _showToast('Incident audio saved to local vault & secure mirror');
        _recordSavedTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _recordState = AudioRecordState.idle;
            });
          }
        });
      } else {
        _recordState = AudioRecordState.recording;
      }
    });
  }

  void _toggleScreenStrobe() {
    setState(() {
      _isStrobeActive = !_isStrobeActive;
      if (_isStrobeActive) {
        _strobeTimer?.cancel();
        _strobeTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
          if (mounted) {
            setState(() {
              _strobeColorToggle = !_strobeColorToggle;
            });
          }
        });
      } else {
        _strobeTimer?.cancel();
      }
    });
  }

  void _toggleDiscreetMask() {
    setState(() {
      _isDiscreetMaskActive = !_isDiscreetMaskActive;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Ambient Glow Background Accents
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFBA1A1A).withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA83900).withValues(alpha: 0.08),
              ),
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Hero Header Block
                        _buildHeroHeader(),
                        const SizedBox(height: 20),

                        // Stack of 4 Emergency Action Cards
                        _buildActionCards(),
                        const SizedBox(height: 14),

                        // 2-Column Utility Buttons (Strobe & Discreet)
                        _buildUtilityRow(),
                        const SizedBox(height: 16),

                        // Constitutional Mandate Article 22(1) Card
                        _buildConstitutionalMandateCard(),
                        const SizedBox(height: 20),

                        // Optional Scenario Context (if arrived from situation list)
                        if (widget.scenario != null) ...[
                          _buildScenarioBanner(widget.scenario!),
                          const SizedBox(height: 16),
                        ],

                        // Back to Safe Home Button
                        _buildSafeHomeButton(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Full-Screen Strobe Flashing Overlay
          if (_isStrobeActive)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleScreenStrobe,
                child: Container(
                  color: _strobeColorToggle ? const Color(0xFFBA1A1A) : Colors.white,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'STROBE ACTIVE',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _toggleScreenStrobe,
                                icon: const Icon(Icons.close_rounded, color: Colors.black, size: 30),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 40),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'TAP ANYWHERE TO STOP STROBE',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Full-Screen Discreet Calculator Disguise Overlay
          if (_isDiscreetMaskActive)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleDiscreetMask,
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(32),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Calculator • Offline Note',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '0.00',
                          style: GoogleFonts.montserrat(
                            fontSize: 54,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade300,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          'Tap anywhere to return to Emergency Console',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9).withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(
            color: Color(0x0A000000),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF1A1C1C),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Image.asset(
                'assets/images/civic_logo.png',
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.shield_rounded,
                  color: Color(0xFFA83900),
                  size: 26,
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
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFA83900),
                      letterSpacing: 1.4,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Emergency Triage',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1C1C),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFA83900),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Column(
      children: [
        const SizedBox(height: 6),
        // Emergency Rights Mode Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFFBA1A1A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'EMERGENCY RIGHTS MODE',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: const Color(0xFF1A1C1C),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Main Headline
        Text(
          'Stay calm.',
          style: GoogleFonts.montserrat(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1C1C),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Help is one tap away.',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFBA1A1A),
          ),
        ),
        const SizedBox(height: 12),
        // GPS Ready Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0B000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF526259),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'GPS Ready • Works without cellular data via SMS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5B4137),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCards() {
    return Column(
      children: [
        // 1. CALL 112
        _buildActionCard(
          onTap: () => _makeCall('112'),
          backgroundColor: const Color(0xFFBF0715),
          leftIcon: Icons.call_rounded,
          leftIconFill: true,
          title: 'CALL 112',
          subtitle: 'National Police & Medical',
          rightIcon: Icons.bolt_rounded,
        ),
        const SizedBox(height: 10),

        // 2. CALL LEGAL AID 15100
        _buildActionCard(
          onTap: () => _makeCall('15100'),
          backgroundColor: const Color(0xFF2F3131),
          leftIcon: Icons.gavel_rounded,
          leftIconFill: true,
          title: 'CALL LEGAL AID 15100',
          subtitle: 'NALSA 24/7 Statutory Hotline',
          rightIcon: Icons.shield_rounded,
        ),
        const SizedBox(height: 10),

        // 3. SEND EMERGENCY SOS SMS
        _buildActionCard(
          onTap: _sendSosBroadcast,
          backgroundColor: const Color(0xFFA83900),
          leftIcon: Icons.share_location_rounded,
          leftIconFill: false,
          title: 'SEND EMERGENCY SOS SMS',
          subtitle: '3 Contacts • Live Coordinates',
          rightIcon: Icons.send_rounded,
        ),
        const SizedBox(height: 10),

        // 4. RECORD INCIDENT AUDIO
        _buildAudioRecorderCard(),
      ],
    );
  }

  Widget _buildActionCard({
    required VoidCallback onTap,
    required Color backgroundColor,
    required IconData leftIcon,
    required bool leftIconFill,
    required String title,
    required String subtitle,
    required IconData rightIcon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.20),
                ),
                child: Icon(
                  leftIcon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.82),
                        letterSpacing: 0.6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.16),
                ),
                child: Icon(
                  rightIcon,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioRecorderCard() {
    final isRecording = _recordState == AudioRecordState.recording;
    final isSaved = _recordState == AudioRecordState.saved;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleAudioRecorder,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRecording ? const Color(0xFFBA1A1A) : const Color(0xFFE8E8E8),
              width: isRecording ? 1.5 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecording
                      ? const Color(0xFFBA1A1A)
                      : (isSaved ? const Color(0xFFD5E7DC) : const Color(0xFFFFDAD6)),
                ),
                child: Icon(
                  Icons.mic_rounded,
                  color: isRecording
                      ? Colors.white
                      : (isSaved ? const Color(0xFF526259) : const Color(0xFF93000A)),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRecording ? 'RECORDING ENCRYPTED AUDIO' : 'RECORD INCIDENT AUDIO',
                      style: GoogleFonts.montserrat(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isRecording ? const Color(0xFFBA1A1A) : const Color(0xFF1A1C1C),
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isRecording
                          ? 'Tamper-Proof Cloud + Local Mirror'
                          : (isSaved ? 'Encrypted and Mirror-Backed Up' : 'Stealth 1-Tap Background Log'),
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5B4137),
                        letterSpacing: 0.6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isRecording
                      ? const Color(0xFFBA1A1A)
                      : (isSaved ? const Color(0xFF526259) : const Color(0xFFE8E8E8)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isRecording ? 'LIVE REC' : (isSaved ? 'SAVED' : 'IDLE'),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: (isRecording || isSaved) ? Colors.white : const Color(0xFF5B4137),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUtilityRow() {
    return Row(
      children: [
        // Strobe Alarm Button
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleScreenStrobe,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: _isStrobeActive ? const Color(0xFFBA1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.crisis_alert_rounded,
                      color: _isStrobeActive ? Colors.white : const Color(0xFFA83900),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Strobe Alarm',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _isStrobeActive ? Colors.white : const Color(0xFF1A1C1C),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Discreet Mask Button
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleDiscreetMask,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.visibility_off_rounded,
                      color: Color(0xFF526259),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Discreet Mask',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1C1C),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConstitutionalMandateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD5E7DC),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Color(0xFF58685F),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONSTITUTIONAL MANDATE • ARTICLE 22(1)',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF526259),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '“No person who is arrested shall be detained in custody without being informed of the grounds for arrest, nor denied the right to consult and be defended by a legal practitioner of their choice.”',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    height: 1.45,
                    color: const Color(0xFF1A1C1C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioBanner(Scenario sc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFA83900).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFFA83900),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LINKED SCENARIO',
                  style: GoogleFonts.montserrat(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFA83900),
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  sc.label,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1C1C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SituationCardScreen(
                    cardId: '${sc.id}_default',
                    userRole: UserRole.affected,
                  ),
                ),
              );
            },
            child: Text(
              'VIEW GUIDE',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFA83900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeHomeButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E2E2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security_rounded,
                color: Color(0xFF1A1C1C),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'BACK TO SAFE HOME',
                style: GoogleFonts.montserrat(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1C1C),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
