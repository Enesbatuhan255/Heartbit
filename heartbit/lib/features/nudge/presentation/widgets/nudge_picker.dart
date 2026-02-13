import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/nudge/domain/entities/nudge_type.dart';

class NudgePicker extends StatelessWidget {
  final void Function(NudgeType) onNudgeSelected;

  const NudgePicker({
    super.key,
    required this.onNudgeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: NudgeType.values.map((type) {
          return _NudgeButton(
            type: type,
            onTap: () {
              HapticFeedback.lightImpact();
              onNudgeSelected(type);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _NudgeButton extends StatelessWidget {
  final NudgeType type;
  final VoidCallback onTap;

  const _NudgeButton({
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                type.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            type.label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
