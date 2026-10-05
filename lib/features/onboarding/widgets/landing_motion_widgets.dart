import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_radii.dart';
import '../../scenarios/situation_card_screen.dart';

/// Interactive Horizontal Scroll Selection Carousel showcasing citizen legal scenarios
class HorizontalScenarioSelector extends StatefulWidget {
  final ValueChanged<int>? onSelected;

  const HorizontalScenarioSelector({
    super.key,
    this.onSelected,
  });

  @override
  State<HorizontalScenarioSelector> createState() =>
      _HorizontalScenarioSelectorState();
}

class _HorizontalScenarioSelectorState
    extends State<HorizontalScenarioSelector> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;

  static const List<Map<String, String>> _scenarios = [
    {
      'id': 'police_stop_vehicle_search',
      'tag': 'MOTOR VEHICLES',
      'title': 'Traffic Stop & Key Seizure',
      'statute': 'MVA Sec 130 / 206',
      'action': 'Key confiscation is strictly unlawful',
      'icon': 'local_police',
    },
    {
      'id': 'police_encounter_filming',
      'tag': 'CONSTITUTIONAL RIGHT',
      'title': 'Recording Police in Public',
      'statute': 'Constitution Art 19(1)(a)',
      'action': 'Right to film on public duty',
      'icon': 'videocam',
    },
    {
      'id': 'women_arrest_night_guidelines',
      'tag': 'BNSS SAFEGUARD',
      'title': 'Arrest of Women at Night',
      'statute': 'BNSS Sec 43 (formerly CrPC 46)',
      'action': 'No arrest between sunset & sunrise',
      'icon': 'shield',
    },
    {
      'id': 'cyber_blackmail_morphing',
      'tag': 'CYBERCRIME DEFENSE',
      'title': 'Cyber Extortion & Blackmail',
      'statute': 'IT Act Sec 66E / BNS Sec 308',
      'action': 'Call 1930 / Never pay extortion',
      'icon': 'security',
    },
    {
      'id': 'account_frozen_bank_escalation',
      'tag': 'FINANCIAL RIGHTS',
      'title': 'Bank Account Cyber Freeze',
      'statute': 'Cyber Notice Dispute Sec 94',
      'action': 'Demand formal lien requisition copy',
      'icon': 'account_balance',
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectCard(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onSelected?.call(index);

    // Smoothly scroll towards selected card
    final double targetOffset = (index * 240.0) - 40.0;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section Subtitle & Indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXPLORE STATUTORY SCENARIOS',
                style: GoogleFonts.montserrat(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: const Color(0xFFFF5A00),
                ),
              ),
              Row(
                children: List.generate(_scenarios.length, (i) {
                  final isSelected = _selectedIndex == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: isSelected ? 16 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFF5A00)
                          : const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Horizontally Scrollable Scenario Cards with Interactive Snap Physics
        SizedBox(
          height: 116,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _scenarios.length,
            itemBuilder: (context, index) {
              final item = _scenarios[index];
              final isSelected = _selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  _selectCard(index);
                  // Deep-link to the card
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SituationCardScreen(cardId: item['id']!),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 220,
                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF17261F) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF5A00)
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0x33FF5A00)
                            : const Color(0x0A000000),
                        blurRadius: isSelected ? 12 : 6,
                        offset: const Offset(0, 3),
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
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFF5A00).withValues(alpha: 0.25)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                item['tag']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 8.0,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: isSelected
                                      ? const Color(0xFFFF8B4A)
                                      : const Color(0xFF4B5563),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10,
                            color: isSelected
                                ? Colors.white70
                                : const Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : const Color(0xFF17261F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['statute']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xFFFF8B4A)
                                  : const Color(0xFFFF5A00),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        item['action']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: isSelected
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFF6B7280),
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
    );
  }
}

/// Dynamic Scroll-to-Reveal Typography Block
class ScrollToRevealText extends StatefulWidget {
  final String quotation;
  final String attribution;

  const ScrollToRevealText({
    super.key,
    required this.quotation,
    required this.attribution,
  });

  @override
  State<ScrollToRevealText> createState() => _ScrollToRevealTextState();
}

class _ScrollToRevealTextState extends State<ScrollToRevealText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _revealFactor;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _revealFactor = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _revealFactor,
      builder: (context, child) {
        final words = widget.quotation.split(' ');
        final totalWords = words.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 4.0,
                runSpacing: 3.0,
                children: List.generate(totalWords, (i) {
                  final wordProgress = (i / totalWords);
                  final isRevealed = _revealFactor.value >= wordProgress;
                  final wordOpacity =
                      ((_revealFactor.value - wordProgress) * 4).clamp(0.2, 1.0);

                  return Opacity(
                    opacity: wordOpacity,
                    child: Text(
                      words[i],
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight:
                            isRevealed ? FontWeight.w800 : FontWeight.w600,
                        color: isRevealed
                            ? const Color(0xFF17261F)
                            : const Color(0xFF9CA3AF),
                        height: 1.4,
                        letterSpacing: 0.2,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
              Opacity(
                opacity: _revealFactor.value,
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 2,
                      color: const Color(0xFFFF5A00),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.attribution,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: const Color(0xFFFF5A00),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Editorial Legal & Safety Navigation Bar
class LegalSafetyBar extends StatelessWidget {
  final VoidCallback onLegalTerms;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onTermsOfService;
  final VoidCallback onSafetyBlog;
  final VoidCallback onSafetyCenter;
  final VoidCallback onCookies;

  const LegalSafetyBar({
    super.key,
    required this.onLegalTerms,
    required this.onPrivacyPolicy,
    required this.onTermsOfService,
    required this.onSafetyBlog,
    required this.onSafetyCenter,
    required this.onCookies,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPillLink('LEGAL TERMS', onLegalTerms),
          _buildDot(),
          _buildPillLink('PRIVACY POLICY', onPrivacyPolicy),
          _buildDot(),
          _buildPillLink('TERMS OF SERVICE', onTermsOfService),
          _buildDot(),
          _buildPillLink('SAFETY BLOG', onSafetyBlog, isAccent: true),
          _buildDot(),
          _buildPillLink('SAFETY CENTER (SOS)', onSafetyCenter, isEmergency: true),
          _buildDot(),
          _buildPillLink('COOKIES', onCookies),
        ],
      ),
    );
  }

  Widget _buildPillLink(String label, VoidCallback onTap,
      {bool isAccent = false, bool isEmergency = false}) {
    Color textColor = const Color(0xFF6B7280);
    if (isEmergency) {
      textColor = const Color(0xFFDC2626);
    } else if (isAccent) {
      textColor = const Color(0xFFFF5A00);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDot() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '•',
        style: TextStyle(
          color: Color(0xFFD1D5DB),
          fontSize: 10,
        ),
      ),
    );
  }
}

/// Floating Cookie & Consent Notice Banner
class CookieConsentPill extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onManage;

  const CookieConsentPill({
    super.key,
    required this.onAccept,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF17261F),
        borderRadius: AppRadii.pillBorder,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.privacy_tip_outlined,
            size: 16,
            color: Color(0xFFFF5A00),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'CIVIC stores essential cache under DPDP Act 2023.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onManage,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                'MANAGE',
                style: GoogleFonts.montserrat(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFFFF8B4A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5A00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.pillBorder),
            ),
            child: Text(
              'ACCEPT',
              style: GoogleFonts.montserrat(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
