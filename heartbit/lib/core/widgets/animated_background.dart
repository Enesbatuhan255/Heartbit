import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:heartbit/config/theme/app_colors.dart';

/// Animated background with subtle heartbeat wave effect
/// Creates visual depth without distracting from content
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final double speed;
  
  const AnimatedBackground({
    super.key,
    required this.child,
    this.speed = 1.0,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _getDuration(),
    )..repeat();
  }

  @override
  void didUpdateWidget(AnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      _controller.duration = _getDuration();
      if (_controller.isAnimating) {
        _controller.repeat(); // Restart with new duration to apply speed change immediately smoothish
      }
    }
  }

  Duration _getDuration() {
    // Base duration is 4 seconds. Higher speed = Lower duration.
    // Clamp to avoid division by zero or negative.
    final effectiveSpeed = widget.speed <= 0 ? 1.0 : widget.speed;
    return Duration(milliseconds: (4000 / effectiveSpeed).round());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated heartbeat wave background
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: HeartbeatWavePainter(
                  animation: _controller.value,
                  color: AppColors.primary.withOpacity(0.06),
                ),
              );
            },
          ),
        ),
        // Subtle floating particles
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: FloatingParticlesPainter(
                  animation: _controller.value,
                  color: AppColors.secondary.withOpacity(0.04),
                ),
              );
            },
          ),
        ),
        // Main content
        widget.child,
      ],
    );
  }
}

/// Paints a heartbeat-like wave pattern
class HeartbeatWavePainter extends CustomPainter {
  final double animation;
  final Color color;

  HeartbeatWavePainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final waveHeight = size.height * 0.03;
    final centerY = size.height * 0.85; // Position wave near bottom
    
    // Offset based on animation
    final offset = animation * size.width * 0.5;

    path.moveTo(-offset, centerY);

    for (double x = -offset; x < size.width + 50; x += 1) {
      // Create heartbeat-like pattern
      final normalizedX = (x + offset) / size.width;
      final cycle = (normalizedX * 4) % 1.0;
      
      double y;
      if (cycle < 0.1) {
        // Flat line
        y = centerY;
      } else if (cycle < 0.15) {
        // Small dip
        y = centerY + waveHeight * 0.3 * math.sin((cycle - 0.1) / 0.05 * math.pi);
      } else if (cycle < 0.25) {
        // Big spike up
        y = centerY - waveHeight * 2 * math.sin((cycle - 0.15) / 0.1 * math.pi);
      } else if (cycle < 0.35) {
        // Spike down
        y = centerY + waveHeight * 0.8 * math.sin((cycle - 0.25) / 0.1 * math.pi);
      } else if (cycle < 0.45) {
        // Small bump
        y = centerY - waveHeight * 0.5 * math.sin((cycle - 0.35) / 0.1 * math.pi);
      } else {
        // Flat line
        y = centerY;
      }
      
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
    
    // Draw a second, more subtle wave slightly offset
    final paint2 = Paint()
      ..color = color.withOpacity(color.opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final path2 = Path();
    final centerY2 = size.height * 0.75;
    
    path2.moveTo(-offset - 100, centerY2);
    for (double x = -offset - 100; x < size.width + 50; x += 1) {
      final normalizedX = (x + offset + 100) / size.width;
      final cycle = (normalizedX * 3) % 1.0;
      
      double y;
      if (cycle < 0.15 || cycle > 0.5) {
        y = centerY2;
      } else if (cycle < 0.25) {
        y = centerY2 - waveHeight * 1.5 * math.sin((cycle - 0.15) / 0.1 * math.pi);
      } else if (cycle < 0.35) {
        y = centerY2 + waveHeight * 0.6 * math.sin((cycle - 0.25) / 0.1 * math.pi);
      } else {
        y = centerY2 - waveHeight * 0.3 * math.sin((cycle - 0.35) / 0.15 * math.pi);
      }
      
      path2.lineTo(x, y);
    }
    
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(HeartbeatWavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// Paints subtle floating particles
class FloatingParticlesPainter extends CustomPainter {
  final double animation;
  final Color color;
  
  // Fixed particle positions (seeded for consistency)
  static final List<Offset> _particlePositions = List.generate(
    12,
    (i) => Offset(
      (i * 0.17 + 0.05) % 1.0,
      (i * 0.23 + 0.1) % 1.0,
    ),
  );

  FloatingParticlesPainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < _particlePositions.length; i++) {
      final basePos = _particlePositions[i];
      
      // Gentle floating motion
      final floatOffset = math.sin(animation * 2 * math.pi + i * 0.5) * 0.02;
      final x = basePos.dx * size.width;
      final y = (basePos.dy + floatOffset) * size.height;
      
      // Varying sizes
      final radius = 2.0 + (i % 3) * 1.5;
      
      // Subtle pulsing opacity
      final opacity = 0.3 + 0.3 * math.sin(animation * 2 * math.pi + i);
      paint.color = color.withOpacity(color.opacity * opacity);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(FloatingParticlesPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
