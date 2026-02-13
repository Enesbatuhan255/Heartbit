import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/daily_question/domain/utils/answer_similarity.dart';

/// Overlay widget that shows confetti celebration for synced answers
class SyncCelebration extends StatefulWidget {
  final SyncLevel syncLevel;
  final VoidCallback? onComplete;

  const SyncCelebration({
    super.key,
    required this.syncLevel,
    this.onComplete,
  });

  @override
  State<SyncCelebration> createState() => _SyncCelebrationState();
}

class _SyncCelebrationState extends State<SyncCelebration>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
    );

    // Start celebration
    _startCelebration();
  }

  void _startCelebration() async {
    _fadeController.forward();
    
    // Only play confetti for medium+ sync levels
    if (widget.syncLevel.index >= SyncLevel.medium.index) {
      _confettiController.play();
    }
    
    // Auto-dismiss after delay
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      _fadeController.reverse().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Semi-transparent background
              Container(
                color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
              ),
              
              // Confetti from top center
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2, // Downward
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.2,
                  shouldLoop: false,
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.accent,
                    Colors.pink,
                    Colors.purple,
                  ],
                ),
              ),
              
              // Celebration card
              Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildCelebrationCard(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCelebrationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji
          Text(
            widget.syncLevel.emoji,
            style: const TextStyle(fontSize: 64),
          ),
          
          const SizedBox(height: 16),
          
          // Title
          Text(
            widget.syncLevel.message,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          // XP Bonus (if any)
          if (widget.syncLevel.hasBonusXp) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '⭐',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+${widget.syncLevel.bonusXp} XP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small inline sync indicator for the answer display
class SyncIndicator extends StatelessWidget {
  final SyncLevel syncLevel;

  const SyncIndicator({
    super.key,
    required this.syncLevel,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show for low sync
    if (syncLevel == SyncLevel.low) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            syncLevel.emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Text(
            syncLevel.message,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          if (syncLevel.hasBonusXp) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '+${syncLevel.bonusXp} XP',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
