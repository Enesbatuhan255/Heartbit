
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/features/egg/domain/entities/egg_status.dart';
import 'package:heartbit/features/egg/presentation/providers/egg_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/pet/presentation/providers/pet_provider.dart';
import 'package:heartbit/features/home/presentation/providers/pulse_control_provider.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:lottie/lottie.dart';

class EggWidget extends ConsumerStatefulWidget {
  const EggWidget({super.key});

  @override
  ConsumerState<EggWidget> createState() => _EggWidgetState();
}

class _EggWidgetState extends ConsumerState<EggWidget> with TickerProviderStateMixin {
  late AnimationController _ekgController;
  late AnimationController _breathController;
  late AnimationController _giggleController;
  late AnimationController _heartController;

  // Tap tracking for giggle feature
  final List<DateTime> _tapTimes = [];
  final List<HeartParticle> _hearts = [];
  bool _isGiggling = false;

  @override
  void initState() {
    super.initState();
    _ekgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Giggle animation controller
    _giggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Heart animation controller
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _ekgController.dispose();
    _breathController.dispose();
    _giggleController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for remote interactions
    ref.listen(petStateProvider, (previous, next) {
      final prevPet = previous?.valueOrNull;
      final currPet = next.valueOrNull;

      if (currPet?.lastInteraction != null) {
        final interaction = currPet!.lastInteraction!;
        // Check if it's a new interaction
        // Note: We might need a more robust check than object equality if objects are recreated,
        // but verify if Equatable or distinct timestamps handle this. 
        // Timestamp check is safest.
        final prevTimestamp = prevPet?.lastInteraction?.timestamp;
        
        if (prevTimestamp != interaction.timestamp) {
           final myId = ref.read(authUserIdProvider);
           // Only trigger for partner's actions (remote)
           if (myId != null && interaction.userId != myId) {
             _triggerGiggle();
           }
        }
      }
    });

    final coupleAsync = ref.watch(coupleStateProvider);
    
    return coupleAsync.when(
      data: (couple) {
        if (couple == null) return const SizedBox();
        
        // Determine status
        final status = EggStatus.fromWarmth(couple.eggWarmth, couple.isHatched);
        final warmth = couple.eggWarmth;
        final progress = (warmth / 1000).clamp(0.0, 1.0);
        
        if (status == EggStatus.hatched) {
           return _buildHatchedView(context, ref);
        }

        return _buildEggView(context, ref, warmth, status, progress);
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.pumpingHeart.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie link expired (403), using fallback icon
          const Icon(
            Icons.pets,
            size: 120,
            color: AppColors.pumpingHeart,
          ),
          const SizedBox(height: 16),
          const Text(
            'It\'s Hatched!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.pumpingHeart,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
             'Your baby pet is here.',
             style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
               ref.read(petControllerProvider.notifier).createPetIfNeeded();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pumpingHeart,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Meet new friend!'),
          ),
        ],
      ),
    );
  }

  Widget _buildEggView(BuildContext context, WidgetRef ref, int warmth, EggStatus status, double progress) {
    // HERO DIMENSIONS: Reduced to fit screen
    final double eggWidth = 260;
    final double eggHeight = 350;

    return GestureDetector(
      onTap: () {
        // Tap to warm
        ref.read(eggControllerProvider.notifier).warmEgg(10);
        HapticFeedback.lightImpact();

        // Track taps for giggle feature
        _handleTap();
        
        // Send interaction to backend (fire and forget)
        ref.read(petControllerProvider.notifier).sendInteraction('poke');
      },
      child: Transform.scale(
        scale: 1.0,
        child: SizedBox(
          height: 350,
          width: 280,
          child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none, // Allow glow to spill out
          children: [
             // 0. The Nest / Grounding / Atmosphere - REMOVED for clean image look

             // Floating Hearts (Giggle Effect)
             ..._buildHeartParticles(),

            // 2. The Egg with Shake + Breath Animation
            Positioned(
              bottom: 20, // Reduced from 60 to prevent overflow
              child: AnimatedBuilder(
                animation: Listenable.merge([_breathController, _giggleController]),
                builder: (context, child) {
                   // Breath Logic (Scale 1.0 -> 1.03)
                   double scale = 1.0 + (_breathController.value * 0.03);

                   // Giggle Shake Logic (Rapid left-right shake)
                   double giggleDx = 0;
                   if (_isGiggling && _giggleController.isAnimating) {
                     giggleDx = math.sin(_giggleController.value * math.pi * 10) * 8;
                   }

                   return Transform(
                     transform: Matrix4.identity()
                       ..translate(giggleDx, 0)
                       ..scale(scale),
                     alignment: Alignment.center,
                     child: child,
                   );
                },
                child: Container(
                  width: eggWidth,
                  height: eggHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                        // THE IMAGE ASSET
                        Image.asset(
                          'assets/images/egg_v2.png',
                          width: eggWidth,
                          height: eggHeight,
                          fit: BoxFit.contain,
                        ),
                        
                        // Icon overlay for cracking state
                        Center(child: _buildEggOverlay(status)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildCracks() {
    return CustomPaint(
      size: Size(312, 390),
      painter: _CracksPainter(),
    );
  }

  Widget _buildEggOverlay(EggStatus status) {
     if (status == EggStatus.hatching) {
       return const Icon(Icons.flash_on, size: 100, color: Colors.orange);
     } else if (status == EggStatus.cracking) {
       // Maybe a static crack image or icon?
       // _CracksPainter handles the main visuals now
     }
     return const SizedBox();
  }

  // ========== GIGGLE FEATURE METHODS ==========

  void _handleTap() {
    final now = DateTime.now();

    // Add current tap time
    _tapTimes.add(now);

    // Remove taps older than 3 seconds
    _tapTimes.removeWhere((time) => now.difference(time) > const Duration(seconds: 3));

    // Check if we have 5+ taps in 3 seconds
    if (_tapTimes.length >= 5 && !_isGiggling) {
      _triggerGiggle();
    }
  }

  void _triggerGiggle() {
    setState(() {
      _isGiggling = true;
    });

    // Trigger giggle shake animation
    _giggleController.forward().then((_) {
      _giggleController.reset();
    });

    // Spawn hearts
    _spawnHearts();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Reset after animation
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _isGiggling = false;
        });
      }
      // Clear tap history to prevent immediate re-trigger
      _tapTimes.clear();
    });
  }

  void _spawnHearts() {
    final random = math.Random();
    for (int i = 0; i < 8; i++) {
      _hearts.add(HeartParticle(
        angle: (i / 8) * 2 * math.pi + random.nextDouble() * 0.5,
        speed: 0.5 + random.nextDouble() * 0.5,
        size: 20.0 + random.nextDouble() * 15.0,
      ));
    }

    // Start heart animation
    _heartController.forward().then((_) {
      _heartController.reset();
      if (mounted) {
        setState(() {
          _hearts.clear();
        });
      }
    });
  }

  List<Widget> _buildHeartParticles() {
    return _hearts.map((heart) {
      return AnimatedBuilder(
        animation: _heartController,
        builder: (context, child) {
          final progress = _heartController.value;
          final distance = progress * 100; // Hearts float outward 100px
          final opacity = 1.0 - progress; // Fade out

          final x = math.cos(heart.angle) * distance;
          final y = math.sin(heart.angle) * distance - progress * 30; // Slight upward drift

          return Positioned(
            left: 140 + x, // Center of container (280/2)
            top: 175 + y, // Center of container (350/2)
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: progress * 1.5, // Grow slightly
                child: Icon(
                  Icons.favorite,
                  color: Colors.pink.withOpacity(0.8),
                  size: heart.size,
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }
}

class _CracksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF4500).withOpacity(0.8) // OrangeRed glowing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    final path = Path();
    // Random jagged lines from center-ish
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Crack 1
    path.moveTo(cx, cy - 50);
    path.lineTo(cx + 20, cy - 20);
    path.lineTo(cx - 10, cy + 10);
    path.lineTo(cx + 15, cy + 60);

    // Crack 2
    path.moveTo(cx - 30, cy);
    path.lineTo(cx - 60, cy + 20);

    canvas.drawPath(path, paint);

    // Glow pass
    final glowPaint = Paint()
      ..color = Colors.orangeAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Heart Particle Class for Giggle Effect
class HeartParticle {
  final double angle;
  final double speed;
  final double size;

  HeartParticle({
    required this.angle,
    required this.speed,
    required this.size,
  });
}
