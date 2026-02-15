import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heartbit/features/home/domain/entities/mood.dart';
import 'package:heartbit/config/theme/app_colors.dart';

/// Premium Mood Pill Component
/// 
/// A minimal, modern pill-shaped button that displays the current mood
/// or prompts the user to set one. Features subtle glow borders and
/// smooth press animations for a premium feel.
class MoodPill extends StatefulWidget {
  final Mood? selectedMood;
  final VoidCallback onTap;
  final bool isLoading;

  const MoodPill({
    super.key,
    this.selectedMood,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<MoodPill> createState() => _MoodPillState();
}

class _MoodPillState extends State<MoodPill> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    const Color(0xFF1F1F23),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.selectedMood != null
                      ? Color(widget.selectedMood!.colorValue).withOpacity(0.5)
                      : AppColors.primary.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  // Subtle outer glow
                  BoxShadow(
                    color: widget.selectedMood != null
                        ? Color(widget.selectedMood!.colorValue).withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                  // Inner glow effect
                  BoxShadow(
                    color: widget.selectedMood != null
                        ? Color(widget.selectedMood!.colorValue).withOpacity(0.05)
                        : Colors.white.withOpacity(0.03),
                    blurRadius: 8,
                    spreadRadius: -2,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : _buildContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (widget.selectedMood == null) {
      // No mood selected state
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_rounded,
            color: AppColors.primary.withOpacity(0.8),
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            'Set Mood',
            style: TextStyle(
              color: AppColors.primary.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      );
    }

    // Mood selected state
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.selectedMood!.emoji,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 8),
        Text(
          widget.selectedMood!.label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
