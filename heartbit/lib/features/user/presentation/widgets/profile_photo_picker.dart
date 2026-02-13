import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import '../providers/profile_photo_provider.dart';

class ProfilePhotoPicker extends ConsumerWidget {
  final String? currentPhotoUrl;
  final String? displayName;
  final double size;
  final bool editable;
  final VoidCallback? onPhotoChanged;

  const ProfilePhotoPicker({
    super.key,
    this.currentPhotoUrl,
    this.displayName,
    this.size = 100,
    this.editable = true,
    this.onPhotoChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerState = ref.watch(profilePhotoControllerProvider);

    return GestureDetector(
      onTap: editable
          ? () => _handlePhotoTap(context, ref)
          : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildPhoto(controllerState, ref),
            if (editable && controllerState.status != PhotoUploadStatus.uploading)
              _buildEditButton(context),
            if (controllerState.status == PhotoUploadStatus.uploading)
              _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoto(ProfilePhotoState state, WidgetRef ref) {
    if (state.status == PhotoUploadStatus.uploading) {
      return Container(
        width: size - 6,
        height: size - 6,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
      );
    }

    if (currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty) {
      return Container(
        width: size - 6,
        height: size - 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.background, width: 3),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: currentPhotoUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.surface,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            errorWidget: (context, url, error) => _buildDefaultAvatar(),
          ),
        ),
      );
    }

    return Container(
      width: size - 6,
      height: size - 6,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 3),
      ),
      child: _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        displayName?.substring(0, 1).toUpperCase() ?? '?',
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          Icons.camera_alt,
          size: size * 0.2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: SizedBox(
          width: size * 0.2,
          height: size * 0.2,
          child: const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  void _handlePhotoTap(BuildContext context, WidgetRef ref) {
    ref.read(profilePhotoControllerProvider.notifier).pickAndUploadImage(context);
  }

  static void showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile photo updated successfully'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
