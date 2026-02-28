import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/egg/domain/entities/egg_status.dart';
import 'package:heartbit/features/egg/presentation/providers/egg_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/pet/presentation/providers/pet_provider.dart';

class EggWidget extends ConsumerStatefulWidget {
  const EggWidget({super.key});

  @override
  ConsumerState<EggWidget> createState() => _EggWidgetState();
}

class _EggWidgetState extends ConsumerState<EggWidget> with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(petStateProvider, (previous, next) {
      final prevPet = previous?.valueOrNull;
      final currPet = next.valueOrNull;
      final interaction = currPet?.lastInteraction;
      if (interaction == null) return;

      final prevTimestamp = prevPet?.lastInteraction?.timestamp;
      if (prevTimestamp == interaction.timestamp) return;

      final myId = ref.read(authUserIdProvider);
      if (myId != null && interaction.userId != myId) {
        _playTapBounce();
      }
    });

    final coupleAsync = ref.watch(coupleStateProvider);

    return coupleAsync.when(
      data: (couple) {
        if (couple == null) return const SizedBox();

        final status = EggStatus.fromWarmth(couple.eggWarmth, couple.isHatched);
        final warmth = couple.eggWarmth;
        final progress = (warmth / 1000).clamp(0.0, 1.0);

        if (status == EggStatus.hatched) {
          return _buildHatchedView(context, ref);
        }

        return _buildEggView(ref, warmth, status, progress);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildHatchedView(BuildContext context, WidgetRef ref) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassStroke),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 24, spreadRadius: 1),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets, size: 120, color: AppColors.primary),
          const SizedBox(height: 12),
          const Text(
            'It\'s Hatched!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          const Text('Your baby pet is here.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ref.read(petControllerProvider.notifier).createPetIfNeeded();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Meet new friend!'),
          ),
        ],
      ),
    );
  }

  Widget _buildEggView(WidgetRef ref, int warmth, EggStatus status, double progress) {
    const double visualScale = 1.25;
    const double eggWidth = 250 * visualScale;
    const double eggHeight = 330 * visualScale;
    const double stageWidth = 290 * visualScale;
    const double stageHeight = 360 * visualScale;
    const double glowSize = 220 * visualScale;
    const double shadowWidth = 128 * visualScale;
    const double shadowHeight = 24 * visualScale;

    return GestureDetector(
      onTap: () {
        ref.read(eggControllerProvider.notifier).warmEgg(10);
        ref.read(petControllerProvider.notifier).sendInteraction('poke');
        HapticFeedback.lightImpact();
        _playTapBounce();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxHeight < 250;
          final liftOffset = isCompact ? -8.0 : -16.0;
          final minVisualHeight = isCompact ? 180.0 : 220.0;
          final boundedHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight.clamp(minVisualHeight, stageHeight).toDouble()
              : stageHeight;

          return AnimatedBuilder(
            animation: Listenable.merge([_idleController, _tapController]),
            builder: (context, child) {
              final floatOffset = math.sin(_idleController.value * math.pi) * -8;
              final tapScale = 1.0 - (_tapController.value * 0.08);
              final glowBoost = _tapController.value * 0.1;

              return Transform.translate(
                offset: Offset(0, floatOffset + liftOffset),
                child: Transform.scale(
                  scale: tapScale,
                  child: SizedBox(
                    width: double.infinity,
                    height: boundedHeight,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: const Alignment(0, -0.12),
                      child: SizedBox(
                        width: stageWidth,
                        height: stageHeight,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              bottom: 16 * visualScale,
                              child: Opacity(
                                opacity: 0.30 + (_tapController.value * 0.18),
                                child: Transform.scale(
                                  scale: 1 - (_tapController.value * 0.2),
                                  child: Container(
                                    width: shadowWidth,
                                    height: shadowHeight,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.34),
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black54,
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: glowSize,
                              height: glowSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.primary.withOpacity(0.18 + glowBoost),
                                    AppColors.accent.withOpacity(0.06 + (glowBoost * 0.4)),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.58, 1.0],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: eggWidth,
                              height: eggHeight,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/egg_v2.png',
                                    width: eggWidth,
                                    height: eggHeight,
                                    fit: BoxFit.contain,
                                  ),
                                  if (progress > 0.8)
                                    const _CrackOverlay(width: eggWidth, height: eggHeight),
                                  _buildEggOverlay(status),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEggOverlay(EggStatus status) {
    if (status == EggStatus.hatching) {
      return Icon(
        Icons.auto_awesome,
        size: 84,
        color: AppColors.accent.withOpacity(0.75),
      );
    }
    return const SizedBox.shrink();
  }

  void _playTapBounce() {
    _tapController.forward().then((_) {
      if (mounted) {
        _tapController.reverse();
      }
    });
  }
}

class _CrackOverlay extends StatelessWidget {
  const _CrackOverlay({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.78,
      child: CustomPaint(
        size: Size(width, height),
        painter: _CrackPainter(),
      ),
    );
  }
}

class _CrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final glow = Paint()
      ..color = AppColors.accent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final cx = size.width * 0.48;
    final cy = size.height * 0.48;

    final crackPath = Path()
      ..moveTo(cx - 8, cy - 56)
      ..lineTo(cx + 10, cy - 26)
      ..lineTo(cx - 6, cy + 2)
      ..lineTo(cx + 16, cy + 42)
      ..moveTo(cx - 16, cy - 8)
      ..lineTo(cx - 36, cy + 22)
      ..moveTo(cx + 6, cy + 8)
      ..lineTo(cx + 34, cy + 24);

    canvas.drawPath(crackPath, glow);
    canvas.drawPath(crackPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
