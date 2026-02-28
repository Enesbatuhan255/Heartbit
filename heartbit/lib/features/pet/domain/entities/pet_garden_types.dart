import 'package:flutter/material.dart';

enum PetGardenTab { feed, decor }

enum PetAnimationState { idle, hungry, happy, feeding, loving }

class PetGardenItem {
  const PetGardenItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.category,
    required this.color,
    this.hungerGain = 0,
    this.happinessGain = 0,
    this.description,
  });

  final String id;
  final String title;
  final IconData icon;
  final PetGardenTab category;
  final Color color;
  final int hungerGain;
  final int happinessGain;
  final String? description;
}

class PetGardenCatalog {
  static const List<PetGardenItem> feedItems = [
    PetGardenItem(
      id: 'feed_soup',
      title: 'Corba',
      icon: Icons.soup_kitchen_rounded,
      category: PetGardenTab.feed,
      color: Color(0xFFFFF3DE),
      hungerGain: 18,
      happinessGain: 6,
      description: 'Sicak ve doyurucu.',
    ),
    PetGardenItem(
      id: 'feed_salad',
      title: 'Salata',
      icon: Icons.eco_rounded,
      category: PetGardenTab.feed,
      color: Color(0xFFEFFBE8),
      hungerGain: 12,
      happinessGain: 8,
      description: 'Hafif ve taze.',
    ),
    PetGardenItem(
      id: 'feed_fish',
      title: 'Balik',
      icon: Icons.set_meal_rounded,
      category: PetGardenTab.feed,
      color: Color(0xFFE6F3FF),
      hungerGain: 20,
      happinessGain: 10,
      description: 'Favori menu.',
    ),
    PetGardenItem(
      id: 'feed_pudding',
      title: 'Puding',
      icon: Icons.icecream_rounded,
      category: PetGardenTab.feed,
      color: Color(0xFFFFF7CC),
      hungerGain: 10,
      happinessGain: 12,
      description: 'Tatli bir odul.',
    ),
    PetGardenItem(
      id: 'feed_shrimp',
      title: 'Karides',
      icon: Icons.lunch_dining_rounded,
      category: PetGardenTab.feed,
      color: Color(0xFFFFEFE8),
      hungerGain: 16,
      happinessGain: 10,
      description: 'Protein gucu.',
    ),
    PetGardenItem(
      id: 'feed_apple',
      title: 'Elma',
      icon: Icons.apple_rounded,
      category: PetGardenTab.feed,
      color: Color(0xFFFFEFF0),
      hungerGain: 8,
      happinessGain: 6,
      description: 'Hizli atistirmalik.',
    ),
  ];

  static const List<PetGardenItem> decorItems = [
    PetGardenItem(
      id: 'decor_pillow',
      title: 'Yastik',
      icon: Icons.bed_rounded,
      category: PetGardenTab.decor,
      color: Color(0xFFEFF3FF),
      description: 'Uyku kalitesini artirir.',
    ),
    PetGardenItem(
      id: 'decor_lamp',
      title: 'Lamba',
      icon: Icons.light_rounded,
      category: PetGardenTab.decor,
      color: Color(0xFFFFF2E0),
      description: 'Ortama sicaklik katar.',
    ),
    PetGardenItem(
      id: 'decor_speaker',
      title: 'Muzik',
      icon: Icons.speaker_rounded,
      category: PetGardenTab.decor,
      color: Color(0xFFEDEBFF),
      description: 'Mutlu melodiler.',
    ),
    PetGardenItem(
      id: 'decor_plant',
      title: 'Bitki',
      icon: Icons.local_florist_rounded,
      category: PetGardenTab.decor,
      color: Color(0xFFE7F8EA),
      description: 'Dogal bir hava.',
    ),
    PetGardenItem(
      id: 'decor_rug',
      title: 'Hali',
      icon: Icons.grid_view_rounded,
      category: PetGardenTab.decor,
      color: Color(0xFFFFF0F5),
      description: 'Konforlu bir alan.',
    ),
    PetGardenItem(
      id: 'decor_toy',
      title: 'Oyuncak',
      icon: Icons.toys_rounded,
      category: PetGardenTab.decor,
      color: Color(0xFFFFF8E5),
      description: 'Eglenceli vakit.',
    ),
  ];

  static List<PetGardenItem> get all => [...feedItems, ...decorItems];

  static Map<String, int> get initialInventory {
    final seed = <String, int>{};
    for (final item in all) {
      seed[item.id] = item.category == PetGardenTab.feed ? 3 : 1;
    }
    return seed;
  }
}
