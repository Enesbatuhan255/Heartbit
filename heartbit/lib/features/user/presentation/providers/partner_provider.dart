
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/user/domain/entities/user_profile.dart';
import 'package:heartbit/features/user/presentation/providers/user_provider.dart';

part 'partner_provider.g.dart';

@riverpod
Stream<UserProfile?> partnerState(PartnerStateRef ref) {
  final user = ref.watch(authUserIdProvider);
  if (user == null) return const Stream.empty();

  final coupleAsync = ref.watch(coupleStateProvider);
  
  return coupleAsync.when(
    data: (couple) {
      if (couple == null) return const Stream.empty();

      // Determine partner ID
      final partnerId = couple.user1Id == user ? couple.user2Id : couple.user1Id;
      
      return ref.watch(userRepositoryProvider).watchUser(partnerId);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
}
