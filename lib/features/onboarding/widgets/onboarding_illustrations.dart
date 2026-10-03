import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Clean Neo-Constructivist vector illustrations rendered directly from Stitch design SVGs
class OnboardingIllustration extends StatelessWidget {
  final int slideIndex;
  final double height;

  const OnboardingIllustration({
    super.key,
    required this.slideIndex,
    this.height = 280,
  });

  @override
  Widget build(BuildContext context) {
    String assetPath;
    switch (slideIndex) {
      case 0:
        assetPath = 'assets/images/slide1_know.svg';
        break;
      case 1:
        assetPath = 'assets/images/slide2_prepare.svg';
        break;
      case 2:
      default:
        assetPath = 'assets/images/slide3_act.svg';
        break;
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Center(
        child: SvgPicture.asset(
          assetPath,
          height: height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
