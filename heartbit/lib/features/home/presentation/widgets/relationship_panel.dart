import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/nudge/domain/entities/nudge_type.dart';
import 'package:heartbit/features/nudge/presentation/providers/nudge_provider.dart';
import 'package:heartbit/features/user/presentation/providers/partner_provider.dart';

class RelationshipPanel extends ConsumerWidget {
  const RelationshipPanel({super.key, this.compact = false});

  final bool compact;

  static const _quickTypes = <NudgeType>[
    NudgeType.fire,
    NudgeType.water,
    NudgeType.missYou,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partnerAsync = ref.watch(partnerStateProvider);
    final isCompact = compact || MediaQuery.sizeOf(context).height < 760;
    final cardPadding = EdgeInsets.symmetric(
      horizontal: isCompact ? 10 : 12,
      vertical: isCompact ? 8 : 10,
    );
    final avatarRadius = isCompact ? 20.0 : 22.0;
    final dividerHeight = isCompact ? 48.0 : 54.0;
    final quickButtonSize = isCompact ? 40.0 : 44.0;
    final labelSize = isCompact ? 8.5 : 9.0;

    return Container(
      padding: cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(isCompact ? 18 : 20),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: partnerAsync.when(
              data: (partner) {
                if (partner == null) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.person_add, color: AppColors.textSecondary, size: 24),
                      SizedBox(height: 4),
                      Text(
                        'Invite',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  );
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: avatarRadius,
                          backgroundImage:
                              NetworkImage(partner.photoUrl ?? 'https://i.pravatar.cc/150'),
                          backgroundColor: AppColors.secondary,
                        ),
                        if (partner.isSleeping)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surface, width: 2),
                              ),
                              child: const Text('\u{1F319}', style: TextStyle(fontSize: 10)),
                            ),
                          )
                        else if (partner.status == 'Online')
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surface, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      partner.displayName ?? 'Partner',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: isCompact ? 12 : 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      partner.isSleeping
                          ? 'Su an uyuyor'
                          : (partner.status ?? 'Offline'),
                      style: TextStyle(
                        color: partner.isSleeping
                            ? const Color(0xFFB3B9C4)
                            : (partner.status == 'Online'
                                ? Colors.green
                                : AppColors.textSecondary),
                        fontSize: 9,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => const Icon(Icons.error, color: AppColors.error, size: 18),
            ),
          ),
          Container(
            width: 1,
            height: dividerHeight,
            color: AppColors.border.withOpacity(0.6),
            margin: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 12),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: _quickTypes.map((type) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isCompact ? 2 : 3),
                    child: _CompactNudgeButton(
                      type: type,
                      compact: isCompact,
                      buttonSize: quickButtonSize,
                      labelSize: labelSize,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final success =
                            await ref.read(nudgeControllerProvider.notifier).sendNudge(type);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sent "${type.label}"'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactNudgeButton extends StatelessWidget {
  const _CompactNudgeButton({
    required this.type,
    required this.onTap,
    required this.compact,
    required this.buttonSize,
    required this.labelSize,
  });

  final NudgeType type;
  final VoidCallback onTap;
  final bool compact;
  final double buttonSize;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.75),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.16)),
            ),
            child: Center(
              child: Text(
                type.emoji,
                style: TextStyle(fontSize: compact ? 18 : 20),
              ),
            ),
          ),
          SizedBox(height: compact ? 3 : 4),
          SizedBox(
            height: 11,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                type.label,
                style: TextStyle(fontSize: labelSize, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

