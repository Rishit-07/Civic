import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radii.dart';
import '../../../data/content_loader.dart';

/// Prepare tab placeholder screen matching Stitch design system
class PrepareScreen extends StatefulWidget {
  const PrepareScreen({super.key});

  @override
  State<PrepareScreen> createState() => _PrepareScreenState();
}

class _PrepareScreenState extends State<PrepareScreen> {
  List<dynamic> _checklists = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ContentLoader.loadSampleContent();
    if (mounted && data.containsKey('prepareChecklists')) {
      setState(() {
        _checklists = data['prepareChecklists'] as List<dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PREPARE // READINESS',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ACTION CHECKLISTS',
                style: AppTypography.headlineLarge.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                'Equip yourself with standardized documentation and emergency contact chains before critical encounters.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),

              if (_checklists.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                ..._checklists.map((item) {
                  final title = item['title'] ?? '';
                  final count = item['itemsCount'] ?? 0;
                  final status = item['status'] ?? 'Ready';
                  final description = item['description'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: AppTypography.headlineSmall.copyWith(fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer,
                                borderRadius: AppRadii.pillBorder,
                              ),
                              child: Text(
                                status,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.doGreen),
                            const SizedBox(width: 6),
                            Text(
                              '$count Key Checkpoints Configured',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.doGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
