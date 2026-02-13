import 'package:flutter/material.dart';
import 'package:heartbit/config/theme/app_colors.dart';

/// Emoji reaction options
enum ReactionType {
  heart('❤️', 'heart'),
  laugh('😂', 'laugh'),
  surprised('😮', 'surprised');

  final String emoji;
  final String value;
  const ReactionType(this.emoji, this.value);

  static ReactionType? fromValue(String? value) {
    if (value == null) return null;
    return ReactionType.values.firstWhere(
      (r) => r.value == value,
      orElse: () => ReactionType.heart,
    );
  }
}

/// Animated reaction bar widget for Daily Question
class ReactionBar extends StatefulWidget {
  final String? currentReaction;
  final Function(String reaction) onReactionSelected;

  const ReactionBar({
    super.key,
    this.currentReaction,
    required this.onReactionSelected,
  });

  @override
  State<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      ReactionType.values.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.4).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTap(int index, ReactionType reaction) {
    // Play bounce animation
    _controllers[index].forward().then((_) {
      _controllers[index].reverse();
    });
    
    // Trigger callback
    widget.onReactionSelected(reaction.value);
  }

  @override
  Widget build(BuildContext context) {
    final hasReacted = widget.currentReaction != null;
    final currentReactionType = ReactionType.fromValue(widget.currentReaction);

    // If already reacted, show only the selected reaction
    if (hasReacted && currentReactionType != null) {
      return _buildReactedState(currentReactionType);
    }

    // Show reaction picker
    return _buildReactionPicker();
  }

  Widget _buildReactedState(ReactionType reaction) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            reaction.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
          Text(
            'Tepkin gönderildi',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tepki ver:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          ...List.generate(ReactionType.values.length, (index) {
            final reaction = ReactionType.values[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => _onTap(index, reaction),
                child: AnimatedBuilder(
                  animation: _scaleAnimations[index],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimations[index].value,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          reaction.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
