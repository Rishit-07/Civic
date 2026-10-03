import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radii.dart';
import '../../data/models/content_models.dart';
import 'situation_card_screen.dart';

/// Data-driven Triage Screen presenting situational questions,
/// role selector, and the mandatory "Skip, show me what to do now" bypass button.
class TriageScreen extends StatefulWidget {
  final Scenario scenario;

  const TriageScreen({super.key, required this.scenario});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  UserRole _selectedRole = UserRole.affected;
  int _currentQuestionIndex = 0;

  void _navigateToCard(String branch) {
    final cardId = '${widget.scenario.id}_$branch';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SituationCardScreen(
          cardId: cardId,
          userRole: _selectedRole,
        ),
      ),
    );
  }

  void _skipToDefault() {
    _navigateToCard('default');
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.scenario.triageQuestions;
    final hasQuestions = questions.isNotEmpty;
    final currentQuestion = hasQuestions ? questions[_currentQuestionIndex] : null;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          'TRIAGE PROTOCOL',
          style: AppTypography.labelLarge.copyWith(
            letterSpacing: 2.0,
            color: AppColors.secondary,
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.defaultBorder,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCENARIO ASSESSMENT',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.scenario.label,
                      style: AppTypography.headlineSmall.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.scenario.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Role Selector Section
              Text(
                'WHAT IS YOUR INVOLVEMENT?',
                style: AppTypography.labelSmall.copyWith(
                  letterSpacing: 1.4,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: UserRole.values.map((role) {
                  final isSelected = _selectedRole == role;
                  return ChoiceChip(
                    label: Text(role.label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedRole = role),
                    selectedColor: AppColors.secondary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Interactive Question Card
              if (currentQuestion != null) ...[
                Text(
                  'QUESTION ${_currentQuestionIndex + 1} OF ${questions.length}',
                  style: AppTypography.labelSmall.copyWith(
                    letterSpacing: 1.4,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentQuestion.text,
                  style: AppTypography.headlineSmall.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                ...currentQuestion.options.map((option) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: OutlinedButton(
                      onPressed: () {
                        if (_currentQuestionIndex + 1 < questions.length) {
                          setState(() {
                            _currentQuestionIndex++;
                          });
                        } else {
                          _navigateToCard(option.branch);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.borderOutline),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.defaultBorder,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.label,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 18),

              // Mandatory "Skip, show me what to do now" button
              Center(
                child: TextButton.icon(
                  onPressed: _skipToDefault,
                  icon: const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 18),
                  label: Text(
                    'Skip, show me what to do now',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
