
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/home/presentation/providers/connection_score_provider.dart';
import 'package:heartbit/features/user/presentation/providers/partner_provider.dart';
import 'package:heartbit/features/nudge/presentation/providers/nudge_provider.dart';
import 'package:heartbit/features/nudge/domain/entities/nudge_type.dart';
import 'package:heartbit/features/home/presentation/providers/mood_provider.dart';
import 'package:heartbit/features/home/presentation/providers/pulse_control_provider.dart';
import 'package:heartbit/features/home/domain/entities/mood.dart';

class RelationshipHub extends ConsumerWidget {
  const RelationshipHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(connectionScoreProvider);
    final partnerAsync = ref.watch(partnerStateProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding
      // Glass morphism-ish subtle container
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24), // Slightly smaller radius
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Softer shadow
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Section: Partner & Score Combined
          Row(
            children: [
              // Left: Partner Avatar (Bigger & Center of attention)
              partnerAsync.when(
                data: (partner) {
                  if (partner == null) return const CircleAvatar(backgroundColor: AppColors.surface, child: Icon(Icons.person_add));
                  
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2), // Reduced border padding
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                          boxShadow: [
                             BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 28, // Slightly smaller avatar (32 -> 28)
                          backgroundImage: NetworkImage(partner.photoUrl ?? 'https://i.pravatar.cc/150'),
                        ),
                      ),
                      // Mood Bubble
                      Positioned(
                        bottom: 0,
                        right: -4,
                        child: Consumer(
                          builder: (context, ref, _) {
                            final partnerMoodAsync = ref.watch(partnerMoodProvider);
                            return partnerMoodAsync.when(
                              data: (mood) {
                                if (mood == null) return const SizedBox();
                                return Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                                    ],
                                  ),
                                  child: Text(mood.emoji, style: const TextStyle(fontSize: 14)),
                                );
                              },
                              loading: () => const SizedBox(),
                              error: (_,__) => const SizedBox(),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(width: 56, height: 56),
                error: (_,__) => const Icon(Icons.error),
              ),
              const SizedBox(width: 12),
              
              // Right: Score & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                       children: [
                         Text(
                          '${score.todayScore}%',
                          style: TextStyle(
                            fontSize: 28, // Smaller font (32 -> 28)
                            fontWeight: FontWeight.bold,
                            color: score.todayScore >= 70 ? Colors.green : AppColors.primary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 6),
                         const Icon(Icons.favorite, color: AppColors.primary, size: 18),
                       ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bağlılık Skoru', 
                      style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12), // Reduced spacing
          
          // Divider
          Divider(color: AppColors.border.withOpacity(0.5), height: 1),
          
          const SizedBox(height: 12),
          
          // Bottom Section: Quick Nudges (Horizontal)
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: NudgeType.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final type = NudgeType.values[index];
                return _HubNudgeButton(
                  type: type,
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    // Trigger EKG Pulse
                    ref.read(pulseTriggerProvider.notifier).trigger();
                    
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
        ],
      ),
    );
  }
}

class _HubNudgeButton extends StatelessWidget {
  final NudgeType type;
  final VoidCallback onTap;

  const _HubNudgeButton({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
            ),
            child: Text(
              type.emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
           const SizedBox(height: 4),
           Text(
             type.label,
             style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
           ),
        ],
      ),
    );
  }
}
