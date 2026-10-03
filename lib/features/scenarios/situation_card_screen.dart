import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radii.dart';
import '../../data/models/content_models.dart';
import '../../data/repositories/content_repository.dart';

/// Screen presenting the full action protocol card for a scenario branch.
/// Strictly enforces Legal Safety Gates:
/// - In Release mode: hides unreviewed or expired content with emergency fallback.
/// - In Debug mode: displays card with a prominent unreviewed warning banner.
class SituationCardScreen extends StatefulWidget {
  final String cardId;
  final UserRole userRole;

  const SituationCardScreen({
    super.key,
    required this.cardId,
    this.userRole = UserRole.affected,
  });

  @override
  State<SituationCardScreen> createState() => _SituationCardScreenState();
}

class _SituationCardScreenState extends State<SituationCardScreen> {
  final ContentRepository _repository = ContentRepository.instance;
  CardModel? _card;
  bool _isLoading = true;
  late UserRole _currentRole;
  final Set<int> _checkedEvidenceIndices = {};
  Map<String, HelplineModel> _resolvedHelplines = {};

  @override
  void initState() {
    super.initState();
    _currentRole = widget.userRole;
    _loadCard();
  }

  Future<void> _loadCard() async {
    final card = await _repository.loadCard(widget.cardId);
    if (!mounted) return;

    if (card != null) {
      // Resolve all helplines for this card
      final helplines = await _repository.loadHelplines();
      final map = <String, HelplineModel>{};
      for (final h in helplines) {
        if (card.helplines.contains(h.id)) {
          map[h.id] = h;
        }
      }

      setState(() {
        _card = card;
        _resolvedHelplines = map;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showHelplineActionSheet(HelplineModel helpline) {
    final isVerified = helpline.lastVerified != 'UNVERIFIED';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            helpline.label,
                            style: AppTypography.headlineSmall.copyWith(fontSize: 16),
                          ),
                          Text(
                            helpline.category.toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    if (!isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.dontRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'UNVERIFIED',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.dontRed,
                            fontSize: 9,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: AppRadii.defaultBorder,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DIAL NUMBER:',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        helpline.number,
                        style: AppTypography.headlineLarge.copyWith(
                          fontSize: 26,
                          color: AppColors.primary,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        helpline.description,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Verification: ${helpline.lastVerified}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _copyToClipboard(helpline.number, helpline.label);
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('COPY NUMBER'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.defaultBorder,
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_card == null) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(title: const Text('PROTOCOL CARD'), backgroundColor: Colors.white),
        body: Center(
          child: Text(
            'Card "${widget.cardId}" not found.',
            style: AppTypography.bodyLarge,
          ),
        ),
      );
    }

    final card = _card!;
    final canDisplay = _repository.canDisplayCard(card);

    // ==============================================================
    // SAFETY GATE: In Release Mode, unreviewed/expired cards are hidden!
    // ==============================================================
    if (!canDisplay) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: Text(
            'LEGAL GUIDANCE PENDING',
            style: AppTypography.labelLarge.copyWith(
              letterSpacing: 1.5,
              color: AppColors.secondary,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 64,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 20),
                Text(
                  'GUIDANCE UNDER REVIEW',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.dontRedContainer,
                    borderRadius: AppRadii.defaultBorder,
                    border: Border.all(color: AppColors.dontRed.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    ContentRepository.releaseSafetyFallbackMessage,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.dontRed,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Immediate National Emergency Contacts:',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => _copyToClipboard('112', 'National Emergency 112'),
                  icon: const Icon(Icons.phone_in_talk_rounded),
                  label: const Text('DIAL 112 (NATIONAL EMERGENCY)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.dontRed,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.defaultBorder),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _copyToClipboard('15100', 'NALSA Legal Aid 15100'),
                  icon: const Icon(Icons.gavel_rounded, color: AppColors.primary),
                  label: const Text('LEGAL AID: 15100 (TELE-LAW)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.defaultBorder),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('RETURN TO SCENARIOS'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          'PROTOCOL // ${card.scenario.toUpperCase()}',
          style: AppTypography.labelLarge.copyWith(
            letterSpacing: 1.5,
            color: AppColors.secondary,
            fontSize: 13,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.borderSubtle, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==============================================================
              // WARNING BANNER (for debug mode or unreviewed cards)
              // ==============================================================
              if (!card.isReviewed || card.isExpired)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.doGreenContainer.withValues(alpha: 0.15),
                    borderRadius: AppRadii.defaultBorder,
                    border: Border.all(color: const Color(0xFFD97706)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.isExpired ? 'EXPIRED REVIEW NOTICE' : 'PENDING LAWYER REVIEW',
                              style: AppTypography.labelSmall.copyWith(
                                color: const Color(0xFFD97706),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card.isExpired
                                  ? 'This card\'s advocate review expired on ${card.validUntil?.toIso8601String().substring(0, 10)}. Content requires re-verification.'
                                  : 'This card contains draft protocol material pending advocate sign-off. Placeholder content only.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Title and Branch header
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.defaultBorder,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'BRANCH: ${card.branch.toUpperCase()}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            card.status.toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.secondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      card.title,
                      style: AppTypography.headlineSmall.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Role Switcher Chips
              Text(
                'YOUR ROLE IN THIS INCIDENT:',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: UserRole.values.map((role) {
                    final isSelected = _currentRole == role;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(role.displayName),
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                        labelStyle: AppTypography.labelSmall.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                        ),
                        backgroundColor: Colors.white,
                        onSelected: (_) {
                          setState(() => _currentRole = role);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // ==============================================================
              // SECTION 1: SHORT LINES (Strictly Max 7)
              // ==============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'IMMEDIATE ACTION PROTOCOL',
                    style: AppTypography.labelLarge.copyWith(letterSpacing: 1.2),
                  ),
                  Text(
                    '${card.shortLines.length}/7 STEPS',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.defaultBorder,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: List.generate(card.shortLines.length, (index) {
                    final step = card.shortLines[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == card.shortLines.length - 1 ? 0 : 14.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // ==============================================================
              // SECTION 2: WHAT TO SAY (Voice Script)
              // ==============================================================
              if (card.voiceScript.isNotEmpty) ...[
                Text(
                  'EXACT SCRIPT TO SAY',
                  style: AppTypography.labelLarge.copyWith(letterSpacing: 1.2),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: AppRadii.defaultBorder,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.record_voice_over_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'CALM CITIZEN STATEMENT',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Copy script',
                            onPressed: () => _copyToClipboard(card.voiceScript, 'Voice script'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '“${card.voiceScript}”',
                        style: AppTypography.bodyMedium.copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ==============================================================
              // SECTION 3: DOs & DON'Ts
              // ==============================================================
              Text(
                'CRITICAL RULES OF ENGAGEMENT',
                style: AppTypography.labelLarge.copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 10),
              // DO LIST
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.doGreenContainer.withValues(alpha: 0.3),
                  borderRadius: AppRadii.defaultBorder,
                  border: Border.all(color: AppColors.doGreen.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.doGreen, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'MANDATORY ACTIONS (DO)',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.doGreen,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...card.doList.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: AppColors.doGreen, fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(
                                  item,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              // DONT LIST
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.dontRedContainer.withValues(alpha: 0.3),
                  borderRadius: AppRadii.defaultBorder,
                  border: Border.all(color: AppColors.dontRed.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cancel_rounded, color: AppColors.dontRed, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'PROHIBITED ACTIONS (DO NOT)',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.dontRed,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...card.dontList.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: AppColors.dontRed, fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(
                                  item,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

              // ==============================================================
              // SECTION 4: LEGAL BASIS
              // ==============================================================
              Text(
                'STATUTORY & CONSTITUTIONAL BASIS',
                style: AppTypography.labelLarge.copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 10),
              ...card.legalBasis.map((lb) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.defaultBorder,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              lb.act,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          if (lb.section.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.canvas,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Text(
                                'SEC ${lb.section}',
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lb.status,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),

              // ==============================================================
              // SECTION 5: HELPLINES
              // ==============================================================
              if (card.helplines.isNotEmpty) ...[
                Text(
                  'DESIGNATED EMERGENCY HELPLINES',
                  style: AppTypography.labelLarge.copyWith(letterSpacing: 1.2),
                ),
                const SizedBox(height: 10),
                ...card.helplines.map((hid) {
                  final helpline = _resolvedHelplines[hid];
                  if (helpline == null) {
                    return const SizedBox.shrink();
                  }
                  final isVerified = helpline.lastVerified != 'UNVERIFIED';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: OutlinedButton(
                      onPressed: () => _showHelplineActionSheet(helpline),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.borderOutline),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadii.defaultBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        helpline.label,
                                        style: AppTypography.headlineSmall.copyWith(fontSize: 15),
                                      ),
                                    ),
                                    if (!isVerified)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.dontRed.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'UNVERIFIED',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.dontRed,
                                            fontSize: 8.5,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Dial: ${helpline.number} • ${helpline.description}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.secondary, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],

              // ==============================================================
              // SECTION 6: EVIDENCE CHECKLIST
              // ==============================================================
              if (card.evidenceChecklist.isNotEmpty) ...[
                Text(
                  'EVIDENCE PRESERVATION CHECKLIST',
                  style: AppTypography.labelLarge.copyWith(letterSpacing: 1.2),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.defaultBorder,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    children: List.generate(card.evidenceChecklist.length, (index) {
                      final item = card.evidenceChecklist[index];
                      final isChecked = _checkedEvidenceIndices.contains(index);

                      return CheckboxListTile(
                        value: isChecked,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                        title: Text(
                          item,
                          style: AppTypography.bodySmall.copyWith(
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                            color: isChecked ? AppColors.textMuted : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _checkedEvidenceIndices.add(index);
                            } else {
                              _checkedEvidenceIndices.remove(index);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ==============================================================
              // SECTION 7: VERIFICATION FOOTER
              // ==============================================================
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: AppRadii.defaultBorder,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VERIFICATION AUDIT LOG',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Reviewed By: ${card.reviewedBy.isEmpty ? "Pending Advocate Review" : card.reviewedBy}',
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (card.reviewedOn != null)
                      Text(
                        'Reviewed Date: ${card.reviewedOn!.toIso8601String().substring(0, 10)}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    if (card.validUntil != null)
                      Text(
                        'Valid Until: ${card.validUntil!.toIso8601String().substring(0, 10)}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
