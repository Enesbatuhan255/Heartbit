import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/home/domain/entities/mood.dart';
import 'package:heartbit/features/home/presentation/providers/connection_score_provider.dart';
import 'package:heartbit/features/home/presentation/providers/mood_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';

class WarmthBar extends ConsumerWidget {
  const WarmthBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(coupleStateProvider).valueOrNull;
    final score = ref.watch(connectionScoreProvider);
    final mood = ref.watch(currentMoodProvider).valueOrNull;

    if (couple == null) return const SizedBox.shrink();

    final warmth = (couple.eggWarmth / 1000).clamp(0.0, 1.0);
    final love = (score.todayScore / 100).clamp(0.0, 1.0);
    final happiness = _happinessFromMood(mood);
    final energy = _energyFromMood(mood);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassStroke),
      ),
      child: Column(
        children: [
          _AnimatedStatBar(
            label: 'Love',
            value: love,
            gradient: const LinearGradient(colors: [Color(0xFFFF4D8D), Color(0xFFFF7AAA)]),
          ),
          const SizedBox(height: 8),
          _AnimatedStatBar(
            label: 'Happiness',
            value: happiness,
            gradient: const LinearGradient(colors: [Color(0xFFF5C76B), Color(0xFFFFDFA2)]),
          ),
          const SizedBox(height: 8),
          _AnimatedStatBar(
            label: 'Energy',
            value: energy,
            gradient: const LinearGradient(colors: [Color(0xFF7A9BFF), Color(0xFF9BD2FF)]),
          ),
          const SizedBox(height: 8),
          _AnimatedStatBar(
            label: 'Warmth',
            value: warmth,
            gradient: const LinearGradient(colors: [Color(0xFFFF8C42), Color(0xFFF5C76B)]),
          ),
        ],
      ),
    );
  }

  double _happinessFromMood(Mood? mood) {
    if (mood == null) return 0.55;
    switch (mood) {
      case Mood.happy:
      case Mood.excited:
      case Mood.romantic:
        return 0.9;
      case Mood.calm:
      case Mood.energetic:
        return 0.76;
      case Mood.needHug:
      case Mood.tired:
        return 0.58;
      case Mood.low:
      case Mood.stressed:
      case Mood.sick:
        return 0.42;
    }
  }

  double _energyFromMood(Mood? mood) {
    if (mood == null) return 0.62;
    switch (mood) {
      case Mood.energetic:
      case Mood.excited:
        return 0.92;
      case Mood.happy:
      case Mood.romantic:
      case Mood.calm:
        return 0.72;
      case Mood.needHug:
      case Mood.low:
        return 0.5;
      case Mood.tired:
      case Mood.stressed:
      case Mood.sick:
        return 0.35;
    }
  }
}

class _AnimatedStatBar extends StatefulWidget {
  const _AnimatedStatBar({
    required this.label,
    required this.value,
    required this.gradient,
  });

  final String label;
  final double value;
  final Gradient gradient;

  @override
  State<_AnimatedStatBar> createState() => _AnimatedStatBarState();
}

class _AnimatedStatBarState extends State<_AnimatedStatBar> with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 74,
          child: Text(
            widget.label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 12,
              color: Colors.white.withOpacity(0.07),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: widget.value),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                builder: (context, animatedValue, _) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: animatedValue,
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, _) {
                        final shimmerX = (_shimmerController.value * 2) - 1;
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: widget.gradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.25),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(shimmerX - 0.4, 0),
                                end: Alignment(shimmerX + 0.2, 0),
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white.withOpacity(0.24),
                                  Colors.white.withOpacity(0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text(
            '${(widget.value * 100).round()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
