import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radii.dart';
import '../../../data/content_loader.dart';
import '../../../data/services/app_preferences.dart';
import '../../scenarios/situation_list_screen.dart';

/// Home tab screen displaying active rights hub, emergency SOS shortcuts,
/// and first-launch state jurisdiction picker.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _guides = [];
  bool _showStateCard = false;
  String _selectedState = 'ALL';

  static const Map<String, String> _indianStates = {
    'ALL': 'All-India (National Rules)',
    'DL': 'Delhi NCT',
    'MH': 'Maharashtra',
    'KA': 'Karnataka',
    'TN': 'Tamil Nadu',
    'UP': 'Uttar Pradesh',
    'WB': 'West Bengal',
    'TG': 'Telangana',
    'GJ': 'Gujarat',
    'RJ': 'Rajasthan',
    'KL': 'Kerala',
    'MP': 'Madhya Pradesh',
    'AP': 'Andhra Pradesh',
    'PB': 'Punjab',
    'HR': 'Haryana',
    'BR': 'Bihar',
    'OD': 'Odisha',
    'AS': 'Assam',
    'JH': 'Jharkhand',
    'UT': 'Uttarakhand',
    'HP': 'Himachal Pradesh',
    'GA': 'Goa',
    'CH': 'Chandigarh',
    'JK': 'Jammu & Kashmir',
  };

  @override
  void initState() {
    super.initState();
    _showStateCard = !AppPreferences.isStateCardDismissed;
    _selectedState = AppPreferences.selectedState;
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ContentLoader.loadSampleContent();
    if (mounted && data.containsKey('quickGuides')) {
      setState(() {
        _guides = data['quickGuides'] as List<dynamic>;
      });
    }
  }

  void _dismissStateCard() {
    setState(() {
      _showStateCard = false;
    });
    AppPreferences.setStateCardDismissed(true);
  }

  void _saveStateSelection(String stateCode) {
    setState(() {
      _selectedState = stateCode;
      _showStateCard = false;
    });
    AppPreferences.setSelectedState(stateCode);
    AppPreferences.setStateCardDismissed(true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Jurisdiction set to ${_indianStates[stateCode] ?? stateCode}'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSituationList() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SituationListScreen()),
    );
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/civic_logo.png',
                        width: 38,
                        height: 38,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CIVIC // CITIZEN',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'RIGHTS HUB',
                            style: AppTypography.headlineLarge.copyWith(
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Jurisdiction indicator chip
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showStateCard = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppRadii.pillBorder,
                            border: Border.all(color: AppColors.borderOutline),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                _selectedState == 'ALL' ? 'ALL-INDIA' : _selectedState,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderOutline),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ==============================================================
              // FIRST LAUNCH DISMISSIBLE CARD: "Choose your state for local rules"
              // ==============================================================
              if (_showStateCard) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.defaultBorder,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.pin_drop_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'CHOOSE YOUR STATE FOR LOCAL RULES',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Dismiss',
                            onPressed: _dismissStateCard,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select your state to prioritize local police guidelines, state tenancy acts, and campus regulations. Content defaults to all-India rules until chosen.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderOutline),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _indianStates.containsKey(_selectedState) ? _selectedState : 'ALL',
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                            items: _indianStates.entries.map((entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(
                                  entry.value,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                _saveStateSelection(val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Emergency SOS Banner (Interactive)
              InkWell(
                onTap: _openSituationList,
                borderRadius: AppRadii.defaultBorder,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.dontRedContainer,
                    borderRadius: AppRadii.defaultBorder,
                    border: Border.all(color: AppColors.dontRed.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.dontRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EMERGENCY DETENTION SOS',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.dontRed,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Immediate guidance on arrest protocols and mandatory legal counsel access.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.dontRed,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Section Title with View All button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FEATURED CITIZEN PROTOCOLS',
                    style: AppTypography.labelLarge.copyWith(
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextButton(
                    onPressed: _openSituationList,
                    child: Text(
                      'VIEW ALL (44+)',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Quick Guides List
              if (_guides.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                ..._guides.map((guide) {
                  final category = guide['category'] ?? 'CIVIC';
                  final title = guide['title'] ?? '';
                  final subtitle = guide['subtitle'] ?? '';
                  final readTime = guide['readTime'] ?? '3 MIN READ';

                  return InkWell(
                    onTap: _openSituationList,
                    borderRadius: AppRadii.defaultBorder,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadii.defaultBorder,
                        border: Border.all(color: AppColors.borderSubtle, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              Text(
                                readTime,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
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
