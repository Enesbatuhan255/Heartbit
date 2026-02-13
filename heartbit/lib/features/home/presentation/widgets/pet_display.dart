import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/pet/domain/entities/pet.dart';
import 'package:heartbit/features/pet/domain/entities/pet_evolution.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/features/pet/presentation/providers/pet_provider.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'dart:math' as math;

class PetDisplay extends ConsumerStatefulWidget {
  final Pet pet;

  const PetDisplay({
    super.key,
    required this.pet,
  });

  @override
  ConsumerState<PetDisplay> createState() => _PetDisplayState();
}

class _PetDisplayState extends ConsumerState<PetDisplay> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _jumpAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _heartController;
  final List<HeartParticle> _hearts = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Jump up
    _jumpAnimation = Tween<double>(begin: 0, end: -40).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad,
        reverseCurve: Curves.easeInQuad,
      ),
    );

    // Squeeze effect (optional)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.mediumImpact();
    if (!_controller.isAnimating) {
      _controller.forward().then((_) => _controller.reverse());
    }
    // Send interaction to backend
    ref.read(petControllerProvider.notifier).sendInteraction('poke');
    // Show local effect immediately
    _spawnHearts();
  }

  void _spawnHearts() {
    final random = math.Random();
    for (int i = 0; i < 6; i++) {
        _hearts.add(HeartParticle(
            angle: (math.pi * 1.5) + (random.nextDouble() * 1.0 - 0.5), // Upwards cone
            speed: 0.5 + random.nextDouble() * 0.5,
            size: 20.0 + random.nextDouble() * 10.0,
        ));
    }
    if (!_heartController.isAnimating) {
        _heartController.forward(from: 0.0);
    } else {
        _heartController.value = 0.0;
        _heartController.forward();
    }
  }

  List<Widget> _buildHeartParticles() {
      return _hearts.map((heart) {
         return AnimatedBuilder(
            animation: _heartController,
            builder: (context, child) {
               final double t = _heartController.value;
               final double yOffset = t * 150.0; // Fly up 150px
               final double opacity = (1.0 - t).clamp(0.0, 1.0);
               final double xOffset = math.cos(heart.angle) * t * 50; // Spread logic

               return Positioned(
                   bottom: 150 + yOffset,
                   left: 0,
                   right: 0 + xOffset,
                   child: Center(
                       child: Transform.translate(
                           offset: Offset(xOffset, 0),
                           child: Opacity(
                               opacity: opacity,
                               child: Icon(Icons.favorite, color: AppColors.primary, size: heart.size),
                           ),
                       ),
                   ),
               );
            },
         );
      }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authUserIdProvider);

    // Listen for incoming interactions
    ref.listen(petStateProvider, (previous, next) {
       final pet = next.valueOrNull;
       final prevPet = previous?.valueOrNull;

       if (pet != null && pet.lastInteraction != null && userId != null) {
          // Check if this is a NEW interaction
          final isNew = prevPet?.lastInteraction?.timestamp != pet.lastInteraction!.timestamp;
          // Check if it's from partner (not me)
          final isFromPartner = pet.lastInteraction!.userId != userId;
          // Check if it's recent (within last 5 seconds) to avoid playing on load
          final isRecent = DateTime.now().difference(pet.lastInteraction!.timestamp).inSeconds < 5;

          if (isNew && isFromPartner && isRecent) {
             _playInteractionEffect(pet.lastInteraction!.type);
          }
       }
    });

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        height: 350,
        width: double.infinity,
        color: Colors.transparent, // Ensure hit test works
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Floating Hearts Layer
            ..._buildHeartParticles(),

            // Shadow under Pet
            Positioned(
              bottom: 100, // Adjusted for floor height
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Shadow shrinks when pet jumps
                  final scale = 1.0 - (_controller.value * 0.4);
                  final opacity = 1.0 - (_controller.value * 0.5);
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        height: 20,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: const BorderRadius.all(Radius.elliptical(120, 20)),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Pet Character
            Positioned(
              bottom: 110,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _jumpAnimation.value),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                     // Lottie Aura
                    Opacity(
                      opacity: 0.6,
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Lottie.network(
                          'https://lottie.host/80e36502-3c48-4e89-9828-56d1163462f4/6F9g3f9g.json',
                          errorBuilder: (context, error, stackTrace) => const SizedBox(),
                        ),
                      ),
                    ),
                    // Pet Emoji
                    Text(widget.pet.stage.emoji, style: const TextStyle(fontSize: 100)),
                  ],
                ),
              ),
            ),
            
            // Pet Name & Level removed to allow external positioning
          ],
        ),
      ),
    );
  }

  void _playInteractionEffect(String type) {
    // 1. Jump
    if (!_controller.isAnimating) {
      _controller.forward().then((_) => _controller.reverse());
    }
    
    // 2. Hearts
    _spawnHearts();

    // 3. Optional: Show Toast/Snackbar?
    // ScaffoldMessenger.of(context).showSnackBar(...); // Maybe too intrusive
  }
}

class HeartParticle {
  final double angle;
  final double speed;
  final double size;

  HeartParticle({required this.angle, required this.speed, required this.size});
}
