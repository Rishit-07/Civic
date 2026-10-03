import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tabs/home/home_screen.dart';
import '../tabs/prepare/prepare_screen.dart';
import '../tabs/notes/notes_screen.dart';
import '../tabs/ask/ask_screen.dart';
import '../tabs/help/help_screen.dart';

/// Main navigation scaffold with bottom tab bar matching CIVIC design standards
class MainTabScaffold extends StatefulWidget {
  const MainTabScaffold({super.key});

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PrepareScreen(),
    NotesScreen(),
    AskScreen(),
    HelpScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9).withValues(alpha: 0.95),
          border: const Border(
            top: BorderSide(
              color: Color(0xFFE8E8E8),
              width: 1.0,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              selectedItemColor: const Color(0xFFFF5A00),
              unselectedItemColor: const Color(0xFF526259),
              selectedLabelStyle: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.shield_outlined, size: 22),
                  activeIcon: Icon(Icons.shield_rounded, size: 22),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.checklist_rounded, size: 22),
                  activeIcon: Icon(Icons.checklist_rounded, size: 22),
                  label: 'Prepare',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.folder_shared_outlined, size: 22),
                  activeIcon: Icon(Icons.folder_shared_rounded, size: 22),
                  label: 'Notes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.forum_outlined, size: 22),
                  activeIcon: Icon(Icons.forum_rounded, size: 22),
                  label: 'Ask',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.help_center_outlined, size: 22),
                  activeIcon: Icon(Icons.help_center_rounded, size: 22),
                  label: 'Help',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
