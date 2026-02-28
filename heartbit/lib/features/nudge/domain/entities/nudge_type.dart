/// Nudge types available to send to partner
enum NudgeType {
  fire,
  water,
  smile,
  thinking,
  missYou,
  love,
}

extension NudgeTypeExtension on NudgeType {
  String get emoji {
    switch (this) {
      case NudgeType.fire:
        return '\u{1F525}';
      case NudgeType.water:
        return '\u{1F4A7}';
      case NudgeType.smile:
        return '\u{1F60A}';
      case NudgeType.thinking:
        return '\u{1F4AD}';
      case NudgeType.missYou:
        return '\u{1F495}';
      case NudgeType.love:
        return '\u{1F496}';
    }
  }

  String get label {
    switch (this) {
      case NudgeType.fire:
        return 'Motive Ol!';
      case NudgeType.water:
        return 'Su \u0130\u00e7!';
      case NudgeType.smile:
        return 'G\u00fcl\u00fcmse!';
      case NudgeType.thinking:
        return 'D\u00fc\u015f\u00fcn\u00fcyorum';
      case NudgeType.missYou:
        return 'Seni \u00d6zledim';
      case NudgeType.love:
        return 'Seviyorum';
    }
  }

  String get receiverMessage {
    switch (this) {
      case NudgeType.fire:
        return 'Partnerin sana enerji g\u00f6nderiyor! \u{1F525}';
      case NudgeType.water:
        return 'Partnerin su i\u00e7meni hat\u0131rlat\u0131yor \u{1F4A7}';
      case NudgeType.smile:
        return 'Partnerin g\u00fcl\u00fcmsemeni istiyor \u{1F60A}';
      case NudgeType.thinking:
        return 'Partnerin seni d\u00fc\u015f\u00fcn\u00fcyor! \u{1F4AD}';
      case NudgeType.missYou:
        return 'Partnerin seni \u00f6zl\u00fcyor \u{1F495}';
      case NudgeType.love:
        return 'Partnerin seni seviyor! \u{1F496}';
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
