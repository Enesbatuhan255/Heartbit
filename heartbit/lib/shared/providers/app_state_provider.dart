
import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';

part 'app_state_provider.freezed.dart';
part 'app_state_provider.g.dart';

@freezed
class AppState with _$AppState {
  const factory AppState({
    @Default(true) bool isLoading,
    String? userId,
    String? pairId,
  }) = _AppState;

  const AppState._();

  bool get isAuthenticated => userId != null;
  bool get isPaired => pairId != null;
}

/// Timeout provider: emits false initially, then true after 5 seconds.
/// This prevents the app from being stuck on the loading screen forever
/// if Firestore is slow to connect (e.g., cold start on Pixel 9).
@Riverpod(keepAlive: true)
class BootTimeout extends _$BootTimeout {
  Timer? _timer;

  @override
  bool build() {
    ref.onDispose(() => _timer?.cancel());
    _timer = Timer(const Duration(seconds: 5), () {
      state = true;
    });
    return false;
  }
}

@riverpod
class AppBootstrap extends _$AppBootstrap {
  @override
  AppState build() {
    // 1. Watch Auth State
    final authState = ref.watch(authStateProvider);
    
    // Handle loading or error in auth
    if (authState is AsyncLoading) {
      return const AppState(isLoading: true);
    }

    // Handle auth error — don't hang, just treat as unauthenticated
    if (authState is AsyncError) {
      return const AppState(isLoading: false, userId: null, pairId: null);
    }

    final user = authState.value;
    if (user == null) {
      return const AppState(isLoading: false, userId: null, pairId: null);
    }

    // 2. Watch Couple State (only if user exists)
    final coupleState = ref.watch(coupleStateProvider);
    
    // Handle loading in couple check
    if (coupleState is AsyncLoading) {
      // Check if we have previous data (Riverpod preserves data during refresh)
      if (coupleState.hasValue) {
        final couple = coupleState.value;
        return AppState(
          isLoading: false,
          userId: user.uid,
          pairId: couple?.id,
        );
      }
      
      // Check timeout — don't hang on loading forever
      final timedOut = ref.watch(bootTimeoutProvider);
      if (timedOut) {
        return AppState(isLoading: false, userId: user.uid, pairId: null);
      }
      
      return AppState(isLoading: true, userId: user.uid);
    }

    // Handle couple error — don't hang, treat as unpaired
    if (coupleState is AsyncError) {
      return AppState(isLoading: false, userId: user.uid, pairId: null);
    }

    final couple = coupleState.value;
    
    return AppState(
      isLoading: false,
      userId: user.uid,
      pairId: couple?.id,
    );
  }
}
