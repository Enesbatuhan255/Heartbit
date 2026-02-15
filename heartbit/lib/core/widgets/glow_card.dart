import 'package:flutter/material.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/config/design_tokens/design_tokens.dart';
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
    this.borderRadius = DesignTokens.radiusLg, // Default: 24px (consistent)
    this.padding = const EdgeInsets.all(DesignTokens.space4), // Default: 16px
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
      duration: DesignTokens.durationSlow, // 500ms
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
  final String? lottieUrl;
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
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space5, // 24px
        vertical: DesignTokens.space4, // 16px
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
          const SizedBox(height: DesignTokens.space2), // 8px
          Text(
            label,
            style: DesignTokens.labelLarge(
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              weight: FontWeight.w600,
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

/// Standard card without glow effect
class StandardCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;

  const StandardCard({
    super.key,
    required this.child,
    this.borderRadius = DesignTokens.radiusLg,
    this.padding = const EdgeInsets.all(DesignTokens.space4),
    this.backgroundColor,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? DesignTokens.shadowMd,
      ),
      child: child,
    );
  }
}

/// Interactive card with tap effect
class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsets padding;
  final Color? backgroundColor;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = DesignTokens.radiusLg,
    this.padding = const EdgeInsets.all(DesignTokens.space4),
    this.backgroundColor,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: DesignTokens.durationFast,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isPressed
                ? DesignTokens.shadowSm
                : DesignTokens.shadowMd,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
