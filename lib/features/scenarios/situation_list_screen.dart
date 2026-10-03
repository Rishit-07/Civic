import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radii.dart';
import '../../data/models/content_models.dart';
import '../../data/repositories/content_repository.dart';
import 'triage_screen.dart';
import '../debug/content_status_screen.dart';

/// Data-driven Situation List Screen displaying all categories and scenarios.
/// Adding a scenario to index.json requires zero new Flutter code.
class SituationListScreen extends StatefulWidget {
  const SituationListScreen({super.key});

  @override
  State<SituationListScreen> createState() => _SituationListScreenState();
}

class _SituationListScreenState extends State<SituationListScreen> {
  final ContentRepository _repository = ContentRepository.instance;
  List<Category> _categories = [];
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final cats = await _repository.loadCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Scenario> get _filteredScenarios {
    final list = <Scenario>[];
    for (final cat in _categories) {
      if (_selectedCategoryId == 'all' || cat.id == _selectedCategoryId) {
        for (final sc in cat.scenarios) {
          if (_searchQuery.isEmpty ||
              sc.label.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              sc.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
            list.add(sc);
          }
        }
      }
    }
    return list;
  }

  Color _getUrgencyColor(int urgency) {
    switch (urgency) {
      case 1:
        return AppColors.dontRed;
      case 2:
        return AppColors.primary;
      case 3:
      default:
        return AppColors.secondary;
    }
  }

  String _getUrgencyLabel(int urgency) {
    switch (urgency) {
      case 1:
        return 'TIER 1 // IMMEDIATE';
      case 2:
        return 'TIER 2 // URGENT';
      case 3:
      default:
        return 'TIER 3 // STANDARD';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          'LEGAL ENCOUNTERS',
          style: AppTypography.labelLarge.copyWith(
            letterSpacing: 2.0,
            color: AppColors.secondary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Debug Content Status entry point
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: AppColors.primary),
            tooltip: 'Content Status (Debug)',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ContentStatusScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.borderSubtle, height: 1.0),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Search Input
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search scenarios (e.g. traffic, FIR, ragging)...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: AppRadii.defaultBorder,
                        borderSide: const BorderSide(color: AppColors.borderOutline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadii.defaultBorder,
                        borderSide: const BorderSide(color: AppColors.borderOutline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadii.defaultBorder,
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),

                // Category Chips Selector
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: const Text('ALL CATEGORIES'),
                          selected: _selectedCategoryId == 'all',
                          onSelected: (_) => setState(() => _selectedCategoryId = 'all'),
                          selectedColor: AppColors.secondary,
                          labelStyle: TextStyle(
                            color: _selectedCategoryId == 'all' ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      ..._categories.map((cat) {
                        final isSelected = _selectedCategoryId == cat.id;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(cat.label),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedCategoryId = cat.id),
                            selectedColor: AppColors.secondary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Scenario Cards List
                Expanded(
                  child: _filteredScenarios.isEmpty
                      ? Center(
                          child: Text(
                            'No matching scenarios found.',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20.0),
                          itemCount: _filteredScenarios.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final sc = _filteredScenarios[index];
                            final urgencyColor = _getUrgencyColor(sc.urgency);

                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => TriageScreen(scenario: sc),
                                  ),
                                );
                              },
                              borderRadius: AppRadii.defaultBorder,
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppRadii.defaultBorder,
                                  border: Border.all(color: AppColors.borderSubtle),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x06000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Urgency Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: urgencyColor.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _getUrgencyLabel(sc.urgency),
                                            style: AppTypography.labelSmall.copyWith(
                                              color: urgencyColor,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${sc.branches.length} BRANCHES',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.textMuted,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      sc.label,
                                      style: AppTypography.headlineSmall.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      sc.description,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textPrimary.withValues(alpha: 0.75),
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'VIEW PROTOCOL',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 14,
                                          color: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
