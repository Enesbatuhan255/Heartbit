import 'dart:math';
import '../../domain/entities/activity.dart';
import '../../domain/entities/custom_activity.dart';
import '../../data/datasources/swipe_datasource.dart';

/// Service for generating the swipe deck with 80/20 mix
class DeckGeneratorService {
  final GlobalActivityDataSource _globalDataSource;
  final CustomActivityDataSource _customDataSource;

  DeckGeneratorService({
    required GlobalActivityDataSource globalDataSource,
    required CustomActivityDataSource customDataSource,
  })  : _globalDataSource = globalDataSource,
        _customDataSource = customDataSource;

  /// Generate a deck by mixing global and custom activities
  /// 
  /// [categories] - Selected vibe categories
  /// [deckSize] - Total number of cards in the deck
  /// Returns a shuffled list of Activity objects
  Future<List<Activity>> generateDeck({
    required String coupleId,
    required List<String> categories,
    Set<int>? budgetLevels,
    Set<String>? durationTiers,
    int deckSize = 20,
  }) async {
    // Calculate the split (80% global, 20% custom)
    final globalTarget = (deckSize * 0.8).round();
    final customTarget = deckSize - globalTarget;

    // Fetch more to allow for filtering and randomization
    // Since we filter in memory, we fetch 3x the target
    final results = await Future.wait([
      _globalDataSource.getByCategories(
        categories,
        limit: globalTarget * 4,
      ),
      _customDataSource.getAll(
        coupleId,
        limit: customTarget * 3,
      ),
    ]);

    final globalCards = results[0] as List<Activity>;
    final customCards = results[1] as List<CustomActivity>;

    // Filter global cards
    // Filter helper
    List<Activity> applyFilters(List<Activity> source, {bool ignoreBudget = false, bool ignoreDuration = false}) {
      return source.where((activity) {
        bool budgetPass = true;
        bool durationPass = true;

        if (!ignoreBudget && budgetLevels != null && budgetLevels.isNotEmpty) {
          budgetPass = budgetLevels.contains(activity.budgetLevel) || 
                       (budgetLevels.contains(3) && activity.budgetLevel >= 3);
        }

        if (!ignoreDuration && durationTiers != null && durationTiers.isNotEmpty) {
          final timeLower = activity.estimatedTime.toLowerCase();
          // Improved loose matching
          bool isQuick = timeLower.contains('min') || timeLower.contains('1 hour') || timeLower.contains('1-');
          bool isMedium = timeLower.contains('2') || timeLower.contains('3') || timeLower.contains('half');
          bool isLong = timeLower.contains('full') || timeLower.contains('4') || timeLower.contains('5');

          durationPass = (durationTiers.contains('quick') && isQuick) ||
                         (durationTiers.contains('medium') && isMedium) ||
                         (durationTiers.contains('long') && isLong);
        }

        return budgetPass && durationPass;
      }).toList();
    }

    // 1. Try Strict
    var filteredGlobal = applyFilters(globalCards);

    // 2. Fallback: Ignore Duration if too few
    if (filteredGlobal.length < 3) {
      final relaxedDuration = applyFilters(globalCards, ignoreDuration: true);
      // Determine which to keep: simple union
      for (final act in relaxedDuration) {
        if (!filteredGlobal.any((a) => a.id == act.id)) {
          filteredGlobal.add(act);
        }
      }
    }

    // 3. Fallback: Ignore Budget if still too few
    if (filteredGlobal.length < 3) {
      final relaxedBudget = applyFilters(globalCards, ignoreBudget: true);
      for (final act in relaxedBudget) {
        if (!filteredGlobal.any((a) => a.id == act.id)) {
          filteredGlobal.add(act);
        }
      }
    }

    // 4. Last Resort: Ignore All Filters (Show Category matches)
    if (filteredGlobal.isEmpty && globalCards.isNotEmpty) {
      filteredGlobal = List.from(globalCards);
    }

    // Shuffle both lists
    final random = Random();
    filteredGlobal.shuffle(random);

    // Convert custom activities to Activity format
    final customActivities = customCards.map((custom) => Activity(
      id: custom.id,
      title: custom.title,
      description: 'Your custom activity',
      imageUrl: '', // Will use placeholder in UI
      category: custom.category ?? 'custom',
      activityType: 'custom',
      estimatedTime: '?',
      budgetLevel: 0,
    )).toList();
    customActivities.shuffle(random);

    // Build the deck
    final deck = <Activity>[];

    // Add global cards
    deck.addAll(filteredGlobal.take(globalTarget));

    // Add custom cards
    deck.addAll(customActivities.take(customTarget));

    // If we don't have enough custom, fill with more global
    if (deck.length < deckSize && filteredGlobal.length > globalTarget) {
      final remaining = deckSize - deck.length;
      deck.addAll(filteredGlobal.skip(globalTarget).take(remaining));
    }

    // Final shuffle
    deck.shuffle(random);

    return deck;
  }

  /// Generate a quick deck from just global activities
  Future<List<Activity>> generateQuickDeck({
    required List<String> categories,
    int deckSize = 15,
  }) async {
    final cards = await _globalDataSource.getByCategories(
      categories,
      limit: deckSize * 2,
    );

    cards.shuffle(Random());
    return cards.take(deckSize).toList();
  }
}
