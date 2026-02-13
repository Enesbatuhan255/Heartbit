import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/user/domain/entities/user_profile.dart';
import 'package:heartbit/features/user/presentation/providers/profile_photo_provider.dart';
import 'package:heartbit/features/user/presentation/widgets/profile_photo_picker.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/user/presentation/providers/user_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(authStateProvider);

    // Listen for photo upload status changes
    ref.listen<ProfilePhotoState>(profilePhotoControllerProvider, (previous, next) {
      if (next.status == PhotoUploadStatus.success) {
        ProfilePhotoPicker.showSuccessMessage(context);
        // Reset after showing success
        Future.delayed(const Duration(seconds: 1), () {
          ref.read(profilePhotoControllerProvider.notifier).reset();
        });
      } else if (next.status == PhotoUploadStatus.error && next.errorMessage != null) {
        ProfilePhotoPicker.showErrorMessage(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('No user found', style: TextStyle(color: AppColors.textSecondary)),
            );
          }

          return _buildProfileContent(user.uid);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(child: Text('Error loading user', style: TextStyle(color: AppColors.error))),
      ),
    );
  }

  Widget _buildProfileContent(String uid) {
    final repository = ref.watch(userRepositoryProvider);

    return StreamBuilder<UserProfile?>(
      stream: repository.watchUser(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading profile', style: TextStyle(color: AppColors.error)));
        }

        final profile = snapshot.data;
        return _buildContent(uid, profile);
      },
    );
  }

  Widget _buildContent(String uid, UserProfile? profile) {


    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Center(
            child: ProfilePhotoPicker(
              currentPhotoUrl: profile?.photoUrl,
              displayName: profile?.displayName,
              size: 120,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () => ref.read(profilePhotoControllerProvider.notifier).pickAndUploadImage(context),
              icon: const Icon(Icons.camera_alt, color: AppColors.primary),
              label: const Text(
                'Change Photo',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Display Name Section
          _buildSection(
            title: 'Display Name',
            child: _buildDisplayNameField(profile?.displayName, uid),
          ),

          const SizedBox(height: 24),

          // Status Section
          _buildSection(
            title: 'Status',
            child: _buildStatusField(profile?.status, uid),
          ),

          const SizedBox(height: 24),

          // User Info
          _buildSection(
            title: 'Account Info',
            child: _buildUserInfo(uid, profile),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDisplayNameField(String? displayName, String uid) {
    return InkWell(
      onTap: () => _showEditDialog(
        title: 'Edit Display Name',
        initialValue: displayName ?? '',
        onSave: (value) => _updateDisplayName(uid, value),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_outline, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayName ?? 'Not set',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusField(String? status, String uid) {
    return InkWell(
      onTap: () => _showEditDialog(
        title: 'Edit Status',
        initialValue: status ?? '',
        onSave: (value) => _updateStatus(uid, value),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              status != null && status.isNotEmpty ? Icons.check_circle : Icons.circle_outlined,
              color: status != null && status.isNotEmpty ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                status ?? 'No status',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
             const Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(String uid, UserProfile? profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('User ID', uid.substring(0, 8) + '...'),
          const SizedBox(height: 8),
          _buildInfoRow('Last Seen', profile?.lastSeen != null ? _formatDate(profile!.lastSeen!) : 'Never'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _updateDisplayName(String uid, String value) async {
    try {
      if (value.trim().isEmpty) return;
      await ref.read(userRepositoryProvider).updateDisplayName(uid, value.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name updated successfully'), backgroundColor: AppColors.primary));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update name: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _updateStatus(String uid, String value) async {
    try {
      await ref.read(userRepositoryProvider).updateStatus(uid, value.trim());
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated successfully'), backgroundColor: AppColors.primary));
      }
    } catch (e) {
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  void _showEditDialog({
    required String title,
    required String initialValue,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter new value',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
