import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/content_models.dart';
import '../../../data/services/prepare_readiness_service.dart';
import '../../scenarios/situation_card_screen.dart';

/// Complete, production-grade Citizen Preparedness and Readiness screen
/// faithfully reflecting the Neo-Constructivist Stitch design system with
/// real persistence, interactive readiness lessons, legal drills, and Firestore sync.
class PrepareScreen extends StatefulWidget {
  const PrepareScreen({super.key});

  @override
  State<PrepareScreen> createState() => _PrepareScreenState();
}

class _PrepareScreenState extends State<PrepareScreen> {
  String _selectedCategory = 'All';
  int _currentDrillIndex = 0;
  String? _selectedOptionId;
  bool _isAnswerChecked = false;

  final List<String> _categories = [
    'All',
    'Police',
    'Campus',
    'Couples',
    'Online Fraud',
    'Work',
    'Housing',
  ];

  @override
  void initState() {
    super.initState();
    // Check if the current drill was already answered in storage
    final currentDrill = PrepareReadinessService.dailyDrills[_currentDrillIndex];
    final storedAnswer =
        PrepareReadinessService.completedDrillsNotifier.value[currentDrill.id];
    if (storedAnswer != null) {
      _selectedOptionId = storedAnswer;
      _isAnswerChecked = true;
    }
  }

  List<PrepareLesson> get _filteredLessons {
    if (_selectedCategory == 'All') {
      return PrepareReadinessService.allLessons;
    }
    return PrepareReadinessService.allLessons
        .where((l) => l.category.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
  }

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showToast('Calling $number...', icon: Icons.phone);
      }
    } catch (_) {
      _showToast('Calling $number...', icon: Icons.phone);
    }
  }

  void _shareGpsBeacon() {
    // ignore: deprecated_member_use
    Share.share(
      '🚨 POLICE / CIVIC READINESS SOS: I am sharing my live emergency coordinates. Please stand by: https://maps.google.com/?q=28.6139,77.2090',
      subject: 'Emergency Readiness Beacon',
    );
    _showToast('Emergency GPS Beacon shared', icon: Icons.near_me_rounded);
  }

  void _showEmergencyContactsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.contact_phone_rounded,
                        color: Color(0xFFBF0715), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'EMERGENCY DISPATCH DIRECTORY',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF101F18),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildContactRow(
                '112', 'Universal All-India Police & Emergency', Icons.local_police_rounded),
            _buildContactRow(
                '15100', 'NALSA Free Legal Aid Hotline (24/7)', Icons.gavel_rounded),
            _buildContactRow(
                '1930', 'National Cyber Crime Financial Fraud', Icons.security_rounded),
            _buildContactRow(
                '1800-180-5522', 'UGC National Anti-Ragging Helpline', Icons.school_rounded),
            _buildContactRow(
                '1091', 'Women in Distress Police Helpline', Icons.shield_rounded),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(String number, String label, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _makeCall(number);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF101F18), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFBF0715),
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF5B4137),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.phone_forwarded_rounded,
                color: Color(0xFF15803D), size: 18),
          ],
        ),
      ),
    );
  }

  void _showToast(String message, {IconData icon = Icons.check_circle_rounded}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF5A00), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF101F18),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Fixed Top Header & Emergency Bar
            _buildTopHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. Header / Top Title Section
                    _buildHeaderTitles(),
                    const SizedBox(height: 14),

                    // B. Current Readiness Progress Card
                    _buildReadinessProgressCard(),
                    const SizedBox(height: 18),

                    // C. Horizontal Category Filter Chips Row
                    _buildFilterChipsRow(),
                    const SizedBox(height: 18),

                    // D. Featured Card: "JUST TURNED 18?"
                    _buildFeaturedCard(),
                    const SizedBox(height: 24),

                    // E. Core Readiness Drills Stack
                    _buildCoreDrillsSection(),
                    const SizedBox(height: 26),

                    // F. Practice Scenario Card (Interactive Daily Legal Drill)
                    _buildDailyLegalDrillCard(),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Fixed SOS Bar & CIVIC App Header
  Widget _buildTopHeader() {
    return Container(
      color: const Color(0xFFF9F9F9),
      child: Column(
        children: [
          // Red Emergency SOS Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 6,
              16,
              8,
            ),
            color: const Color(0xFFBF0715),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emergency_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'EMERGENCY SOS',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildSosPill('112', () => _makeCall('112')),
                    const SizedBox(width: 6),
                    _buildSosPill('15100', () => _makeCall('15100')),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: _shareGpsBeacon,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.near_me_rounded,
                            color: Colors.white, size: 15),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: _showEmergencyContactsDialog,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.contact_phone_rounded,
                            color: Colors.white, size: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // CIVIC Subheader
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/civic_logo.png',
                      height: 30,
                      width: 30,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.shield_rounded,
                        color: Color(0xFFA83900),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CIVIC',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFA83900),
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Prepare',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF101F18),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    // XP counter pill
                    ValueListenableBuilder<int>(
                      valueListenable: PrepareReadinessService.xpNotifier,
                      builder: (context, xp, _) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5A00).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt_rounded,
                                color: Color(0xFFFF5A00), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$xp XP',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFA83900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showToast('Statutory readiness alerts active',
                          icon: Icons.notifications_active_rounded),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEEEE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_rounded,
                            color: Color(0xFF101F18), size: 18),
                      ),
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

  Widget _buildSosPill(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Title and Subtitle Block
  Widget _buildHeaderTitles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CIVIC PREPAREDNESS MODULES',
              style: GoogleFonts.montserrat(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFA83900),
                letterSpacing: 0.8,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'BATCH 2025',
                style: GoogleFonts.montserrat(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF101F18),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'PREPARE',
          style: GoogleFonts.montserrat(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF101F18),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'LEARN CALMLY BEFORE IT MATTERS',
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF5B4137),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  /// Current Readiness Progress Card
  Widget _buildReadinessProgressCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        PrepareReadinessService.completedLessonsNotifier,
        PrepareReadinessService.featuredCompletedNotifier,
      ]),
      builder: (context, _) {
        final progress = PrepareReadinessService.getReadinessPercentage();
        final summary = PrepareReadinessService.getReadinessSummary();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E2E2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Current Readiness',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101F18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    summary,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFA83900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Dual-color progress track
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) => Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: constraints.maxWidth * progress,
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5A00), Color(0xFFA83900)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.verified_rounded,
                      color: Color(0xFF15803D), size: 15),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Recommended: 2 short drills daily to retain statutory procedural rights.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF5B4137),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Horizontal Filter Chips Row
  Widget _buildFilterChipsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF101F18) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF101F18)
                        : const Color(0xFFE2E2E2),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.montserrat(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF101F18),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Featured Transition Card: "JUST TURNED 18?"
  Widget _buildFeaturedCard() {
    return ValueListenableBuilder<bool>(
      valueListenable: PrepareReadinessService.featuredCompletedNotifier,
      builder: (context, isCompleted, _) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted ? const Color(0xFFD5E7DC) : const Color(0xFFE2E2E2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.badge_rounded,
                          color: Color(0xFFFF5A00), size: 24),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDBCF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ESSENTIAL TRANSITION',
                        style: GoogleFonts.montserrat(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF802900),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF15803D), size: 22),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'JUST TURNED 18?',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF101F18),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "WHAT CHANGES, WHAT DOESN'T IN INDIAN LAW",
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFA83900),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'From adult criminal liability to fundamental constitutional freedoms and voting eligibility.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF5B4137),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'EST. 3 MINS READ',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF5B4137),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE4BEB1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'INTERACTIVE CHECKLIST',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFA83900),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Black circular action button
                InkWell(
                  onTap: _openJustTurned18Guide,
                  borderRadius: BorderRadius.circular(26),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF101F18),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Core Readiness Drills Stack
  Widget _buildCoreDrillsSection() {
    final lessons = _filteredLessons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book_rounded,
                    color: Color(0xFFA83900), size: 20),
                const SizedBox(width: 8),
                Text(
                  'CORE READINESS DRILLS',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF101F18),
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            Text(
              '${lessons.length} LESSONS',
              style: GoogleFonts.montserrat(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF5B4137),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (lessons.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'No lessons in $_selectedCategory category.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF5B4137),
              ),
            ),
          )
        else
          ValueListenableBuilder<Set<String>>(
            valueListenable: PrepareReadinessService.completedLessonsNotifier,
            builder: (context, completedSet, _) {
              return Column(
                children: lessons.map((lesson) {
                  final isDone = completedSet.contains(lesson.id);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDone ? const Color(0xFFD5E7DC) : const Color(0xFFE2E2E2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => _openLessonModal(lesson),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: lesson.iconBgColor,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(lesson.icon,
                                      color: lesson.iconColor, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              lesson.title,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF101F18),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isDone)
                                            const Icon(Icons.check_circle_rounded,
                                                color: Color(0xFF15803D), size: 19)
                                          else
                                            const Icon(Icons.chevron_right_rounded,
                                                color: Color(0xFF907065), size: 20),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEEEEEE),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              lesson.duration,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF5B4137),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              lesson.priorityTag,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: isDone
                                                    ? const Color(0xFF15803D)
                                                    : const Color(0xFFA83900),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Mini progress track
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: isDone ? 1.0 : 0.0,
                                minHeight: 4,
                                backgroundColor: const Color(0xFFE2E2E2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFF5A00)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  /// Daily Legal Drill Card (Interactive practice quiz)
  Widget _buildDailyLegalDrillCard() {
    final drill = PrepareReadinessService.dailyDrills[_currentDrillIndex];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E2E2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDBCF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'DAILY LEGAL DRILL',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF802900),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.quiz_rounded,
                      color: Color(0xFFA83900), size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '+${drill.xpReward} XP',
                    style: GoogleFonts.montserrat(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFA83900),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            drill.question,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101F18),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            drill.subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF5B4137),
            ),
          ),
          const SizedBox(height: 16),

          // Selectable Options
          Column(
            children: drill.options.map((option) {
              final isSelected = _selectedOptionId == option.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedOptionId = option.id;
                      _isAnswerChecked = false; // reset feedback on option change
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFD5E7DC)
                          : const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF15803D)
                            : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFF101F18)
                                : const Color(0xFFE2E2E2),
                          ),
                          child: Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Colors.white : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option.text,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF101F18)
                                  : const Color(0xFF3B4A42),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _handleCheckAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAnswerChecked
                    ? const Color(0xFFFF5A00)
                    : const Color(0xFF101F18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 1,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isAnswerChecked
                        ? 'DRILL COMPLETED (+${drill.xpReward} XP)'
                        : 'CHECK ANSWER',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isAnswerChecked
                        ? Icons.check_circle_rounded
                        : Icons.task_alt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Feedback Box (Visible after checking)
          if (_isAnswerChecked) ...[
            const SizedBox(height: 12),
            _buildDrillFeedbackBox(drill),
          ],
        ],
      ),
    );
  }

  void _handleCheckAnswer() {
    if (_selectedOptionId == null) {
      _showToast('Please select an option first', icon: Icons.info_outline_rounded);
      return;
    }

    final drill = PrepareReadinessService.dailyDrills[_currentDrillIndex];
    final selectedOption =
        drill.options.firstWhere((o) => o.id == _selectedOptionId);

    setState(() {
      _isAnswerChecked = true;
    });

    PrepareReadinessService.recordDrillAnswer(
      drill.id,
      selectedOption.id,
      selectedOption.isCorrect,
    );

    if (selectedOption.isCorrect) {
      _showToast('Correct! +${drill.xpReward} XP added to Readiness',
          icon: Icons.celebration_rounded);
    } else {
      _showToast('Review statutory legal feedback below',
          icon: Icons.warning_amber_rounded);
    }
  }

  Widget _buildDrillFeedbackBox(LegalDrill drill) {
    final selectedOption =
        drill.options.firstWhere((o) => o.id == _selectedOptionId);
    final isCorrect = selectedOption.isCorrect;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFFD5E7DC).withValues(alpha: 0.6)
            : const Color(0xFFFFDBCF).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCorrect ? const Color(0xFF15803D) : const Color(0xFFA83900),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
            color: isCorrect ? const Color(0xFF15803D) : const Color(0xFFA83900),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Correct procedure!' : 'Caution: Legally Risky',
                  style: GoogleFonts.montserrat(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isCorrect
                        ? const Color(0xFF15803D)
                        : const Color(0xFFA83900),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  selectedOption.feedback,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: const Color(0xFF101F18),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Statutory Citation: ${drill.statutoryCitation}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF5B4137),
                  ),
                ),
                if (_currentDrillIndex < PrepareReadinessService.dailyDrills.length - 1) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _currentDrillIndex++;
                        _isAnswerChecked = false;
                        _selectedOptionId = 'b';
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TRY NEXT DRILL',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFA83900),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 14, color: Color(0xFFA83900)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Open detailed "JUST TURNED 18?" interactive guide modal
  void _openJustTurned18Guide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(22),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E2E2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDBCF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'TRANSITION GUIDE',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF802900),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'JUST TURNED 18?',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF101F18),
                ),
              ),
              Text(
                'Essential Indian Legal Freedoms & Responsibilities',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFA83900),
                ),
              ),
              const SizedBox(height: 18),

              // 4 Key Pillars
              _buildTransitionPillar(
                title: '1. Adult Criminal Jurisprudence',
                description:
                    'You are now governed under full adult criminal codes (BNS / CrPC) rather than the Juvenile Justice Board. You possess the constitutional right to be informed of arrest grounds, 24-hr magistrate production, and free NALSA counsel.',
                icon: Icons.gavel_rounded,
              ),
              _buildTransitionPillar(
                title: '2. Constitutional & Democratic Autonomy',
                description:
                    'Under Article 326 of the Constitution, you possess the non-negotiable right to vote. Under Article 21, you have full adult privacy—police and parents have zero legal power to restrict your lawful association, travel, or hotel check-ins.',
                icon: Icons.how_to_vote_rounded,
              ),
              _buildTransitionPillar(
                title: '3. Contractual & Financial Independence',
                description:
                    'You have legal capacity under Section 11 of the Indian Contract Act to execute binding contracts, sign apartment leases, open independent bank accounts, and demand formal employment terms without parental co-signing.',
                icon: Icons.account_balance_wallet_rounded,
              ),
              _buildTransitionPillar(
                title: '4. Essential 18+ Checklist',
                description:
                    'Apply for your Voter ID on voters.eci.gov.in, link your PAN card, and configure DigiLocker for legally verified digital IDs accepted across India under Rule 139 CMVR.',
                icon: Icons.checklist_rtl_rounded,
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    PrepareReadinessService.markFeaturedCompleted();
                    Navigator.pop(ctx);
                    _showToast('Transition guide marked as completed! (+50 XP)',
                        icon: Icons.military_tech_rounded);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF101F18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'COMPLETE TRANSITION DRILL (+50 XP)',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransitionPillar({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD5E7DC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF101F18), size: 20),
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
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF101F18),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF5B4137),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Open interactive lesson viewer modal
  void _openLessonModal(PrepareLesson lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: lesson.iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    lesson.priorityTag.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: lesson.iconColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lesson.title,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF101F18),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              lesson.summary,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF5B4137),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            Text(
              'KEY STATUTORY CHECKPOINTS',
              style: GoogleFonts.montserrat(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFA83900),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            ...lesson.keyCheckpoints.map(
              (cp) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF15803D), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cp,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF101F18),
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            Text(
              'Governing Law: ${lesson.legalCitation}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF5B4137),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                if (lesson.scenarioId != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SituationCardScreen(
                              cardId: lesson.scenarioId!,
                              userRole: UserRole.affected,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF101F18)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'PRACTICE SCENARIO',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF101F18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      PrepareReadinessService.markLessonCompleted(lesson.id);
                      Navigator.pop(ctx);
                      _showToast('Lesson completed! +15 XP added',
                          icon: Icons.check_circle_rounded);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5A00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'MARK AS DONE (+15 XP)',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
