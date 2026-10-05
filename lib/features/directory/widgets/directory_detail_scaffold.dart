import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable high-contrast editorial scaffold for CIVIC legal directory & protocol pages.
class DirectoryDetailScaffold extends StatelessWidget {
  final String title;
  final String category;
  final String badgeText;
  final String subtitle;
  final List<Widget> children;
  final Widget? floatingActionButton;

  const DirectoryDetailScaffold({
    super.key,
    required this.title,
    required this.category,
    this.badgeText = 'STATUTORY REFERENCE',
    required this.subtitle,
    required this.children,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF17261F), size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/civic_logo.png',
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              'CIVIC',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: const Color(0xFF17261F),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB800),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'PRO-BONO',
                style: GoogleFonts.montserrat(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0E1116),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined,
                color: Color(0xFF17261F), size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(
                  text: 'CIVIC Legal Directory: $title - $subtitle'));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied link & summary for "$title"'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE2E4EB),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 48.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Badge Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5A00).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: const Color(0xFFFF5A00),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: GoogleFonts.montserrat(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Main H1 Title
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF17261F),
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Divider(color: Color(0xFFECEEF2), thickness: 1),
                  const SizedBox(height: 16),

                  // Main Page Contents
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper card widgets for directory pages
class DirectoryCard extends StatelessWidget {
  final String title;
  final String? statute;
  final String body;
  final IconData? icon;
  final Color? accentColor;
  final List<Widget>? actions;

  const DirectoryCard({
    super.key,
    required this.title,
    this.statute,
    required this.body,
    this.icon,
    this.accentColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (accentColor ?? const Color(0xFFFF5A00))
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: accentColor ?? const Color(0xFFFF5A00),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF17261F),
                        height: 1.25,
                      ),
                    ),
                    if (statute != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        statute!,
                        style: GoogleFonts.montserrat(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF5A00),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.6,
              color: const Color(0xFF374151),
            ),
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}
