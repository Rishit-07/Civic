import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radii.dart';
import '../../data/models/content_models.dart';
import '../../data/repositories/content_repository.dart';
import '../scenarios/situation_card_screen.dart';

/// Debug screen listing all scenarios and branches with their current verification status
/// (placeholder, drafted, reviewed, expired), total metrics, and review percentages.
class ContentStatusScreen extends StatefulWidget {
  const ContentStatusScreen({super.key});

  @override
  State<ContentStatusScreen> createState() => _ContentStatusScreenState();
}

class _ContentStatusScreenState extends State<ContentStatusScreen> {
  final ContentRepository _repository = ContentRepository.instance;
  List<CardModel> _allCards = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    final cards = await _repository.loadAllCards();
    if (mounted) {
      setState(() {
        _allCards = cards;
        _isLoading = false;
      });
    }
  }

  int get _totalCards => _allCards.length;
  int get _reviewedCards => _allCards.where((c) => c.status == 'reviewed').length;
  int get _placeholderCards => _allCards.where((c) => c.status == 'placeholder').length;
  int get _draftedCards => _allCards.where((c) => c.status == 'drafted').length;
  int get _expiredCards => _allCards.where((c) => c.status == 'expired').length;

  double get _reviewedPercent => _totalCards == 0 ? 0.0 : (_reviewedCards / _totalCards) * 100;

  List<CardModel> get _filteredCards {
    return _allCards.where((card) {
      if (_selectedStatusFilter != 'all' && card.status != _selectedStatusFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return card.id.toLowerCase().contains(q) ||
            card.title.toLowerCase().contains(q) ||
            card.scenario.toLowerCase().contains(q) ||
            card.branch.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'reviewed':
        return AppColors.doGreen;
      case 'expired':
        return AppColors.dontRed;
      case 'drafted':
        return const Color(0xFFD97706);
      case 'placeholder':
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          'CONTENT AUDIT // DEBUG',
          style: AppTypography.labelLarge.copyWith(
            letterSpacing: 1.5,
            color: AppColors.secondary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Reload cards',
            onPressed: _loadStatus,
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
                // Top Metrics Dashboard
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'LEGAL VERIFICATION PROGRESS',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '${_reviewedPercent.toStringAsFixed(1)}% REVIEWED',
                            style: AppTypography.labelSmall.copyWith(
                              color: _reviewedPercent > 0 ? AppColors.doGreen : AppColors.textMuted,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _totalCards == 0 ? 0 : (_reviewedCards / _totalCards),
                          backgroundColor: AppColors.borderSubtle,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.doGreen),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildMetricBadge('TOTAL', '$_totalCards', AppColors.secondary),
                          const SizedBox(width: 8),
                          _buildMetricBadge('REVIEWED', '$_reviewedCards', AppColors.doGreen),
                          const SizedBox(width: 8),
                          _buildMetricBadge('DRAFTED', '$_draftedCards', const Color(0xFFD97706)),
                          const SizedBox(width: 8),
                          _buildMetricBadge('PLACEHOLDER', '$_placeholderCards', AppColors.textMuted),
                          const SizedBox(width: 8),
                          _buildMetricBadge('EXPIRED', '$_expiredCards', AppColors.dontRed),
                        ],
                      ),
                    ],
                  ),
                ),

                // Search & Filter Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search scenario or branch ID...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: AppRadii.defaultBorder,
                            borderSide: const BorderSide(color: AppColors.borderOutline),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'all',
                            'placeholder',
                            'drafted',
                            'reviewed',
                            'expired',
                          ].map((st) {
                            final isSel = _selectedStatusFilter == st;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: ChoiceChip(
                                label: Text(st.toUpperCase()),
                                selected: isSel,
                                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                                labelStyle: AppTypography.labelSmall.copyWith(
                                  color: isSel ? AppColors.primary : AppColors.textPrimary,
                                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                                  fontSize: 10,
                                ),
                                onSelected: (_) => setState(() => _selectedStatusFilter = st),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Card List
                Expanded(
                  child: _filteredCards.isEmpty
                      ? Center(
                          child: Text(
                            'No matching cards found.',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredCards.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final card = _filteredCards[index];
                            final statusColor = _getStatusColor(card.status);

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SituationCardScreen(cardId: card.id),
                                  ),
                                );
                              },
                              borderRadius: AppRadii.defaultBorder,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppRadii.defaultBorder,
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(3),
                                                ),
                                                child: Text(
                                                  card.status.toUpperCase(),
                                                  style: AppTypography.labelSmall.copyWith(
                                                    color: statusColor,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 9.5,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                card.id,
                                                style: AppTypography.labelSmall.copyWith(
                                                  color: AppColors.textMuted,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            card.title,
                                            style: AppTypography.headlineSmall.copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Reviewer: ${card.reviewedBy.isEmpty ? "None" : card.reviewedBy} • Steps: ${card.shortLines.length}/7',
                                            style: AppTypography.bodySmall.copyWith(
                                              color: AppColors.textMuted,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.secondary,
                                      size: 20,
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

  Widget _buildMetricBadge(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
