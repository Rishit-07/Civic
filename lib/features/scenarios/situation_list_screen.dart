import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/content_models.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/services/app_preferences.dart';
import 'triage_screen.dart';

/// Premium Legal Encounters screen based on CIVIC Neo-Constructivist design system.
/// Displays a 2-column category grid with icons, tags, scenario descriptions,
/// legal references, search/filter, and voice filter placeholder.
class SituationListScreen extends StatefulWidget {
  final String? initialCategoryId;
  final String? initialSearchQuery;

  const SituationListScreen({
    super.key,
    this.initialCategoryId,
    this.initialSearchQuery,
  });

  @override
  State<SituationListScreen> createState() => _SituationListScreenState();
}

class _SituationListScreenState extends State<SituationListScreen> {
  final ContentRepository _repository = ContentRepository.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Category> _categories = [];
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  bool _isLoading = true;
  int _currentPage = 1;
  static const int _scenariosPerPage = 5;
  String _selectedRole = 'all'; // 'all', 'affected', 'accused', 'witness', 'parent'

  @override
  void initState() {
    super.initState();
    final cached = _repository.categoriesCache;
    if (cached != null && cached.isNotEmpty) {
      _categories = cached;
      _isLoading = false;
    }
    if (widget.initialSearchQuery != null &&
        widget.initialSearchQuery!.isNotEmpty) {
      _searchQuery = widget.initialSearchQuery!;
      _searchController.text = _searchQuery;
    }
    _selectedCategoryId = widget.initialCategoryId ?? 'all';
    _selectedRole = AppPreferences.selectedRole;
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final cats = await _repository.loadCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _selectedCategoryId = _resolveCategoryId(_selectedCategoryId, cats);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _resolveCategoryId(String? rawId, List<Category> availableCategories) {
    if (rawId == null || rawId.trim().isEmpty || rawId.toLowerCase() == 'all') {
      return 'all';
    }
    final target = rawId.toLowerCase().trim();

    for (final cat in availableCategories) {
      if (cat.id.toLowerCase() == target) return cat.id;
    }

    const aliases = <String, String>{
      'police_criminal': 'police_criminal',
      'police': 'police_criminal',
      'criminal': 'police_criminal',
      'traffic': 'police_criminal',
      'campus_education': 'campus',
      'campus': 'campus',
      'education': 'campus',
      'ragging': 'campus',
      'couples_privacy': 'couples_public',
      'couples_public': 'couples_public',
      'couples': 'couples_public',
      'privacy': 'couples_public',
      'cyber_fraud': 'online_money',
      'online_money': 'online_money',
      'cyber': 'online_money',
      'fraud': 'online_money',
      'online': 'online_money',
      'money': 'online_money',
      'workplace_employment': 'work',
      'workplace': 'work',
      'work': 'work',
      'employment': 'work',
      'housing_tenancy': 'housing',
      'housing_property': 'housing',
      'housing': 'housing',
      'tenancy': 'housing',
      'family_safety': 'family_safety',
      'family': 'family_safety',
      'consumer_documents': 'consumer_documents',
      'consumer': 'consumer_documents',
    };

    if (aliases.containsKey(target)) {
      final aliasedId = aliases[target]!;
      for (final cat in availableCategories) {
        if (cat.id.toLowerCase() == aliasedId) return cat.id;
      }
    }

    for (final cat in availableCategories) {
      final catId = cat.id.toLowerCase();
      final catLabel = cat.label.toLowerCase();
      if (target.contains(catId) ||
          catId.contains(target) ||
          target.contains(catLabel) ||
          catLabel.contains(target)) {
        return cat.id;
      }
    }

    return 'all';
  }

  bool _scenarioMatchesRole(Scenario sc, String role) {
    if (role == 'all') return true;
    final r = role.toLowerCase().trim();
    final text = '${sc.id} ${sc.label} ${sc.description}'.toLowerCase();

    switch (r) {
      case 'accused':
        return text.contains('arrest') ||
            text.contains('detention') ||
            text.contains('traffic') ||
            text.contains('stop') ||
            text.contains('41a') ||
            text.contains('notice') ||
            text.contains('cheque') ||
            text.contains('fir') ||
            text.contains('custody') ||
            text.contains('search') ||
            text.contains('alcohol') ||
            text.contains('challan') ||
            text.contains('phone') ||
            text.contains('device') ||
            text.contains('seizure') ||
            text.contains('interrogation') ||
            text.contains('suspect') ||
            text.contains('accused') ||
            text.contains('bribe') ||
            text.contains('bail') ||
            text.contains('warrant') ||
            text.contains('summon');

      case 'witness':
        return text.contains('good samaritan') ||
            text.contains('samaritan') ||
            text.contains('accident') ||
            text.contains('witness') ||
            text.contains('bystander') ||
            text.contains('helpless') ||
            text.contains('bribe') ||
            text.contains('noise') ||
            text.contains('animal') ||
            text.contains('feeder') ||
            text.contains('stray') ||
            text.contains('statement') ||
            text.contains('cyber') ||
            text.contains('fraud') ||
            text.contains('1930') ||
            text.contains('helpline') ||
            text.contains('evidence');

      case 'parent':
        return text.contains('ragging') ||
            text.contains('campus') ||
            text.contains('hostel') ||
            text.contains('student') ||
            text.contains('college') ||
            text.contains('school') ||
            text.contains('minor') ||
            text.contains('child') ||
            text.contains('pocso') ||
            text.contains('cyberbullying') ||
            text.contains('maintenance') ||
            text.contains('senior citizen') ||
            text.contains('parents') ||
            text.contains('family') ||
            text.contains('custody');

      case 'affected':
      default:
        return true;
    }
  }

  List<Category> get _filteredCategories {
    if (_searchQuery.isEmpty && _selectedCategoryId == 'all' && _selectedRole == 'all') {
      return _categories;
    }

    final query = _searchQuery.toLowerCase();
    return _categories.where((cat) {
      // Category chip filter
      if (_selectedCategoryId != 'all' && cat.id != _selectedCategoryId) {
        return false;
      }

      final matchingScenarios = cat.scenarios.where((sc) {
        final matchesRole = _scenarioMatchesRole(sc, _selectedRole);
        if (!matchesRole) return false;
        if (query.isEmpty) return true;
        return sc.label.toLowerCase().contains(query) ||
            sc.description.toLowerCase().contains(query) ||
            sc.id.toLowerCase().contains(query);
      }).toList();

      if (query.isNotEmpty) {
        final catMatch = cat.label.toLowerCase().contains(query) ||
            cat.description.toLowerCase().contains(query);
        return catMatch || matchingScenarios.isNotEmpty;
      }

      if (_selectedRole != 'all') {
        return matchingScenarios.isNotEmpty;
      }

      return true;
    }).toList();
  }

  List<Scenario> _filteredScenariosFor(Category cat) {
    final query = _searchQuery.toLowerCase();
    return cat.scenarios.where((sc) {
      if (!_scenarioMatchesRole(sc, _selectedRole)) return false;
      if (query.isEmpty) return true;
      return sc.label.toLowerCase().contains(query) ||
          sc.description.toLowerCase().contains(query);
    }).toList();
  }

  /// Live matching scenarios across all loaded categories
  List<({Scenario scenario, Category category})> get _matchingScenarios {
    final q = _searchQuery.toLowerCase();
    final results = <({Scenario scenario, Category category})>[];
    for (final cat in _categories) {
      if (_selectedCategoryId != 'all' && cat.id != _selectedCategoryId) continue;
      for (final sc in cat.scenarios) {
        if (!_scenarioMatchesRole(sc, _selectedRole)) continue;
        if (q.isEmpty) {
          if (_selectedCategoryId != 'all') {
            results.add((scenario: sc, category: cat));
          }
        } else if (sc.label.toLowerCase().contains(q) ||
            sc.description.toLowerCase().contains(q) ||
            sc.id.toLowerCase().contains(q) ||
            cat.label.toLowerCase().contains(q)) {
          results.add((scenario: sc, category: cat));
        }
      }
    }
    return results;
  }

  /// Map category IDs to representative icons
  IconData _getCategoryIcon(String catId) {
    switch (catId.toLowerCase()) {
      case 'police_criminal':
        return Icons.local_police_rounded;
      case 'campus':
      case 'campus_education':
        return Icons.school_rounded;
      case 'couples_public':
      case 'couples_privacy':
        return Icons.favorite_rounded;
      case 'online_money':
      case 'cyber_fraud':
        return Icons.lock_rounded;
      case 'work':
      case 'workplace':
      case 'workplace_employment':
        return Icons.business_center_rounded;
      case 'housing':
      case 'housing_tenancy':
      case 'housing_property':
        return Icons.home_rounded;
      case 'family_safety':
        return Icons.family_restroom_rounded;
      case 'consumer_documents':
        return Icons.description_rounded;
      default:
        return Icons.gavel_rounded;
    }
  }

  /// Map category IDs to tag labels
  String _getCategoryTag(String catId) {
    switch (catId.toLowerCase()) {
      case 'police_criminal':
        return 'URGENT';
      case 'campus':
      case 'campus_education':
        return 'UGC';
      case 'couples_public':
      case 'couples_privacy':
        return 'PRIVACY';
      case 'online_money':
      case 'cyber_fraud':
        return '1930';
      case 'work':
      case 'workplace':
      case 'workplace_employment':
        return 'POSH';
      case 'housing':
      case 'housing_tenancy':
      case 'housing_property':
        return 'TENANCY';
      case 'family_safety':
        return 'SAFETY';
      case 'consumer_documents':
        return 'CONSUMER';
      default:
        return 'LEGAL';
    }
  }

  /// Map category IDs to short legal reference line
  String _getCategoryLegalRef(String catId) {
    switch (catId.toLowerCase()) {
      case 'police_criminal':
        return 'SECTION 41A';
      case 'campus':
      case 'campus_education':
        return 'FIR PROTOCOL';
      case 'couples_public':
      case 'couples_privacy':
        return 'ART. 21 SAFE';
      case 'online_money':
      case 'cyber_fraud':
        return 'GOLD HOUR';
      case 'work':
      case 'workplace':
      case 'workplace_employment':
        return 'NOTICE RULES';
      case 'housing':
      case 'housing_tenancy':
      case 'housing_property':
        return 'RENT ACT';
      case 'family_safety':
        return 'DV ACT';
      case 'consumer_documents':
        return 'CONSUMER ACT';
      default:
        return 'CRPC';
    }
  }

  /// Map category IDs to short user-readable title
  String _getCategoryShortTitle(String catId, String fallbackLabel) {
    switch (catId.toLowerCase()) {
      case 'police_criminal':
        return 'Police';
      case 'campus':
      case 'campus_education':
        return 'Campus';
      case 'couples_public':
      case 'couples_privacy':
        return 'Couples';
      case 'online_money':
      case 'cyber_fraud':
        return 'Online Fraud';
      case 'work':
      case 'workplace':
      case 'workplace_employment':
        return 'Workplace';
      case 'housing':
      case 'housing_tenancy':
      case 'housing_property':
        return 'Housing';
      case 'family_safety':
        return 'Family';
      case 'consumer_documents':
        return 'Consumer';
      default:
        return fallbackLabel.split('&').first.trim();
    }
  }

  /// Map category IDs to short description
  String _getCategoryShortDesc(String catId, String fallbackDesc) {
    switch (catId.toLowerCase()) {
      case 'police_criminal':
        return 'Traffic stops, frisking, detention & 41A notices.';
      case 'campus':
      case 'campus_education':
        return 'Anti-ragging statutory rules, admin search, hostels.';
      case 'couples_public':
      case 'couples_privacy':
        return 'Hotel check-in rights, park moral policing defense.';
      case 'online_money':
      case 'cyber_fraud':
        return 'UPI scams, freeze bank requests, blackmail extortion.';
      case 'work':
      case 'workplace':
      case 'workplace_employment':
        return 'Salary withholding, instant firing, harassment relief.';
      case 'housing':
      case 'housing_tenancy':
      case 'housing_property':
        return 'Illegal eviction, withholding deposit, electric cuts.';
      default:
        return fallbackDesc.length > 60
            ? '${fallbackDesc.substring(0, 57)}...'
            : fallbackDesc;
    }
  }

  Color _getTagColor(String catId) {
    switch (catId.toLowerCase()) {
      case 'police_criminal':
        return const Color(0xFFBA1A1A);
      case 'campus':
      case 'campus_education':
        return const Color(0xFF15803D);
      case 'online_money':
      case 'cyber_fraud':
        return const Color(0xFFD97706);
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),

            // Main Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isUserSignedIn {
    try {
      return FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  String get _userEmail {
    try {
      return FirebaseAuth.instance.currentUser?.email ?? 'Guest Citizen';
    } catch (_) {
      return 'Guest Citizen';
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase().trim()) {
      case 'accused':
        return 'Accused / Suspect';
      case 'witness':
        return 'Witness / Bystander';
      case 'parent':
        return 'Parent / Guardian';
      case 'affected':
        return 'Victim / Affected';
      default:
        return 'All Roles';
    }
  }

  Widget _buildAppBar() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9).withValues(alpha: 0.92),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE8E8E8), width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF1A1C1C), size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              Image.asset(
                'assets/images/civic_logo.png',
                width: 26,
                height: 26,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.shield_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CIVIC',
                    style: GoogleFonts.montserrat(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 1.4,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Legal Encounters',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: _showAccountRoleSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isUserSignedIn
                    ? const Color(0xFF15803D).withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isUserSignedIn
                      ? const Color(0xFF15803D).withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isUserSignedIn
                        ? Icons.verified_user_rounded
                        : Icons.shield_outlined,
                    color: _isUserSignedIn
                        ? const Color(0xFF15803D)
                        : AppColors.primary,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _selectedRole == 'all'
                        ? (_isUserSignedIn ? 'Vault Active' : 'Guest Mode')
                        : _selectedRole.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: _isUserSignedIn
                          ? const Color(0xFF15803D)
                          : AppColors.primaryDark,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final filtered = _filteredCategories;
    final isSearching = _searchQuery.isNotEmpty;
    final isSingleCategory = _selectedCategoryId != 'all' && !isSearching;
    final matchingScenarios = _matchingScenarios;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency SOS Banner
          _buildEmergencyBanner(),
          const SizedBox(height: 16),

          // Search Bar
          _buildSearchBar(),
          const SizedBox(height: 14),

          // Quick Category Filter Chips
          _buildCategoryFilterChips(),
          const SizedBox(height: 10),

          // Role Perspective Filter Chips
          _buildRoleFilterChips(),
          const SizedBox(height: 16),

          // Search Results or Single Category View or Category Section Header
          if (isSearching) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MATCHING PROTOCOLS (${matchingScenarios.length})',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5B4137),
                    letterSpacing: 1.4,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                      _currentPage = 1;
                    });
                  },
                  child: Text(
                    'Clear Search',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (matchingScenarios.isEmpty)
              _buildEmptyState()
            else ...[
              _buildPaginatedScenarios(matchingScenarios),
            ],
          ] else if (isSingleCategory) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${_getCategoryShortTitle(_selectedCategoryId, _selectedCategoryId).toUpperCase()} PROTOCOLS (${matchingScenarios.length})',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5B4137),
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = 'all';
                      _currentPage = 1;
                    });
                  },
                  child: Text(
                    'Show All Categories',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (matchingScenarios.isEmpty)
              _buildEmptyState()
            else ...[
              _buildPaginatedScenarios(matchingScenarios),
            ],
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SELECT SCENARIO CATEGORY',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5B4137),
                    letterSpacing: 1.4,
                  ),
                ),
                Text(
                  _selectedRole == 'all'
                      ? 'CrPC & BNS Verified'
                      : 'Role: ${_getRoleDisplayName(_selectedRole)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (filtered.isEmpty) _buildEmptyState() else _buildCategoryGrid(filtered),
          ],

          const SizedBox(height: 24),

          // Legal Compliance Footer
          _buildLegalComplianceFooter(),
        ],
      ),
    );
  }

  Widget _buildPaginatedScenarios(List<({Scenario scenario, Category category})> scenarios) {
    final totalPages = (scenarios.length / _scenariosPerPage).ceil();
    final safePage = _currentPage.clamp(1, totalPages > 0 ? totalPages : 1);
    final startIndex = (safePage - 1) * _scenariosPerPage;
    final paginatedItems = scenarios.skip(startIndex).take(_scenariosPerPage).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMatchingScenariosList(paginatedItems),
        if (totalPages > 1)
          _buildPaginationControls(
            currentPage: safePage,
            totalPages: totalPages,
            totalItems: scenarios.length,
            onPageChanged: (newPage) {
              setState(() {
                _currentPage = newPage;
              });
            },
          ),
      ],
    );
  }

  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required ValueChanged<int> onPageChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
            icon: const Icon(Icons.arrow_back_rounded, size: 15),
            label: Text(
              'PREV',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              disabledForegroundColor: const Color(0xFFC4B5AE),
              side: BorderSide(
                color: currentPage > 1
                    ? AppColors.primary
                    : const Color(0xFFE8E8E8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PAGE $currentPage OF $totalPages',
                style: GoogleFonts.montserrat(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1C1C),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$totalItems protocols total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  color: const Color(0xFF907065),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: const Icon(Icons.arrow_forward_rounded, size: 15),
            label: Text(
              'NEXT',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              disabledForegroundColor: const Color(0xFFC4B5AE),
              side: BorderSide(
                color: currentPage < totalPages
                    ? AppColors.primary
                    : const Color(0xFFE8E8E8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterChips() {
    final categories = [
      (id: 'all', label: 'All'),
      (id: 'police_criminal', label: 'Police'),
      (id: 'campus', label: 'Campus'),
      (id: 'couples_public', label: 'Couples'),
      (id: 'online_money', label: 'Cyber Fraud'),
      (id: 'work', label: 'Workplace'),
      (id: 'housing', label: 'Housing'),
      (id: 'family_safety', label: 'Family'),
      (id: 'consumer_documents', label: 'Consumer'),
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = categories[index];
          final isSelected = _selectedCategoryId == item.id;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategoryId = item.id;
                  _currentPage = 1;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFE8E8E8),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x04000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    item.label,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF5B4137),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleFilterChips() {
    final roles = [
      (id: 'all', label: 'All Roles', icon: Icons.public_rounded),
      (id: 'affected', label: 'Victim / Affected', icon: Icons.shield_rounded),
      (id: 'accused', label: 'Accused / Suspect', icon: Icons.gavel_rounded),
      (id: 'witness', label: 'Witness / Bystander', icon: Icons.visibility_rounded),
      (id: 'parent', label: 'Parent / Guardian', icon: Icons.family_restroom_rounded),
    ];

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: roles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final item = roles[index];
          final isSelected = _selectedRole == item.id;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedRole = item.id;
                  _currentPage = 1;
                });
                AppPreferences.setSelectedRole(item.id);
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF101F18)
                      : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 13,
                      color: isSelected ? Colors.white : const Color(0xFF5B4137),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.label,
                      style: GoogleFonts.montserrat(
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF5B4137),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAccountRoleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final isSignedIn = _isUserSignedIn;
            final email = _userEmail;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E2E2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CITIZEN IDENTITY & PERSPECTIVE',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSignedIn
                                ? const Color(0xFF15803D).withValues(alpha: 0.12)
                                : const Color(0xFFD97706).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isSignedIn ? 'AUTHENTICATED' : 'GUEST MODE',
                            style: GoogleFonts.montserrat(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isSignedIn
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFD97706),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isSignedIn
                                    ? Icons.cloud_done_rounded
                                    : Icons.cloud_off_rounded,
                                color: isSignedIn
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFF907065),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isSignedIn ? email : 'Guest Citizen (Unauthenticated)',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1A1C1C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isSignedIn
                                ? '✓ Cloud Evidence Vault active with real-time Firestore encryption.\n✓ Tamper-evident timestamping enabled for legal affidavit submission.\n✓ Incident logs synced across all authorized devices.'
                                : '• Immediate emergency access is unrestricted (police, SOS, public rights).\n• Local volatile storage: Notes remain on this device only.\n• To enable Cloud Evidence Vault and Section 65B certified legal dossier export, sign in with your account.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFF5B4137),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'SELECT YOUR LEGAL ROLE PERSPECTIVE',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF5B4137),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Different legal rights, duties, and statutory protections apply depending on your role in an encounter.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF907065),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...[
                      (
                        id: 'all',
                        title: 'All Roles (Overview)',
                        desc: 'Shows all statutory scenarios across victims, suspects, and witnesses without filtering.',
                        icon: Icons.public_rounded,
                        tag: 'GENERAL',
                      ),
                      (
                        id: 'affected',
                        title: 'Affected Victim / Aggrieved Person',
                        desc: 'Focuses on Zero FIR registration, DLSA free legal aid, victim compensation, and restraining orders.',
                        icon: Icons.shield_rounded,
                        tag: 'PROTECTION',
                      ),
                      (
                        id: 'accused',
                        title: 'Accused / Suspect / Named Citizen',
                        desc: 'Focuses on Section 35(3) Notice instead of arrest, Right to Silence (Art 20(3)), bail safeguards (Sec 479 BNSS).',
                        icon: Icons.gavel_rounded,
                        tag: 'DEFENSE',
                      ),
                      (
                        id: 'witness',
                        title: 'Witness / Good Samaritan / Bystander',
                        desc: 'Focuses on Good Samaritan immunity (Sec 134A Motor Vehicles Act), exemption from police harassment or coercion.',
                        icon: Icons.visibility_rounded,
                        tag: 'IMMUNITY',
                      ),
                      (
                        id: 'parent',
                        title: 'Parent / Legal Guardian / Caregiver',
                        desc: 'Focuses on Juvenile Justice safeguards, anti-ragging UGC statutory regulations, and POCSO reporting protocols.',
                        icon: Icons.family_restroom_rounded,
                        tag: 'GUARDIAN',
                      ),
                    ].map((roleItem) {
                      final isSelected = _selectedRole == roleItem.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                _selectedRole = roleItem.id;
                              });
                              setState(() {
                                _selectedRole = roleItem.id;
                                _currentPage = 1;
                              });
                              AppPreferences.setSelectedRole(roleItem.id);
                              Navigator.pop(ctx);
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.06)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFFE8E8E8),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : const Color(0xFFF3F3F3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      roleItem.icon,
                                      size: 18,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF5B4137),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                roleItem.title,
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : const Color(0xFF1A1C1C),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF0F0F0),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                roleItem.tag,
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 8.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(0xFF5B4137),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          roleItem.desc,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            color: const Color(0xFF5B4137),
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMatchingScenariosList(List<({Scenario scenario, Category category})> matches) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: matches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final match = matches[index];
        final sc = match.scenario;
        final cat = match.category;
        final tagColor = _getTagColor(cat.id);
        final tagLabel = _getCategoryShortTitle(cat.id, cat.label).toUpperCase();
        final urgencyColor = _getUrgencyColor(sc.urgency);
        final urgencyLabel = _getUrgencyLabel(sc.urgency);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TriageScreen(scenario: sc),
                ),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8E8E8)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: tagColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tagLabel,
                              style: GoogleFonts.montserrat(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: tagColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: urgencyColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              urgencyLabel,
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: urgencyColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${sc.branches.length} BRANCHES',
                        style: GoogleFonts.montserrat(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF907065),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sc.label,
                    style: GoogleFonts.montserrat(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sc.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF5B4137),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'OPEN PROTOCOL',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmergencyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFBA1A1A).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFBA1A1A).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFBA1A1A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emergency_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency SOS',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFBA1A1A),
                  ),
                ),
                Text(
                  'Dial 112 for Police • 1930 for Cyber Crime',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF5B4137),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFBA1A1A), size: 20),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val.trim()),
        textInputAction: TextInputAction.search,
        onSubmitted: (val) => setState(() => _searchQuery = val.trim()),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: const Color(0xFF1A1C1C),
        ),
        decoration: InputDecoration(
          prefixIcon: IconButton(
            icon: const Icon(Icons.search_rounded,
                color: AppColors.primary, size: 22),
            onPressed: () {
              setState(() => _searchQuery = _searchController.text.trim());
            },
          ),
          hintText: 'Search scenarios (e.g. traffic, FIR, ragging)...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: const Color(0xFF907065).withValues(alpha: 0.6),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: Color(0xFF907065), size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.mic_rounded,
                      color: AppColors.primary, size: 22),
                  onPressed: () {
                    // Voice search placeholder
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.mic_rounded,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Voice search coming soon',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF101F18),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    );
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<Category> categories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 500 ? 3 : 2;
        final spacing = 12.0;
        final cardWidth =
            (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: categories.map((cat) {
            return SizedBox(
              width: cardWidth,
              child: _buildCategoryCard(cat),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategoryCard(Category cat) {
    final icon = _getCategoryIcon(cat.id);
    final tag = _getCategoryTag(cat.id);
    final tagColor = _getTagColor(cat.id);
    final legalRef = _getCategoryLegalRef(cat.id);
    final shortTitle = _getCategoryShortTitle(cat.id, cat.label);
    final shortDesc = _getCategoryShortDesc(cat.id, cat.description);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showCategoryScenarios(cat),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E8E8)),
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
              // Icon + Tag Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: AppColors.primaryDark, size: 20),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tagColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.montserrat(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: tagColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category Title
              Text(
                shortTitle,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1C1C),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),

              // Short Description
              Text(
                shortDesc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: const Color(0xFF5B4137),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),

              // Legal Ref + Arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      legalRef,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryScenarios(Category cat) {
    final scenarios = _filteredScenariosFor(cat);

    if (scenarios.length == 1) {
      // Single scenario: navigate directly
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TriageScreen(scenario: scenarios.first),
        ),
      );
      return;
    }

    int modalPage = 1;
    const int modalPerPage = 5;

    // Multiple scenarios: show bottom sheet with pagination
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final totalPages = (scenarios.length / modalPerPage).ceil();
            final safePage = modalPage.clamp(1, totalPages > 0 ? totalPages : 1);
            final startIndex = (safePage - 1) * modalPerPage;
            final pageScenarios = scenarios.skip(startIndex).take(modalPerPage).toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E2E2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getCategoryShortTitle(cat.id, cat.label)
                                  .toUpperCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Select Your Scenario',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1C1C),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${scenarios.length} PROTOCOLS',
                            style: GoogleFonts.montserrat(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE8E8E8)),
                  Flexible(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                      itemCount: pageScenarios.length,
                      shrinkWrap: true,
                      separatorBuilder: (context, i) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final sc = pageScenarios[index];
                        return _buildScenarioTile(sc, ctx);
                      },
                    ),
                  ),
                  if (totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: _buildPaginationControls(
                        currentPage: safePage,
                        totalPages: totalPages,
                        totalItems: scenarios.length,
                        onPageChanged: (newPage) {
                          setModalState(() {
                            modalPage = newPage;
                          });
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScenarioTile(Scenario sc, BuildContext modalContext) {
    final urgencyColor = _getUrgencyColor(sc.urgency);
    final urgencyLabel = _getUrgencyLabel(sc.urgency);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(modalContext);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TriageScreen(scenario: sc),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: urgencyColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      urgencyLabel,
                      style: GoogleFonts.montserrat(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: urgencyColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Text(
                    '${sc.branches.length} BRANCHES',
                    style: GoogleFonts.montserrat(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF907065),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                sc.label,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1C1C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sc.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF5B4137),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'VIEW PROTOCOL',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 14, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 32, color: Color(0xFF907065)),
          ),
          const SizedBox(height: 16),
          Text(
            'No matching scenarios found.',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search query or selecting a different category filter.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF5B4137),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
                _selectedCategoryId = 'all';
              });
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              'SHOW ALL SCENARIOS',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalComplianceFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD5E7DC).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF15803D).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'STATUTORY COMPLIANCE',
              style: GoogleFonts.montserrat(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF15803D),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '100% Offline • All rights data stored locally on device.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: const Color(0xFF3B4A42),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(int urgency) {
    switch (urgency) {
      case 1:
        return const Color(0xFFBA1A1A);
      case 2:
        return AppColors.primary;
      case 3:
      default:
        return AppColors.onSurfaceVariant;
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
}
