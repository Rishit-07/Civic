import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radii.dart';
import '../../../data/content_loader.dart';

/// Help tab placeholder screen matching Stitch design system
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  List<dynamic> _helplines = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ContentLoader.loadSampleContent();
    if (mounted && data.containsKey('helpHelplines')) {
      setState(() {
        _helplines = data['helpHelplines'] as List<dynamic>;
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
                'HELP // ASSISTANCE',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'OFFICIAL HELPLINES',
                style: AppTypography.headlineLarge.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                'Verified toll-free emergency response and legal aid contact channels.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),

              if (_helplines.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                ..._helplines.map((item) {
                  final title = item['title'] ?? '';
                  final number = item['number'] ?? '';
                  final badge = item['badge'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadii.defaultBorder,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: AppRadii.pillBorder,
                                ),
                                child: Text(
                                  badge,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                title,
                                style: AppTypography.headlineSmall.copyWith(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: AppRadii.pillBorder,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.call_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                number,
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
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
