import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/responsive_layout.dart';
import '../../data/models/content_models.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/services/app_preferences.dart';
import '../navigation/main_tab_scaffold.dart';
import '../onboarding/onboarding_screen.dart';

/// Loading screen with progress bar matching the Stitch design.
/// Checks for content updates in the background without blocking,
/// auto-advancing after ~2 seconds (Splash > Home for returning users,
/// Splash > Landing for first-time users).
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Background content check (non-blocking)
    ContentRepository.instance.loadCategories().catchError((_) => <Category>[]);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          final isReturning = AppPreferences.isFirstLaunchComplete;
          final Widget destination = isReturning
              ? const MainTabScaffold()
              : const OnboardingScreen();

          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, anim1, anim2) => destination,
              transitionsBuilder: (context, anim1, anim2, child) {
                return FadeTransition(opacity: anim1, child: child);
              },
              transitionDuration: const Duration(milliseconds: 350),
            ),
          );
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isCompact = mediaQuery.size.height < 700;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: ResponsiveLayout(
        child: SafeArea(
          child: Stack(
          children: [
            // Architectural background accent shapes
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: AppColors.blobBackground,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Official Brand Logo Emblem
                    Image.asset(
                      'assets/images/civic_logo.png',
                      width: 96,
                      height: 96,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'CIVIC',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 26,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle / Tagline
                    Text(
                      'CIVIC LEGAL EMPOWERMENT',
                      style: AppTypography.labelSmall.copyWith(
                        letterSpacing: 2.0,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: isCompact ? 32 : 52),

                    // Progress Bar Container
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: AppRadii.pillBorder,
                              child: Container(
                                height: 6,
                                width: double.infinity,
                                color: AppColors.surfaceContainerHigh,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: _progressAnimation.value,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: AppRadii.pillBorder,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'INITIALIZING GUIDES...',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  '${(_progressAnimation.value * 100).toInt()}%',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
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
