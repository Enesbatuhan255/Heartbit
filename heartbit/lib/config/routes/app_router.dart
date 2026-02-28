import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/features/pairing/presentation/screens/pairing_screen.dart';
import 'package:heartbit/features/home/presentation/screens/dashboard_screen.dart';
import 'package:heartbit/features/daily_question/presentation/screens/daily_question_archive_screen.dart';
import 'package:heartbit/features/drawing/presentation/pages/draw_and_guess_screen.dart';
import 'package:heartbit/features/user/presentation/screens/profile_edit_screen.dart';
import 'package:heartbit/features/activity_hub/presentation/screens/activity_hub_screen.dart';

import 'package:heartbit/features/activity_hub/presentation/screens/fortune_wheel_screen.dart';
import 'package:heartbit/features/activity_hub/presentation/screens/bucket_list_screen.dart';
import 'package:heartbit/features/activity_hub/presentation/screens/swipe_setup_screen.dart';
import 'package:heartbit/features/activity_hub/presentation/screens/enhanced_swipe_screen.dart';
import 'package:heartbit/features/games/stack_tower/presentation/screens/stack_tower_screen.dart';
import 'package:heartbit/features/games/emoji_game/presentation/screens/emoji_game_screen.dart';

import 'package:heartbit/features/games/rhythm_copy/presentation/screens/rhythm_copy_screen.dart';
import 'package:heartbit/features/games/story_chain/presentation/screens/story_chain_screen.dart';
import 'package:heartbit/features/games/word_chain/presentation/screens/word_chain_screen.dart';
import 'package:heartbit/features/memory_vault/presentation/screens/memory_vault_screen.dart';
import 'package:heartbit/features/memory_vault/presentation/screens/add_memory_screen.dart';
import 'package:heartbit/features/pet/presentation/screens/pet_garden_screen.dart';
import 'package:heartbit/shared/providers/app_state_provider.dart';
import 'package:heartbit/shared/presentation/screens/loading_screen.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  // Watch centralized AppState
  final appState = ref.watch(appBootstrapProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/loading',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/loading',
      ),
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/pairing',
        builder: (context, state) => const PairingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/archive',
        builder: (context, state) => const DailyQuestionArchiveScreen(),
      ),
      GoRoute(
        path: '/draw-game',
        builder: (context, state) => const DrawAndGuessScreen(),
      ),
      GoRoute(
        path: '/profile-edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      // Activity Hub Routes
      GoRoute(
        path: '/activity-hub',
        builder: (context, state) => const ActivityHubScreen(),
      ),

      GoRoute(
        path: '/swipe-setup',
        builder: (context, state) => const SwipeSetupScreen(),
      ),
      GoRoute(
        path: '/swipe-match-enhanced',
        builder: (context, state) => const EnhancedSwipeScreen(),
      ),
      GoRoute(
        path: '/fortune-wheel',
        builder: (context, state) => const FortuneWheelScreen(),
      ),
      GoRoute(
        path: '/bucket-list',
        builder: (context, state) => const BucketListScreen(),
      ),
      // Stack Tower Game
      GoRoute(
        path: '/stack-tower',
        builder: (context, state) => const StackTowerScreen(),
      ),
      // Emoji Tahmin Game
      GoRoute(
        path: '/emoji-game',
        builder: (context, state) => const EmojiGameScreen(),
      ),

      // Rhythm Copy
      GoRoute(
        path: '/rhythm-copy',
        builder: (context, state) => const RhythmCopyScreen(),
      ),
      // Word Chain
      GoRoute(
        path: '/word-chain',
        builder: (context, state) => const WordChainScreen(),
      ),
      // Story Chain
      GoRoute(
        path: '/story-chain',
        builder: (context, state) => const StoryChainScreen(),
      ),
      // Memory Vault Routes
      GoRoute(
        path: '/memory-vault',
        builder: (context, state) => const MemoryVaultScreen(),
      ),
      GoRoute(
        path: '/add-memory',
        builder: (context, state) => const AddMemoryScreen(),
      ),
      GoRoute(
        path: '/pet-garden',
        builder: (context, state) => const PetGardenScreen(),
      ),
      GoRoute(
        path: '/:rest(.*)',
        redirect: (context, state) => '/loading',
      ),
    ],
    redirect: (context, state) {
      final isLoadingRoute = state.uri.path == '/loading';

      // If still loading, redirect to loading screen
      if (appState.isLoading) {
        return isLoadingRoute ? null : '/loading';
      }

      // Loading complete, redirect away from loading screen
      if (isLoadingRoute) {
        // Determine where to go based on auth/pairing state
        if (!appState.isAuthenticated) {
          return '/pairing';
        }
        return appState.isPaired ? '/dashboard' : '/pairing';
      }

      final isLoggedIn = appState.isAuthenticated;
      final isPaired = appState.isPaired;

      final isPairingRoute = state.uri.path == '/pairing';

      // 1. Not Logged In -> Pairing (for now)
      if (!isLoggedIn) {
        // Here we could redirect to '/login' if we had one.
        // Since we treat PairingScreen as entry for anon login too, stay here.
        return null;
      }

      // 2. Logged In
      // If Coupled -> Dashboard (only redirect if trying to access auth/pairing screens)
      if (isPaired) {
        if (isPairingRoute) return '/dashboard';
      }
      // If Not Coupled -> Pairing
      else {
        if (!isPairingRoute) return '/pairing';
      }

      return null;
    },
  );
}
