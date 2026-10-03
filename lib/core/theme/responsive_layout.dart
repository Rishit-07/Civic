import 'package:flutter/material.dart';

/// Responsive layout helper ensuring content has optimal width
/// on wide laptop/desktop displays while allowing backgrounds
/// to flow naturally across the page.
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = 640.0,
    this.backgroundColor,
  });

  /// Check if the viewport is a wide screen (laptop/desktop/tablet)
  static bool isWide(BuildContext context) {
    return MediaQuery.sizeOf(context).width > 700;
  }

  /// Check if the viewport is compact height
  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).height < 740;
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? const Color(0xFFFAFAFA);

    return Container(
      color: bg,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
