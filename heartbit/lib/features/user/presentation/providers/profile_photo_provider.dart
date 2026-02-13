import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../../domain/usecases/upload_profile_image_usecase.dart';
import '../../domain/usecases/update_profile_photo_usecase.dart';
import '../providers/user_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'profile_photo_provider.g.dart';

enum PhotoUploadStatus { idle, picking, uploading, success, error }

class ProfilePhotoState {
  final PhotoUploadStatus status;
  final String? errorMessage;

  ProfilePhotoState({required this.status, this.errorMessage});

  ProfilePhotoState copyWith({PhotoUploadStatus? status, String? errorMessage}) {
    return ProfilePhotoState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class ProfilePhotoController extends _$ProfilePhotoController {
  @override
  ProfilePhotoState build() {
    return ProfilePhotoState(status: PhotoUploadStatus.idle);
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final cameraStatus = await Permission.camera.request();
      final photosStatus = await Permission.photos.request();
      return cameraStatus.isGranted || photosStatus.isGranted;
    }
    return true;
  }

  Future<void> pickAndUploadImage(BuildContext context) async {
    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      state = state.copyWith(
        status: PhotoUploadStatus.error,
        errorMessage: 'Camera or photo library permission denied',
      );
      return;
    }

    state = state.copyWith(status: PhotoUploadStatus.picking, errorMessage: null);

    try {
      final picker = ImagePicker();
      final XFile? image = await showDialog<XFile>(
        context: context,
        builder: (context) => _ImageSourceDialog(picker: picker),
      );

      if (image == null) {
        state = state.copyWith(status: PhotoUploadStatus.idle);
        return;
      }

      state = state.copyWith(status: PhotoUploadStatus.uploading);

      final authRepo = ref.read(authRepositoryProvider);
      final user = authRepo.currentUser;
      if (user == null) {
        state = state.copyWith(
          status: PhotoUploadStatus.error,
          errorMessage: 'User not authenticated',
        );
        return;
      }

      final uploadUseCase = ref.read(uploadProfileImageUseCaseProvider);
      final photoUrl = await uploadUseCase(user.uid, image.path);

      final updateUseCase = ref.read(updateProfilePhotoUseCaseProvider);
      await updateUseCase(user.uid, photoUrl);

      state = state.copyWith(status: PhotoUploadStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: PhotoUploadStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = ProfilePhotoState(status: PhotoUploadStatus.idle);
  }
}

@riverpod
UploadProfileImageUseCase uploadProfileImageUseCase(UploadProfileImageUseCaseRef ref) {
  return UploadProfileImageUseCase(ref.watch(userRepositoryProvider));
}

@riverpod
UpdateProfilePhotoUseCase updateProfilePhotoUseCase(UpdateProfilePhotoUseCaseRef ref) {
  return UpdateProfilePhotoUseCase(ref.watch(userRepositoryProvider));
}

class _ImageSourceDialog extends StatelessWidget {
  final ImagePicker picker;

  const _ImageSourceDialog({required this.picker});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Photo Source'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () async {
              final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
              if (context.mounted) Navigator.of(context).pop(image);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () async {
              final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
              if (context.mounted) Navigator.of(context).pop(image);
            },
          ),
        ],
      ),
    );
  }
}
