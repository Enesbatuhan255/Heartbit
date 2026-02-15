import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../domain/entities/memory.dart';

class MemoryRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  MemoryRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  CollectionReference _memoriesCollection(String coupleId) {
    return _firestore.collection('couples').doc(coupleId).collection('memories');
  }

  Stream<List<Memory>> watchMemories(String coupleId) {
    return _memoriesCollection(coupleId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Convert Timestamps to Strings for json_serializable
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }

        return Memory.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    });
  }

  Future<List<Memory>> getMemories(String coupleId) async {
    final snapshot = await _memoriesCollection(coupleId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Convert Timestamps to Strings for json_serializable
      if (data['date'] is Timestamp) {
        data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
      }
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
      }

      return Memory.fromJson({
        'id': doc.id,
        ...data,
      });
    }).toList();
  }

  Future<int> getMemoryCount(String coupleId) async {
    final snapshot = await _memoriesCollection(coupleId).count().get();
    return snapshot.count ?? 0;
  }

  Future<Memory> addMemory(Memory memory) async {
    final docRef = _memoriesCollection(memory.coupleId).doc();
    final memoryWithId = memory.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
    );

    await docRef.set({
      'coupleId': memoryWithId.coupleId,
      'imageUrl': memoryWithId.imageUrl,
      'date': Timestamp.fromDate(memoryWithId.date),
      'description': memoryWithId.description,
      'title': memoryWithId.title,
      'createdAt': Timestamp.fromDate(memoryWithId.createdAt!),
      'createdBy': memoryWithId.createdBy,
    });

    return memoryWithId;
  }

  Future<void> deleteMemory(String coupleId, String memoryId) async {
    // Get memory to delete image from storage
    final doc = await _memoriesCollection(coupleId).doc(memoryId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final imageUrl = data['imageUrl'] as String?;
      
      // Delete image from storage if exists
      if (imageUrl != null && imageUrl.isNotEmpty && 
          (imageUrl.startsWith('http') || imageUrl.startsWith('gs://'))) {
        try {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        } on FirebaseException catch (e) {
          // Ignore if image doesn't exist or already deleted
          if (e.code != 'object-not-found') {
            rethrow;
          }
        } catch (e) {
          // Ignore other errors related to image deletion
          debugPrint('Error deleting image: $e');
        }
      }
    }

    await _memoriesCollection(coupleId).doc(memoryId).delete();
  }

  Future<String> uploadImage(String coupleId, String filePath) async {
    final file = File(filePath);
    // Verify file exists
    if (!await file.exists()) {
      debugPrint('File does not exist: $filePath');
      throw Exception('Dosya bulunamadı: $filePath');
    }
    
    // Sanitize filename to avoid special characters issues
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanFileName = 'memory_$timestamp.jpg';
    
    final ref = _storage.ref().child('memories/$coupleId/$cleanFileName');
    debugPrint('Uploading to: ${ref.fullPath}');
    debugPrint('Bucket: ${_storage.bucket}');
    debugPrint('File size: ${await file.length()} bytes');

    try {
      // Check if user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış. Lütfen tekrar giriş yapın.');
      }
      debugPrint('Authenticated user: ${currentUser.uid}');
      
      // Use putFile for better reliability with file uploads
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': currentUser.uid,
            'timestamp': timestamp.toString(),
            'originalPath': filePath,
          },
        ),
      );
      
      // Listen to upload state changes
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        debugPrint('Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
        debugPrint('Upload state: ${snapshot.state}');
      });
      
      // Wait for upload to complete
      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        debugPrint('Upload successful!');
        
        // Get download URL immediately
        final url = await snapshot.ref.getDownloadURL();
        debugPrint('Download URL: $url');
        return url;
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage Error Code: ${e.code}');
      debugPrint('Firebase Storage Error Message: ${e.message}');
      debugPrint('Firebase Storage Error Stack: ${e.stackTrace}');
      
      if (e.code == 'object-not-found') {
        throw Exception('Storage yapılandırma hatası: Dosya yolu bulunamadı. Firebase Console\'da Storage\'ın etkinleştirildiğinden emin olun.');
      } else if (e.code == 'unauthorized') {
        throw Exception('Yetki hatası: Storage erişim izni yok. Storage Rules kontrol edin.');
      } else if (e.code == 'canceled') {
        throw Exception('Yükleme iptal edildi.');
      } else if (e.code == 'unknown') {
        throw Exception('Bilinmeyen Storage hatası: ${e.message}. Firebase Console\'da Storage\'ın doğru yapılandırıldığından emin olun.');
      }
      
      throw Exception('Resim yüklenirken hata (${e.code}): ${e.message}');
    } catch (e) {
      debugPrint('Unexpected Upload Error: $e');
      throw Exception('Resim yüklenirken beklenmeyen hata: $e');
    }
  }
}
