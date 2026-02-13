import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/activity.dart';
import '../../domain/entities/activity_category.dart';
import '../../domain/entities/custom_activity.dart';
import '../../domain/entities/swipe_session.dart';
import '../../domain/services/deck_generator_service.dart';
import '../../data/datasources/swipe_datasource.dart';
import 'draft_session_provider.dart';

part 'swipe_provider.g.dart';

// --- Data Layer Providers ---

@riverpod
GlobalActivityDataSource globalActivityDataSource(GlobalActivityDataSourceRef ref) {
  return GlobalActivityDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@riverpod
CustomActivityDataSource customActivityDataSource(CustomActivityDataSourceRef ref) {
  return CustomActivityDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@riverpod
SwipeSessionDataSource swipeSessionDataSource(SwipeSessionDataSourceRef ref) {
  return SwipeSessionDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@riverpod
DeckGeneratorService deckGeneratorService(DeckGeneratorServiceRef ref) {
  return DeckGeneratorService(
    globalDataSource: ref.watch(globalActivityDataSourceProvider),
    customDataSource: ref.watch(customActivityDataSourceProvider),
  );
}

// --- Custom Activities ---

@riverpod
Stream<List<CustomActivity>> customActivities(CustomActivitiesRef ref) {
  final coupleAsync = ref.watch(coupleStateProvider);
  
  if (!coupleAsync.hasValue || coupleAsync.value == null) {
    return const Stream.empty();
  }
  
  return ref.watch(customActivityDataSourceProvider)
      .watchAll(coupleAsync.value!.id);
}

// --- Matches Stream ---

@riverpod
Stream<List<ActivityMatch>> activityMatches(ActivityMatchesRef ref) {
  final coupleAsync = ref.watch(coupleStateProvider);

  if (!coupleAsync.hasValue || coupleAsync.value == null) {
    return const Stream.empty();
  }

  print('📡 activityMatches: Starting to watch matches for couple ${coupleAsync.value!.id}');

  return ref.watch(swipeSessionDataSourceProvider)
      .watchMatches(coupleAsync.value!.id)
      .map((matches) {
        print('📡 activityMatches: Received ${matches.length} matches from Firestore');
        for (final m in matches) {
          print('  - Match: ${m.activityTitle} (${m.activityId}) at ${m.matchedAt}');
        }
        return matches;
      });
}

// --- Setup State ---

/// Holds the currently selected categories for the session
@riverpod
class SelectedCategories extends _$SelectedCategories {
  @override
  Set<ActivityCategory> build() => {};

  void toggle(ActivityCategory category) {
    if (state.contains(category)) {
      state = {...state}..remove(category);
    } else {
      state = {...state, category};
    }
  }

  void clear() => state = {};
}

/// Holds selected budget levels (1=$, 2=$$, 3=$$$)
@riverpod
class SelectedBudgets extends _$SelectedBudgets {
  @override
  Set<int> build() => <int>{};

  void toggle(int level) {
    if (state.contains(level)) {
      state = {...state}..remove(level);
    } else {
      state = {...state, level};
    }
  }

  void clear() => state = {};
}

/// Holds selected duration tiers ('quick', 'medium', 'long')
@riverpod
class SelectedDurations extends _$SelectedDurations {
  @override
  Set<String> build() => <String>{};

  void toggle(String duration) {
    if (state.contains(duration)) {
      state = {...state}..remove(duration);
    } else {
      state = {...state, duration};
    }
  }

  void clear() => state = {};
}

/// Holds temporary custom activities added for this session
@riverpod
class SessionCustomActivities extends _$SessionCustomActivities {
  @override
  List<String> build() => [];

  void add(String title) {
    state = [...state, title];
  }

  void remove(String title) {
    state = state.where((t) => t != title).toList();
  }

  void clear() => state = [];
}

// --- Deck Controller ---

@Riverpod(keepAlive: true)
class SwipeDeckController extends _$SwipeDeckController {
  @override
  FutureOr<List<Activity>> build() => [];

  Future<void> generateDeck({List<String> explicitCustoms = const []}) async {
    // Prevent concurrent generation
    if (state.isLoading) return;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final coupleAsync = ref.read(coupleStateProvider);
      if (!coupleAsync.hasValue || coupleAsync.value == null) {
        throw Exception('Couple not found');
      }

      final selectedCategories = ref.read(selectedCategoriesProvider);
      final selectedBudgets = ref.read(selectedBudgetsProvider);
      final selectedDurations = ref.read(selectedDurationsProvider);
      // We use the explicit list passed from UI to be safe
      final sessionCustoms = explicitCustoms; 
      
      final deckService = ref.read(deckGeneratorServiceProvider);
      final coupleId = coupleAsync.value!.id;

      // Get categories as strings
      final categories = selectedCategories.map((c) => c.value).toList();

      // Generate deck
      var deck = await deckService.generateDeck(
        coupleId: coupleId,
        categories: categories,
        budgetLevels: selectedBudgets,
        durationTiers: selectedDurations,
        deckSize: 20,
      );

      // Add explicit custom activities (Wild Cards)
      if (sessionCustoms.isNotEmpty) {
        final customCards = sessionCustoms.map((title) => Activity(
          id: 'wild_${const Uuid().v4()}', // Unique ID for session
          title: title,
          description: 'Your Wild Card',
          imageUrl: '',
          category: 'spicy', // Default category for wilds
          activityType: 'custom',
          estimatedTime: 'Flexible',
          budgetLevel: 1,
        )).toList();

        deck = [...deck, ...customCards];
        deck.shuffle();
      }

      // DEBUG FALLBACK: If deck is still empty, add a hardcoded card to prove pipeline works
      if (deck.isEmpty) {
        deck.add(const Activity(
          id: 'welcome_card',
          title: 'Welcome to Activity Swipe!',
          description: 'Swipe RIGHT to like, LEFT to pass. Match with your partner to plan your next adventure! (Add more activities in Setup)',
          imageUrl: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=800',
          category: 'chill_home',
          activityType: 'global',
        ));
      }

      if (deck.isEmpty) {
        return [];
      }

      return deck;
    });
  }
}

// --- Swipe Controller ---

@riverpod
class SwipeSessionController extends _$SwipeSessionController {
  String? _sessionId;
  int _currentIndex = 0;
  final List<String> _matchedActivityIds = [];

  @override
  FutureOr<void> build() {}

  /// Start a new swipe session
  /// Uses shared session ID from DraftSession so both partners swipe in the same session
  Future<void> startSession(List<Activity> deck) async {
    final coupleAsync = ref.read(coupleStateProvider);
    if (!coupleAsync.hasValue || coupleAsync.value == null) return;

    final coupleId = coupleAsync.value!.id;
    final dataSource = ref.read(swipeSessionDataSourceProvider);
    final selectedCategories = ref.read(selectedCategoriesProvider);

    // Check if there's already a shared session ID from DraftSession
    final draftAsync = await ref.read(sharedDraftSessionProvider.future);

    if (draftAsync != null && draftAsync.activeSessionId != null && draftAsync.activeSessionId!.isNotEmpty) {
      // Use existing session - partner already created it
      _sessionId = draftAsync.activeSessionId;
      print('🔗 Using EXISTING session ID: $_sessionId');
    } else {
      // First user to start - create new session and save to DraftSession
      _sessionId = await dataSource.createSession(
        coupleId,
        selectedCategories.map((c) => c.value).toList(),
        deck.length,
      );

      // Save session ID to DraftSession so partner can use the same session
      await ref.read(draftSessionControllerProvider.notifier).setActiveSessionId(_sessionId!);
      print('🆕 Created NEW session ID: $_sessionId');
    }

    _currentIndex = 0;
    _matchedActivityIds.clear();
    print('🎮 Session started with ${deck.length} cards');
  }

  /// Record a swipe and check for match
  Future<bool> swipe(Activity activity, bool liked) async {
    final coupleAsync = ref.read(coupleStateProvider);
    final userId = ref.read(authUserIdProvider);

    if (!coupleAsync.hasValue || coupleAsync.value == null || userId == null) {
      return false;
    }
    if (_sessionId == null) {
      print('❌ No session ID - cannot swipe');
      return false;
    }

    final coupleId = coupleAsync.value!.id;
    final dataSource = ref.read(swipeSessionDataSourceProvider);

    print('📝 Swiping ${activity.title} ${liked ? "RIGHT" : "LEFT"} (Session: $_sessionId, User: $userId, activityType: ${activity.activityType})');

    state = const AsyncLoading();

    try {
      // Record my swipe
      final swipe = SwipeRecord(
        activityId: activity.id,
        activityType: activity.activityType,
        userId: userId,
        direction: liked ? 'right' : 'left',
        sessionId: _sessionId!,
        timestamp: DateTime.now(),
      );
      await dataSource.recordSwipe(coupleId, swipe);
      print('✅ Swipe recorded successfully');

      // Check for match (only if I liked)
      if (liked) {
        // Retry mechanism for partner swipe check
        SwipeRecord? partnerSwipe;
        for (int i = 0; i < 5; i++) {
          await Future.delayed(Duration(milliseconds: 300 * (i + 1)));

          partnerSwipe = await dataSource.getPartnerSwipe(
            coupleId,
            activity.id,
            userId,
            _sessionId!,
          );

          if (partnerSwipe != null) {
            print('🔍 Attempt ${i + 1}: Found partner swipe! direction=${partnerSwipe.direction}');
            break;
          } else {
            print('🔍 Attempt ${i + 1}: No partner swipe found yet...');
          }
        }

        print('🔍 Final partner swipe check for ${activity.title}: ${partnerSwipe?.direction ?? "NOT FOUND"}');

        if (partnerSwipe != null && partnerSwipe.direction == 'right') {
          // Check if match already exists to avoid duplicates
          final matchId = '${activity.id}_${_sessionId}';
          print('🎉 Both swiped RIGHT! Checking if match already exists...');

          // Check if this match was already created
          if (_matchedActivityIds.contains(activity.id)) {
            print('⚠️ Match already recorded for this activity');
            _currentIndex++;
            state = const AsyncData(null);
            return true;
          }

          // 🎉 MATCH! Create it
          print('🎉 MATCH FOUND! Creating match for ${activity.title}');
          final match = ActivityMatch(
            id: matchId,
            activityId: activity.id,
            activityType: activity.activityType,
            activityTitle: activity.title,
            matchedAt: DateTime.now(),
          );
          await dataSource.createMatch(coupleId, match);
          print('✅ Match created successfully: ${match.id}');

          _matchedActivityIds.add(activity.id);
          ref.read(matchEventNotifierProvider.notifier).trigger(activity);

          state = const AsyncData(null);
          return true;
        } else {
          print('❌ No partner swipe found or partner swiped LEFT after all retries');
        }
      }

      _currentIndex++;
      state = const AsyncData(null);
      return false;
    } catch (e, st) {
      print('❌ Error during swipe: $e\n$st');
      state = AsyncError(e, st);
      return false;
    }
  }

  int get currentIndex => _currentIndex;
  List<String> get matchedActivityIds => _matchedActivityIds;
}

// --- Match Event Notifier ---

@riverpod
class MatchEventNotifier extends _$MatchEventNotifier {
  @override
  Activity? build() => null;

  void trigger(Activity activity) => state = activity;
  void clear() => state = null;
}

// --- Custom Activity Controller ---

@riverpod
class CustomActivityController extends _$CustomActivityController {
  @override
  FutureOr<void> build() {}

  Future<void> addCustomActivity(String title) async {
    final coupleAsync = ref.read(coupleStateProvider);
    final userId = ref.read(authUserIdProvider);

    if (!coupleAsync.hasValue || coupleAsync.value == null || userId == null) {
      return;
    }

    final dataSource = ref.read(customActivityDataSourceProvider);
    final coupleId = coupleAsync.value!.id;

    final activity = CustomActivity(
      id: const Uuid().v4(),
      title: title,
      createdBy: userId,
      createdAt: DateTime.now(),
    );

    await dataSource.add(coupleId, activity);
  }

  Future<void> deleteCustomActivity(String activityId) async {
    final coupleAsync = ref.read(coupleStateProvider);
    if (!coupleAsync.hasValue || coupleAsync.value == null) return;

    final dataSource = ref.read(customActivityDataSourceProvider);
    await dataSource.delete(coupleAsync.value!.id, activityId);
  }
}
