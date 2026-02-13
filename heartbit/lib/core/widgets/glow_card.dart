import 'package:flutter/material.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:lottie/lottie.dart';

/// A card with animated glow effect around its border
class GlowCard extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final bool isPulsing;
  final double borderRadius;
  final EdgeInsets padding;

  const GlowCard({
    super.key,
    required this.child,
    this.glowColor = AppColors.primary,
    this.isPulsing = false,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  State<GlowCard> createState() => _GlowCardState();
}

class _GlowCardState extends State<GlowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPulsing && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0.7;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowIntensity = widget.isPulsing ? _glowAnimation.value : 0.6;
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              // Outer glow
              BoxShadow(
                color: widget.glowColor.withOpacity(0.3 * glowIntensity),
                blurRadius: 20 * glowIntensity,
                spreadRadius: 2,
              ),
              // Inner glow (tighter)
              BoxShadow(
                color: widget.glowColor.withOpacity(0.2 * glowIntensity),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: widget.glowColor.withOpacity(0.4 * glowIntensity),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface,
                  widget.glowColor.withOpacity(0.05),
                ],
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Pre-styled relationship status card
class RelationshipStatusCard extends StatelessWidget {
  final String? emoji;
  final String? lottieUrl; // Support Lottie
  final String label;
  final Color color;
  final bool isActive;

  const RelationshipStatusCard({
    super.key,
    this.emoji,
    this.lottieUrl,
    required this.label,
    required this.color,
    this.isActive = true,
  }) : assert(emoji != null || lottieUrl != null, 'Must provide emoji or lottieUrl');

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      glowColor: color,
      isPulsing: isActive && label == 'On Fire',
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (lottieUrl != null) {
      return SizedBox(
        height: 60,
        width: 60,
        child: Lottie.network(
          lottieUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to emoji if error
            return Text(
              emoji ?? '❓',
              style: const TextStyle(fontSize: 42),
            );
          },
        ),
      );
    }
    
    return Text(
      emoji ?? '',
      style: const TextStyle(fontSize: 42),
    );
  }
}
