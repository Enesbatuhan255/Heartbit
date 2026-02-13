import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:heartbit/features/nudge/domain/entities/nudge_type.dart';

/// Full-screen overlay shown when receiving a nudge
class NudgeOverlay extends StatefulWidget {
  final NudgeType nudgeType;
  final VoidCallback onDismiss;

  const NudgeOverlay({
    super.key,
    required this.nudgeType,
    required this.onDismiss,
  });

  @override
  State<NudgeOverlay> createState() => _NudgeOverlayState();
}

class _NudgeOverlayState extends State<NudgeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) => widget.onDismiss());
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
          child: Container(
            color: Colors.black.withOpacity(0.6),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Text(
                      widget.nudgeType.emoji,
                      style: const TextStyle(fontSize: 120),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.nudgeType.receiverMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
