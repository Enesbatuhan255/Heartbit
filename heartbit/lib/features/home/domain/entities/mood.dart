
enum Mood {
  happy,
  sad,
  tired;

  String get emoji {
    switch (this) {
      case Mood.happy:
        return '😊';
      case Mood.sad:
        return '😢';
      case Mood.tired:
        return '😴';
    }
  }

  String get label {
    switch (this) {
      case Mood.happy:
        return 'Happy';
      case Mood.sad:
        return 'Sad';
      case Mood.tired:
        return 'Tired';
    }
  }
}
