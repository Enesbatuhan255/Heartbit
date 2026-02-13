enum EggStatus {
  cold,
  warm,
  cracking,
  hatching,
  hatched;

  static EggStatus fromWarmth(int warmth, bool isHatched) {
    if (isHatched) return EggStatus.hatched;
    if (warmth >= 900) return EggStatus.hatching;
    if (warmth >= 600) return EggStatus.cracking;
    if (warmth >= 300) return EggStatus.warm;
    return EggStatus.cold;
  }
}
