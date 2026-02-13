
import '../entities/pet.dart';

abstract class PetRepository {
  Stream<Pet?> watchPet(String coupleId);
  Future<void> createPet(String coupleId);
  Future<void> updatePet(Pet pet);
  Future<void> feedPet(String petId, double amount);
  Future<void> addExperience(String coupleId, double amount);
  Future<void> sendInteraction(String coupleId, PetInteraction interaction);
}
