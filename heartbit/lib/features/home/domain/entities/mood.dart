enum Mood {
  happy,
  needHug,
  energetic,
  tired,
  low,
  romantic,
  stressed,
  calm,
  excited,
  sick;

  String get emoji {
    switch (this) {
      case Mood.happy:
        return '🙂';
      case Mood.needHug:
        return '🥺';
      case Mood.energetic:
        return '🔥';
      case Mood.tired:
        return '😴';
      case Mood.low:
        return '😔';
      case Mood.romantic:
        return '💞';
      case Mood.stressed:
        return '😡';
      case Mood.calm:
        return '😌';
      case Mood.excited:
        return '🤩';
      case Mood.sick:
        return '🤒';
    }
  }

  String get label {
    switch (this) {
      case Mood.happy:
        return 'Happy';
      case Mood.needHug:
        return 'Need Hug';
      case Mood.energetic:
        return 'Energetic';
      case Mood.tired:
        return 'Tired';
      case Mood.low:
        return 'Low';
      case Mood.romantic:
        return 'Romantic';
      case Mood.stressed:
        return 'Stressed';
      case Mood.calm:
        return 'Calm';
      case Mood.excited:
        return 'Excited';
      case Mood.sick:
        return 'Sick';
    }
  }

  int get colorValue {
    switch (this) {
      case Mood.happy:
        return 0xFFFFD166;
      case Mood.needHug:
        return 0xFFFFB7C5;
      case Mood.energetic:
        return 0xFFFF6B35;
      case Mood.tired:
        return 0xFF7B8CDE;
      case Mood.low:
        return 0xFF6B7280;
      case Mood.romantic:
        return 0xFFFF4B7D;
      case Mood.stressed:
        return 0xFFDC2626;
      case Mood.calm:
        return 0xFF10B981;
      case Mood.excited:
        return 0xFF7B61FF;
      case Mood.sick:
        return 0xFF84CC16;
    }
  }
}
