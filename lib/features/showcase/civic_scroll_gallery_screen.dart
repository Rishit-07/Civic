import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_radii.dart';
import '../navigation/widgets/civic_dynamic_footer.dart';
import '../scenarios/situation_card_screen.dart';
import '../scenarios/situation_list_screen.dart';

/// Item data model for the ScrollHorizontal gallery matching CIVIC Design Standards
class CivicGalleryItem {
  final int id;
  final String label;
  final String subtitle;
  final String statute;
  final String imagePath;
  final Color accentColor;
  final String cardId;
  final String tag;
  final String verdict;
  final String constitutionalBasis;

  const CivicGalleryItem({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.statute,
    required this.imagePath,
    required this.accentColor,
    required this.cardId,
    required this.tag,
    required this.verdict,
    required this.constitutionalBasis,
  });
}

/// Architectural Horizontal Scroll-Driven Gallery
/// Implements sticky vertical-to-horizontal transform pinning in Flutter:
/// Pinned on screen until all cards 01 -> 05 are traversed, then releases to Outro & Footer.
/// Color palette strictly matched to CIVIC (#FAFAFA, #17261F, #FF5A00, #FFFFFF).
class CivicScrollGalleryScreen extends StatefulWidget {
  const CivicScrollGalleryScreen({super.key});

  @override
  State<CivicScrollGalleryScreen> createState() =>
      _CivicScrollGalleryScreenState();
}

class _CivicScrollGalleryScreenState extends State<CivicScrollGalleryScreen> {
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  static const double _desktopCardWidth = 420.0;
  static const double _desktopCardHeight = 520.0;
  static const double _desktopGap = 32.0;

  static const double _mobileCardWidth = 300.0;
  static const double _mobileCardHeight = 440.0;
  static const double _mobileGap = 16.0;

  final List<CivicGalleryItem> _items = const [
    CivicGalleryItem(
      id: 1,
      label: 'TRAFFIC CHECKPOINT',
      subtitle: 'Key Snatching & Vehicle Impoundment Limits',
      statute: 'MVA 1988 § 130/206 · BNSS § 106',
      imagePath: 'assets/images/gallery/traffic_checkpoint.jpg',
      accentColor: Color(0xFFFF5A00), // Brand Saffron
      cardId: 'traffic_stop_default',
      tag: 'MOTOR VEHICLES',
      verdict: 'Confiscating vehicle ignition keys is strictly unlawful without a cognizable warrant.',
      constitutionalBasis: 'Right to Liberty & Procedural Propriety under Motor Vehicles Act',
    ),
    CivicGalleryItem(
      id: 2,
      label: 'ARREST SAFEGUARDS',
      subtitle: '11 D.K. Basu Mandatory Guidelines & Arrest Memo',
      statute: 'CONSTITUTION ART 21 · BNSS § 36',
      imagePath: 'assets/images/gallery/court_justice.jpg',
      accentColor: Color(0xFF1E3A8A), // Sovereign Navy
      cardId: 'arrest_detention_default',
      tag: 'CONSTITUTIONAL RIGHT',
      verdict: 'Immediate grounds notice, friend notification in 8h, and 24h Magistrate production.',
      constitutionalBasis: 'Fundamental Right to Life and Personal Liberty (Article 21)',
    ),
    CivicGalleryItem(
      id: 3,
      label: 'ZERO FIR MANDATE',
      subtitle: 'Instant Registration Anywhere Across India',
      statute: 'BNSS 2023 § 173 · SP ESCALATION § 173(4)',
      imagePath: 'assets/images/gallery/zero_fir.jpg',
      accentColor: Color(0xFF059669), // Civic Emerald
      cardId: 'fir_refused_default',
      tag: 'BNSS MANDATE',
      verdict: 'Any police station must register a cognizable complaint regardless of territorial jurisdiction.',
      constitutionalBasis: 'Mandatory Access to Criminal Justice System & Lalita Kumari Precedent',
    ),
    CivicGalleryItem(
      id: 4,
      label: 'DIGITAL PRIVACY',
      subtitle: 'Smartphone Inspection & Search Protocols',
      statute: 'CONSTITUTION ART 20(3) · BNSS § 105',
      imagePath: 'assets/images/gallery/digital_privacy.jpg',
      accentColor: Color(0xFF7C3AED), // Cyber Defense Purple
      cardId: 'account_frozen_default',
      tag: 'DIGITAL INTEGRITY',
      verdict: 'Citizens cannot be compelled to provide phone passcodes without a Magistrate warrant.',
      constitutionalBasis: 'Right against Self-Incrimination (Article 20(3)) & KS Puttaswamy',
    ),
    CivicGalleryItem(
      id: 5,
      label: 'NIGHT ARREST BAN',
      subtitle: 'Sunset-to-Sunrise Protection for Women',
      statute: 'BNSS 2023 § 43 (FORMERLY CrPC 46(4))',
      imagePath: 'assets/images/gallery/night_safeguards.jpg',
      accentColor: Color(0xFFD97706), // Twilight Amber
      cardId: 'domestic_violence_default',
      tag: 'GENDER SAFEGUARD',
      verdict: 'No female citizen can be arrested between sunset and sunrise except under judicial order.',
      constitutionalBasis: 'Special Statutory & Constitutional Safeguard for Female Citizens',
    ),
  ];

  // ─── Paint-phase ValueNotifiers (no setState, no layout thrash) ───
  final ValueNotifier<double> _scrollProgressNotifier = ValueNotifier(0.0);
  final ValueNotifier<int> _activeCardNotifier = ValueNotifier(0);
  final ValueNotifier<double> _pinOffsetNotifier = ValueNotifier(0.0);

  int _hoveredCardIndex = -1;

  // Cached layout params (recomputed only on build, not during scroll)
  double _zoneStart = 0.0;
  double _totalDistance = 0.0;
  double _endDwell = 0.0;

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(_handleScroll);
  }

  /// High-frequency scroll handler — ZERO setState calls.
  /// Updates only ValueNotifiers (paint-phase) and jumpTo (paint-phase).
  void _handleScroll() {
    if (!mounted || !_mainScrollController.hasClients) return;

    final double currentOffset = _mainScrollController.offset;

    if (currentOffset <= _zoneStart) {
      // Before the pinned zone — reset everything
      if (_scrollProgressNotifier.value != 0.0) {
        _scrollProgressNotifier.value = 0.0;
        _activeCardNotifier.value = 0;
        _pinOffsetNotifier.value = 0.0;
      }
      if (_horizontalController.hasClients &&
          _horizontalController.position.hasContentDimensions &&
          _horizontalController.offset != 0.0) {
        _horizontalController.jumpTo(0.0);
      }
      return;
    }

    // Compute normalized progress [0..1] through the horizontal zone
    final double progress =
        ((_totalDistance > 0.0) ? ((currentOffset - _zoneStart) / _totalDistance) : 0.0)
            .clamp(0.0, 1.0);

    // Update pin offset (paint only, no layout change)
    final double pinOffset =
        (currentOffset - _zoneStart).clamp(0.0, _totalDistance + _endDwell);
    _pinOffsetNotifier.value = pinOffset;

    // Update scroll progress for dots / header counter
    _scrollProgressNotifier.value = progress;

    // Determine active card index
    final int newActiveIndex =
        (progress * (_items.length - 1)).round().clamp(0, _items.length - 1);
    if (_activeCardNotifier.value != newActiveIndex) {
      _activeCardNotifier.value = newActiveIndex;
    }

    // Synchronize horizontal gallery — direct jumpTo, no setState
    if (_horizontalController.hasClients &&
        _horizontalController.position.hasContentDimensions) {
      final double maxH = _horizontalController.position.maxScrollExtent;
      final double target = progress * maxH;
      // Always sync (jumpTo is a paint-phase operation, very cheap)
      _horizontalController.jumpTo(target);
    }
  }

  void _scrollToCard(int index) {
    if (!_mainScrollController.hasClients) return;

    final double targetFraction = index / (_items.length - 1);
    final double targetMainOffset =
        _zoneStart + (targetFraction * _totalDistance);

    _mainScrollController.animateTo(
      targetMainOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _mainScrollController.removeListener(_handleScroll);
    _mainScrollController.dispose();
    _horizontalController.dispose();
    _scrollProgressNotifier.dispose();
    _activeCardNotifier.dispose();
    _pinOffsetNotifier.dispose();
    super.dispose();
  }

  void _openCard(CivicGalleryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SituationCardScreen(cardId: item.cardId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isMobile = screenSize.width < 600;
    final double cardW = isMobile ? _mobileCardWidth : _desktopCardWidth;
    final double cardH = isMobile ? _mobileCardHeight : _desktopCardHeight;
    final double gapW = isMobile ? _mobileGap : _desktopGap;

    final double introH = math.max(screenSize.height * 0.46, 320.0);
    _totalDistance = (_items.length - 1) * (cardW + gapW);
    _endDwell = isMobile ? 160.0 : 280.0;
    _zoneStart = 70.0 + introH;

    // Pinned zone total vertical height: viewport + horizontal travel distance + dwell
    final double pinnedZoneHeight =
        screenSize.height + _totalDistance + _endDwell;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Matches CIVIC app theme
      body: Stack(
        children: [
          // Background ambient constructivist circles matching CIVIC design
          Positioned(
            top: -90,
            right: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF5A00).withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFECEEF2),
              ),
            ),
          ),

          // Primary Vertical Scrollable containing Intro -> Pinned Gallery -> Outro -> Footer
          SingleChildScrollView(
            controller: _mainScrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header buffer
                const SizedBox(height: 70),

                // SECTION 1: Intro Section
                _buildIntroSection(introH, isMobile),

                // SECTION 2: Sticky Pinned Horizontal Scroll Section
                // Forces user to scroll through all 5 cards horizontally before moving down
                SizedBox(
                  height: pinnedZoneHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ── Paint-phase pinning via ValueListenableBuilder ──
                      // Instead of computing galleryPinOffset in build() and
                      // passing it to Positioned(top:), we pin at top:0 and
                      // apply the offset via Transform.translate driven by a
                      // ValueNotifier. This means vertical scroll updates
                      // only repaint this subtree, never re-layout the Column.
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: screenSize.height,
                        child: ValueListenableBuilder<double>(
                          valueListenable: _pinOffsetNotifier,
                          builder: (context, pinOffset, child) {
                            return Transform.translate(
                              offset: Offset(0, pinOffset),
                              child: child,
                            );
                          },
                          child: _buildPinnedGalleryViewport(
                            cardW,
                            cardH,
                            gapW,
                            isMobile,
                            screenSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // SECTION 3: Outro Section (Unlocked only after Card 05 is traversed)
                _buildOutroSection(screenSize, isMobile),

                // SECTION 4: CIVIC Dynamic Footer
                const CivicDynamicFooter(),
              ],
            ),
          ),

          // Persistent Top Navigation Header matching CIVIC Theme
          _buildPersistentHeader(context, isMobile),
        ],
      ),
    );
  }

  /// Persistent Top Navigation Header (Light Theme with Brand Accents)
  Widget _buildPersistentHeader(BuildContext context, bool isMobile) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16.0 : 28.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA).withValues(alpha: 0.94),
          border: const Border(
            bottom: BorderSide(color: Color(0xFFE2E4EB), width: 1.0),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button + Brand Pill
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF17261F), size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadii.pillBorder,
                      border: Border.all(
                          color: const Color(0xFFE2E4EB), width: 1.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/civic_logo.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'CIVIC',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: const Color(0xFF17261F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Card Counter & SOS Direct Pill
              Row(
                children: [
                  // Step Indicator: "CARD 01 / 05" — driven by ValueNotifier
                  ValueListenableBuilder<int>(
                    valueListenable: _activeCardNotifier,
                    builder: (context, activeIdx, _) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5A00).withValues(alpha: 0.10),
                          borderRadius: AppRadii.pillBorder,
                          border: Border.all(
                            color: const Color(0xFFFF5A00).withValues(alpha: 0.30),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF5A00),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'CARD 0${activeIdx + 1} / 0${_items.length}',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFF5A00),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),

                  // SOS Direct Emergency Button
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SituationListScreen(),
                        ),
                      );
                    },
                    borderRadius: AppRadii.pillBorder,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD92D20),
                        borderRadius: AppRadii.pillBorder,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33D92D20),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emergency_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'SOS DIRECT',
                            style: GoogleFonts.montserrat(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// SECTION 1: Intro Section (Light Architectural Theme)
  Widget _buildIntroSection(double introHeight, bool isMobile) {
    return Container(
      height: introHeight,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24.0 : 48.0,
        vertical: 24.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Monospace Tag Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.pillBorder,
              border: Border.all(color: const Color(0xFFE2E4EB), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5A00),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'STATUTORY VISUAL ARCHITECTURE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: const Color(0xFFFF5A00),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Impact Headline in CIVIC #17261F
          Text(
            'CIVIC NIGHTS & CITIZEN RIGHTS',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: isMobile ? 30 : 50,
              fontWeight: FontWeight.w900,
              letterSpacing: isMobile ? 0.8 : 2.0,
              height: 1.08,
              color: const Color(0xFF17261F),
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle / Scroll Prompt
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              'Scroll down to glide horizontally through real statutory defense scenarios under BNSS 2023, BNS 2023 & the Constitution of India.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Downward Scroll Chevron Prompt
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_downward_rounded,
                  color: Color(0xFFFF5A00), size: 16),
              const SizedBox(width: 6),
              Text(
                'SCROLL DOWN TO TRAVERSE ALL CARDS',
                style: GoogleFonts.montserrat(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: const Color(0xFFFF5A00),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// SECTION 2 Viewport: Contains the sticky horizontal gallery track + controls
  Widget _buildPinnedGalleryViewport(
    double cardW,
    double cardH,
    double gapW,
    bool isMobile,
    Size screenSize,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Floating Card Gallery Track
          SizedBox(
            height: cardH,
            child: ListView.separated(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(), // Driven strictly by vertical progress
              padding: EdgeInsets.symmetric(
                horizontal: math.max(
                  (screenSize.width - cardW) / 2,
                  isMobile ? 24.0 : 48.0,
                ),
              ),
              itemCount: _items.length,
              separatorBuilder: (context, index) => SizedBox(width: gapW),
              itemBuilder: (context, index) {
                return _buildGalleryCard(
                  _items[index],
                  index,
                  cardW,
                  cardH,
                  isMobile,
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Interactive Navigation Dots & Arrow Controls
          _buildGalleryControls(isMobile),
        ],
      ),
    );
  }

  /// Individual High-End Card matching CIVIC Theme (#FAFAFA, #FFFFFF, #17261F, #FF5A00)
  Widget _buildGalleryCard(
    CivicGalleryItem item,
    int index,
    double cardW,
    double cardH,
    bool isMobile,
  ) {
    return ValueListenableBuilder<int>(
      valueListenable: _activeCardNotifier,
      builder: (context, activeIdx, _) {
        final bool isActive = activeIdx == index;
        final bool isHovered = _hoveredCardIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCardIndex = index),
      onExit: (_) => setState(() => _hoveredCardIndex = -1),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _openCard(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: cardW,
          height: cardH,
          transform: Matrix4.translationValues(
              0.0, isHovered || isActive ? -8.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isActive
                  ? item.accentColor
                  : (isHovered
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFFE2E4EB)),
              width: isActive ? 2.2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? item.accentColor.withValues(alpha: 0.22)
                    : const Color(0x0F000000),
                blurRadius: isActive ? 26 : 14,
                offset: Offset(0, isActive ? 12 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Visual Artwork Section (55% height)
                Expanded(
                  flex: 11,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF1F5F9),
                            child: Center(
                              child: Icon(
                                Icons.balance_rounded,
                                color: item.accentColor,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),

                      // Gradient fade from image into crisp white card body
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.65),
                              Colors.white,
                            ],
                            stops: const [0.0, 0.45, 0.85, 1.0],
                          ),
                        ),
                      ),

                      // Top Row: Category Tag & Arrow Badge
                      Positioned(
                        top: 14,
                        left: 14,
                        right: 14,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF17261F),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x22000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                item.tag,
                                style: GoogleFonts.montserrat(
                                  fontSize: 9.0,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFFE2E4EB), width: 1.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_outward_rounded,
                                  color: item.accentColor,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Content Section (45% height)
                Expanded(
                  flex: 9,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Monospace Counter: "01", "02"
                            Text(
                              '0${item.id}',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                color: item.accentColor,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Main Headline
                            Text(
                              item.label,
                              style: GoogleFonts.montserrat(
                                fontSize: isMobile ? 18 : 22,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF17261F),
                                height: 1.15,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Statutory Section Badge
                            Text(
                              item.statute,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFF5A00),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Key Citizen Verdict
                            Text(
                              item.verdict,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4B5563),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),

                        // Action Button Pill: "VIEW STATUTORY GUIDE"
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF17261F)
                                : const Color(0xFFF3F4F6),
                            borderRadius: AppRadii.pillBorder,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'VIEW STATUTORY GUIDE',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: isActive
                                      ? Colors.white
                                      : const Color(0xFF17261F),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: isActive
                                    ? Colors.white
                                    : const Color(0xFF17261F),
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
        ),
      ),
    );
      },
    );
  }

  /// Interactive Navigation Controls (Dots, Prev/Next, Status)
  Widget _buildGalleryControls(bool isMobile) {
    return ValueListenableBuilder<int>(
      valueListenable: _activeCardNotifier,
      builder: (context, activeIdx, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.pillBorder,
            border: Border.all(color: const Color(0xFFE2E4EB), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Previous Card Arrow
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                color: activeIdx > 0
                    ? const Color(0xFF17261F)
                    : const Color(0xFFCBD5E1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: activeIdx > 0
                    ? () => _scrollToCard(activeIdx - 1)
                    : null,
              ),
              const SizedBox(width: 8),

              // Fluid Animated Pagination Dots
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_items.length, (i) {
                  final bool isSelected = activeIdx == i;
                  return GestureDetector(
                    onTap: () => _scrollToCard(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isSelected ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF5A00)
                            : const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),

              // Next Card Arrow
              IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                color: activeIdx < _items.length - 1
                    ? const Color(0xFF17261F)
                    : const Color(0xFFCBD5E1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: activeIdx < _items.length - 1
                    ? () => _scrollToCard(activeIdx + 1)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  /// SECTION 3: Outro Section (Unlocked only after Card 05 is traversed)
  Widget _buildOutroSection(Size screenSize, bool isMobile) {
    return Container(
      constraints: BoxConstraints(minHeight: screenSize.height * 0.44),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24.0 : 48.0,
        vertical: 48.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.12),
              borderRadius: AppRadii.pillBorder,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded,
                    color: Color(0xFF059669), size: 16),
                const SizedBox(width: 6),
                Text(
                  'ALL 5 CRITICAL PROTOCOLS COMPLETED',
                  style: GoogleFonts.montserrat(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'CONSTITUTIONAL DEFENSE IN YOUR POCKET',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: isMobile ? 26 : 40,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: const Color(0xFF17261F),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Text(
              'Over 28+ verified offline scenario guides, emergency dispatch integrations, and instant statutory triage at zero cost.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Primary Action CTA: Explore All Scenarios
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SituationListScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5A00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadii.pillBorder,
              ),
              elevation: 8,
              shadowColor: const Color(0x44FF5A00),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EXPLORE ALL 28+ SCENARIOS',
                  style: GoogleFonts.montserrat(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_rounded, size: 17),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
