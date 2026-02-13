/// Nudge types available to send to partner
enum NudgeType {
  fire,
  water,
  smile,
  missYou,
}

extension NudgeTypeExtension on NudgeType {
  String get emoji {
    switch (this) {
      case NudgeType.fire:
        return '🔥';
      case NudgeType.water:
        return '💧';
      case NudgeType.smile:
        return '😊';
      case NudgeType.missYou:
        return '💕';
    }
  }

  String get label {
    switch (this) {
      case NudgeType.fire:
        return 'Motive Ol!';
      case NudgeType.water:
        return 'Su İç!';
      case NudgeType.smile:
        return 'Gülümse!';
      case NudgeType.missYou:
        return 'Seni Özledim';
    }
  }

  String get receiverMessage {
    switch (this) {
      case NudgeType.fire:
        return 'Partnerin sana enerji gönderiyor! 🔥';
      case NudgeType.water:
        return 'Partnerin su içmeni hatırlatıyor 💧';
      case NudgeType.smile:
        return 'Partnerin gülümsemeni istiyor 😊';
      case NudgeType.missYou:
        return 'Partnerin seni özlüyor 💕';
    }
  }

  /// Firestore string key
  String get key => name;

  static NudgeType fromKey(String key) {
    return NudgeType.values.firstWhere(
      (e) => e.name == key,
      orElse: () => NudgeType.fire,
    );
  }
}
