
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

    final user = authState.value;
    if (user == null) {
      return const AppState(isLoading: false, userId: null, pairId: null);
    }

    // 2. Watch Couple State (only if user exists)
    final coupleState = ref.watch(coupleStateProvider);
    
    // Handle loading in couple check
    if (coupleState is AsyncLoading) {
       return AppState(isLoading: true, userId: user.uid);
    }

    final couple = coupleState.value;
    
    return AppState(
      isLoading: false,
      userId: user.uid,
      pairId: couple?.id,
    );
  }
}
