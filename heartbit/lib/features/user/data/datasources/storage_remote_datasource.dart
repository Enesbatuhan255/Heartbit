import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

abstract class StorageRemoteDataSource {
  Future<String> uploadProfilePhoto(String uid, String filePath);
  Future<String> uploadProfilePhotoFromBytes(String uid, Uint8List bytes, String extension);
}

class StorageRemoteDataSourceImpl implements StorageRemoteDataSource {
  final FirebaseStorage _storage;

  StorageRemoteDataSourceImpl({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadProfilePhoto(String uid, String filePath) async {
    final file = File(filePath);
    final fileExtension = path.extension(filePath);
    final ref = _storage.ref().child('profile_photos').child(uid).child('profile$fileExtension');

    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Future<String> uploadProfilePhotoFromBytes(String uid, Uint8List bytes, String extension) async {
    final ref = _storage.ref().child('profile_photos').child(uid).child('profile$extension');
    final uploadTask = ref.putData(bytes);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
