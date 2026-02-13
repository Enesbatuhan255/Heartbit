import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/user/presentation/providers/partner_provider.dart';
import 'package:heartbit/features/nudge/presentation/providers/nudge_provider.dart';
import 'package:heartbit/features/nudge/domain/entities/nudge_type.dart';

class RelationshipPanel extends ConsumerWidget {
  const RelationshipPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partnerAsync = ref.watch(partnerStateProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Partner Profile
          Expanded(
            flex: 2,
            child: partnerAsync.when(
              data: (partner) {
                if (partner == null) {
                   return const Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.person_add, color: AppColors.textSecondary, size: 32),
                       SizedBox(height: 4),
                       Text('Invite', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                     ],
                   );
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(partner.photoUrl ?? 'https://i.pravatar.cc/150'),
                          backgroundColor: AppColors.secondary,
                        ),
                        if (partner.status == 'Online')
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surface, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      partner.displayName ?? 'Partner',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      partner.status ?? 'Offline',
                      style: TextStyle(
                        color: partner.status == 'Online' ? Colors.green : AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (_, __) => const Icon(Icons.error, color: AppColors.error),
            ),
          ),
          
          // Divider
          Container(
            width: 1,
            height: 60,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Right: Quick Nudges (Horizontal Scroll)
          Expanded(
            flex: 5,
            child: SizedBox(
               height: 70,
               child: ListView.separated(
                 scrollDirection: Axis.horizontal,
                 itemCount: NudgeType.values.length,
                 separatorBuilder: (_, __) => const SizedBox(width: 12),
                 itemBuilder: (context, index) {
                   final type = NudgeType.values[index];
                   return _CompactNudgeButton(
                     type: type,
                     onTap: () async {
                       HapticFeedback.lightImpact();
                       final success = await ref.read(nudgeControllerProvider.notifier).sendNudge(type);
                       if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sent "${type.label}" ❤️'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                       }
                     },
                   );
                 },
               ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactNudgeButton extends StatelessWidget {
  final NudgeType type;
  final VoidCallback onTap;

  const _CompactNudgeButton({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                type.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            type.label,
            style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
