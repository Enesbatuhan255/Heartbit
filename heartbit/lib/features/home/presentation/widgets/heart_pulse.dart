import 'package:flutter/material.dart';
import 'package:heartbit/config/theme/app_colors.dart';

/// Heart Pulse Animation Widget
///
/// Displays a pulsing heart animation when mood is selected.
/// Provides emotional feedback to enhance the user experience.
class HeartPulse extends StatefulWidget {
  final VoidCallback? onComplete;
  final double size;

  const HeartPulse({
    super.key,
    this.onComplete,
    this.size = 80,
  });

  @override
  State<HeartPulse> createState() => _HeartPulseState();
}

class _HeartPulseState extends State<HeartPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Heart beat effect - quick double pulse
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0)
            .chain(CurveTween(curve: Curves.linear)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5 * _opacityAnimation.value),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite,
                color: Colors.white,
                size: widget.size * 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Floating hearts animation that shows multiple small hearts
/// floating upward when mood is selected
class FloatingHearts extends StatefulWidget {
  final int count;

  const FloatingHearts({
    super.key,
    this.count = 5,
  });

  @override
  State<FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<FloatingHearts>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _animations = [];
  final List<Offset> _startPositions = [];
  final List<double> _sizes = [];
  final List<Color> _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    const Color(0xFFFF8C42),
    const Color(0xFF10B981),
  ];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.count; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 1500 + (i * 200)),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOut)).animate(controller);

      _controllers.add(controller);
      _animations.add(animation);
      _startPositions.add(Offset(
        (i - widget.count / 2) * 30,
        0,
      ));
      _sizes.add(15 + (i * 3).toDouble());

      // Stagger animations
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) controller.forward();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: List.generate(widget.count, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              final progress = _animations[index].value;
              return Transform.translate(
                offset: Offset(
                  _startPositions[index].dx,
                  -progress * 120,
                ),
                child: Opacity(
                  opacity: (1 - progress).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 1 - (progress * 0.3),
                    child: Icon(
                      Icons.favorite,
                      color: _colors[index % _colors.length].withOpacity(0.8),
                      size: _sizes[index],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
