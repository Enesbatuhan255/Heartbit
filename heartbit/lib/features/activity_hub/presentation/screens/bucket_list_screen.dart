import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/config/design_tokens/design_tokens.dart';
import 'package:heartbit/core/widgets/empty_states.dart';
import '../providers/activity_provider.dart';
import '../../domain/entities/bucket_item.dart';

class BucketListScreen extends ConsumerWidget {
  const BucketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucketListAsync = ref.watch(bucketListProvider);
    final activitiesAsync = ref.watch(availableActivitiesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bucket List 💕',
          style: DesignTokens.heading4(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: bucketListAsync.when(
        data: (bucketItems) {
          if (bucketItems.isEmpty) {
            return EmptyBucketListState(
              onAddItem: () => Navigator.pop(context),
            );
          }

          return activitiesAsync.when(
            data: (activities) {
              return ListView.builder(
                padding: DesignTokens.padding4,
                itemCount: bucketItems.length,
                itemBuilder: (context, index) {
                  final item = bucketItems[index];
                  final activity = activities.firstWhere(
                    (a) => a.id == item.activityId,
                    orElse: () => activities.first,
                  );

                  return _BucketItemCard(
                    item: item,
                    activityTitle: activity.title,
                    activityDescription: activity.description,
                    activityImageUrl: activity.imageUrl,
                    onStatusChange: (newStatus) async {
                      await ref.read(bucketListControllerProvider.notifier)
                          .updateItemStatus(item.id, newStatus);
                    },
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => ErrorState(
              message: 'Error: $e',
              onRetry: () => ref.refresh(bucketListProvider),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => ErrorState(
          message: 'Error: $e',
          onRetry: () => ref.refresh(bucketListProvider),
        ),
      ),
    );
  }

}

class _BucketItemCard extends StatelessWidget {
  final BucketItem item;
  final String activityTitle;
  final String activityDescription;
  final String activityImageUrl;
  final Function(String) onStatusChange;

  const _BucketItemCard({
    required this.item,
    required this.activityTitle,
    required this.activityDescription,
    required this.activityImageUrl,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.space4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: DesignTokens.borderRadiusMd,
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 2,
        ),
        boxShadow: DesignTokens.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusMd)),
            child: Stack(
              children: [
                Image.network(
                  activityImageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: AppColors.primary.withOpacity(0.2),
                    child: const Icon(Icons.image, color: AppColors.primary, size: 40),
                  ),
                ),
                // Status Badge
                Positioned(
                  top: DesignTokens.space3,
                  right: DesignTokens.space3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space3, vertical: DesignTokens.space1),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: DesignTokens.borderRadiusMd,
                    ),
                    child: Text(
                      _getStatusText(),
                      style: DesignTokens.labelSmall(
                        color: Colors.white,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: DesignTokens.padding4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activityTitle,
                  style: DesignTokens.heading4(color: AppColors.textPrimary),
                ),
                const SizedBox(height: DesignTokens.space1),
                Text(
                  activityDescription,
                  style: DesignTokens.bodyMedium(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: DesignTokens.space3),
                
                // Action Buttons
                Row(
                  children: [
                    if (item.isPending) ...[
                      _buildActionButton(
                        icon: Icons.calendar_today,
                        label: 'Plan It',
                        color: AppColors.primary,
                        onTap: () => onStatusChange('planned'),
                      ),
                      const SizedBox(width: DesignTokens.space2),
                    ],
                    if (item.isPlanned) ...[
                      _buildActionButton(
                        icon: Icons.check_circle,
                        label: 'Done!',
                        color: AppColors.accent,
                        onTap: () => onStatusChange('completed'),
                      ),
                      const SizedBox(width: DesignTokens.space2),
                    ],
                    Text(
                      'Matched ${_formatDate(item.matchedAt)}',
                      style: DesignTokens.labelSmall(
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space3, vertical: DesignTokens.space2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: DesignTokens.borderRadiusMd,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: DesignTokens.space1),
            Text(
              label,
              style: DesignTokens.labelSmall(
                color: color,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (item.status) {
      case 'pending':
        return AppColors.secondary;
      case 'planned':
        return AppColors.primary;
      case 'completed':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText() {
    switch (item.status) {
      case 'pending':
        return '💭 Pending';
      case 'planned':
        return '📅 Planned';
      case 'completed':
        return '✅ Done';
      default:
        return item.status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}';
  }
}
