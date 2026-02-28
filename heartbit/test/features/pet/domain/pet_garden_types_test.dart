import 'package:flutter_test/flutter_test.dart';
import 'package:heartbit/features/pet/domain/entities/pet_garden_types.dart';

void main() {
  group('PetGardenTab', () {
    test('contains only feed and decor', () {
      expect(PetGardenTab.values, [PetGardenTab.feed, PetGardenTab.decor]);
    });
  });

  group('PetGardenCatalog', () {
    test('initial inventory has all catalog items with positive quantity', () {
      final inventory = PetGardenCatalog.initialInventory;
      final all = PetGardenCatalog.all;

      expect(inventory.length, all.length);

      for (final item in all) {
        expect(inventory.containsKey(item.id), isTrue);
        expect(inventory[item.id]! > 0, isTrue);
      }
    });

    test('catalog includes only feed/decor and both groups are non-empty', () {
      final categories =
          PetGardenCatalog.all.map((item) => item.category).toSet();
      expect(categories.contains(PetGardenTab.feed), isTrue);
      expect(categories.contains(PetGardenTab.decor), isTrue);
      expect(categories.length, 2);
    });
  });
}
