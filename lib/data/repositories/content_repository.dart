import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/services.dart';
import '../models/content_models.dart';

/// Central Content Repository managing scenario hierarchy, card retrieval,
/// offline caching, filtering, and strict Legal Safety Gates.
class ContentRepository {
  static ContentRepository? _instance;
  static ContentRepository get instance => _instance ??= ContentRepository();

  ContentRepository({this.isReleaseModeOverride});

  final bool? isReleaseModeOverride;
  bool get isRelease => isReleaseModeOverride ?? kReleaseMode;

  List<Category>? _categoriesCache;
  List<Category>? get categoriesCache => _categoriesCache;
  List<HelplineModel>? _helplinesCache;
  List<HelplineModel>? get helplinesCache => _helplinesCache;
  final Map<String, CardModel> _cardCache = {};

  bool _isPreloading = false;

  /// Load master categories and scenarios from assets/content/index.json
  Future<List<Category>> loadCategories() async {
    if (_categoriesCache != null) return _categoriesCache!;

    final rawJson = await rootBundle.loadString('assets/content/index.json');
    final data = jsonDecode(rawJson) as Map<String, dynamic>;
    final list = (data['categories'] as List<dynamic>? ?? [])
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();

    _categoriesCache = list;
    _warmUpCardCache(list);
    return list;
  }

  /// Asynchronously warm up the card cache in the background so cards render with zero latency.
  void _warmUpCardCache(List<Category> categories) {
    if (_isPreloading) return;
    _isPreloading = true;
    Future.microtask(() async {
      try {
        for (final cat in categories) {
          for (final sc in cat.scenarios) {
            for (final branch in sc.branches) {
              final cardId = '${sc.id}_$branch';
              if (!_cardCache.containsKey(cardId)) {
                await loadCard(cardId);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('ContentRepository: Warmup background preload error: $e');
      } finally {
        _isPreloading = false;
      }
    });
  }

  /// Load universal helpline registry from assets/content/helplines.json
  Future<List<HelplineModel>> loadHelplines() async {
    if (_helplinesCache != null) return _helplinesCache!;

    final rawJson = await rootBundle.loadString('assets/content/helplines.json');
    final list = (jsonDecode(rawJson) as List<dynamic>)
        .map((e) => HelplineModel.fromJson(e as Map<String, dynamic>))
        .toList();

    _helplinesCache = list;
    return list;
  }

  /// Resolve a specific helpline by id
  Future<HelplineModel?> getHelpline(String id) async {
    final list = await loadHelplines();
    try {
      return list.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Load a scenario card by id (e.g. "traffic_stop_default")
  Future<CardModel?> loadCard(String cardId) async {
    if (_cardCache.containsKey(cardId)) {
      return _cardCache[cardId];
    }

    try {
      final raw = await rootBundle.loadString('assets/content/cards/$cardId.json');
      final card = CardModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _cardCache[cardId] = card;
      return card;
    } catch (e) {
      debugPrint('ContentRepository: Failed to load card $cardId: $e');
      return null;
    }
  }

  /// Safety Gate: Determines if a card is safe to display to the user
  ///
  /// In Debug mode: All cards can be displayed (with unreviewed warning banner).
  /// In Release mode: Strictly HIDES cards that have empty reviewed_by or are expired.
  bool canDisplayCard(CardModel card) {
    if (!isRelease) {
      return true; // Debug mode shows all cards with warning banner
    }
    return card.isDisplayableInRelease;
  }

  /// Default emergency fallback text for release builds when content is unreviewed
  static const String releaseSafetyFallbackMessage =
      'Guidance for this situation is being reviewed. Call 112 or legal aid 15100.';

  /// Load all cards across all scenarios (for debug status metrics or bulk search)
  Future<List<CardModel>> loadAllCards() async {
    final categories = await loadCategories();
    final allCards = <CardModel>[];

    for (final cat in categories) {
      for (final sc in cat.scenarios) {
        for (final branch in sc.branches) {
          final cardId = '${sc.id}_$branch';
          final card = await loadCard(cardId);
          if (card != null) {
            allCards.add(card);
          }
        }
      }
    }
    return allCards;
  }

  /// Search scenarios across titles and descriptions
  Future<List<Scenario>> searchScenarios(String query) async {
    if (query.trim().isEmpty) return [];
    final categories = await loadCategories();
    final q = query.toLowerCase().trim();

    final results = <Scenario>[];
    for (final cat in categories) {
      for (final sc in cat.scenarios) {
        if (sc.label.toLowerCase().contains(q) ||
            sc.description.toLowerCase().contains(q) ||
            cat.label.toLowerCase().contains(q)) {
          results.add(sc);
        }
      }
    }
    return results;
  }

  /// Filter scenarios and cards by demographic parameters
  List<CardModel> filterCards(
    List<CardModel> cards, {
    String? state,
    int? age,
    String? userType,
    String? language,
  }) {
    return cards.where((card) {
      if (language != null && card.language != language) {
        return false;
      }
      return card.appliesTo.matches(state: state, age: age, userType: userType);
    }).toList();
  }

  /// Clear in-memory caches
  void clearCache() {
    _isPreloading = false;
    _categoriesCache = null;
    _helplinesCache = null;
    _cardCache.clear();
  }
}
