
import 'package:flutter_test/flutter_test.dart';
import 'package:heartbit/features/pairing/domain/usecases/generate_pairing_code_usecase.dart';
import 'package:heartbit/features/pairing/domain/usecases/join_with_code_usecase.dart';

import '../../../../helpers/fake_pairing_repository.dart';

void main() {
  late FakePairingRepository repository;
  late GeneratePairingCodeUseCase generateCodeUseCase;
  late JoinWithCodeUseCase joinWithCodeUseCase;

  setUp(() {
    repository = FakePairingRepository();
    generateCodeUseCase = GeneratePairingCodeUseCase(repository);
    joinWithCodeUseCase = JoinWithCodeUseCase(repository);
  });

  group('Pairing UseCases', () {
    const user1Id = 'user_1';
    const user2Id = 'user_2';

    test('should generate a pairing code for a user', () async {
      final code = await generateCodeUseCase(user1Id);
      
      expect(code, isNotNull);
      expect(code.length, 6);
      expect(await repository.getCurrentPairingCode(user1Id), code);
    });

    test('should allow a second user to join with the generated code', () async {
      // 1. User 1 generates code
      final code = await generateCodeUseCase(user1Id);
      
      // 2. User 2 joins with code
      await joinWithCodeUseCase(
        currentUserId: user2Id,
        code: code,
      );

      // 3. Verify couple created
      final couple1 = await repository.getCoupleForUser(user1Id);
      final couple2 = await repository.getCoupleForUser(user2Id);

      expect(couple1, isNotNull);
      expect(couple2, isNotNull);
      expect(couple1!.id, couple2!.id); // Same couple
      expect(couple1.user1Id == user1Id || couple1.user2Id == user1Id, true);
      expect(couple1.user1Id == user2Id || couple1.user2Id == user2Id, true);
    });
  });
}
