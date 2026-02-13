import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/config/theme/app_colors.dart';
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
        title: const Text(
          'Bucket List 💕',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: bucketListAsync.when(
        data: (bucketItems) {
          if (bucketItems.isEmpty) {
            return _buildEmptyState(context);
          }

          return activitiesAsync.when(
            data: (activities) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
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
                    onStatusChange: (newStatus) {
                      // TODO: Implement status change
                    },
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => Center(
              child: Text('Error: $e', style: const TextStyle(color: AppColors.error)),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Bucket List is Empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Swipe right on activities you both love!\nWhen you match, they\'ll appear here.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.swipe, color: Colors.white),
              label: const Text(
                'Start Swiping',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
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
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activityTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activityDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
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
                      const SizedBox(width: 8),
                    ],
                    if (item.isPlanned) ...[
                      _buildActionButton(
                        icon: Icons.check_circle,
                        label: 'Done!',
                        color: AppColors.accent,
                        onTap: () => onStatusChange('completed'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      'Matched ${_formatDate(item.matchedAt)}',
                      style: TextStyle(
                        fontSize: 12,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
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
