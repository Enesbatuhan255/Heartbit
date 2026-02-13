
import 'package:heartbit/features/pet/domain/entities/pet.dart';
import 'package:heartbit/features/pet/domain/repositories/pet_repository.dart';
import 'package:heartbit/features/pet/data/datasources/pet_remote_datasource.dart';

class PetRepositoryImpl implements PetRepository {
  final PetRemoteDataSource _remoteDataSource;

  PetRepositoryImpl({required PetRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Stream<Pet?> watchPet(String coupleId) {
    return _remoteDataSource.watchPet(coupleId);
  }

  @override
  Future<void> createPet(String coupleId) {
    return _remoteDataSource.createPet(coupleId);
  }

  @override
  Future<void> updatePet(Pet pet) {
    return _remoteDataSource.updatePet(pet);
  }

  @override
  Future<void> feedPet(String petId, double amount) {
    // Note: our datasource uses coupleId as ID main key
    return _remoteDataSource.feedPet(petId, amount);
  }

  @override
  Future<void> addExperience(String coupleId, double amount) {
    return _remoteDataSource.addExperience(coupleId, amount);
  }

  @override
  Future<void> sendInteraction(String coupleId, PetInteraction interaction) {
    return _remoteDataSource.sendInteraction(coupleId, interaction);
  }
}
