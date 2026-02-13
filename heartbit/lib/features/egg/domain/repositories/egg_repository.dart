abstract class EggRepository {
  Future<void> incrementWarmth(String coupleId, int amount);
  Future<void> setHatched(String coupleId);
}
