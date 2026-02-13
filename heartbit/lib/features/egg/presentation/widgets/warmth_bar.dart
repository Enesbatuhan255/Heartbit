
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';

class WarmthBar extends ConsumerStatefulWidget {
  const WarmthBar({super.key});

  @override
  ConsumerState<WarmthBar> createState() => _WarmthBarState();
}

class _WarmthBarState extends ConsumerState<WarmthBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Slower, breathing heat
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coupleAsync = ref.watch(coupleStateProvider);

    return coupleAsync.when(
      data: (couple) {
        if (couple == null) return const SizedBox();
        final warmth = couple.eggWarmth;
        final progress = (warmth / 1000).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              // Header Row with Flame Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: AppColors.orange, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Isı Seviyesi',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Thicker Animated Bar
              Container(
                height: 24, // Thicker
                decoration: BoxDecoration(
                  color: AppColors.background, // Match app bg to look like a cutout or just dark track
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    // Inner shadow effect or subtle outer shadow
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1)),
                  ],
                  border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
                ),
                child: Stack(
                  children: [
                    // Background Track
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    
                    // Active Progress with Shimmer
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    // Shimmer effect via colors or alignment
                                    // Animated alignment to creating "flow" effect
                                    stops: [
                                      0.0,
                                      _controller.value, 
                                      1.0
                                    ],
                                    colors: const [
                                      Color(0xFFFF4500), // OrangeRed
                                      Color(0xFFFF8C00), // DarkOrange
                                      Color(0xFFFFD700), // Gold
                                    ],
                                    transform: GradientRotation(_controller.value * 6.28), // Rotate gradient slightly or just move stops works better?
                                    // Let's try a simpler LinearGradient with alignment animation for "shimmer/flow"
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.orange.withOpacity(0.5),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  // Overlay for extra shimmer shine
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                          begin: Alignment(-1.0 + (_controller.value * 3), -0.5),
                                          end: Alignment(0.0 + (_controller.value * 3), 0.5),
                                          colors: [
                                            Colors.white.withOpacity(0.0),
                                            Colors.white.withOpacity(0.3),
                                            Colors.white.withOpacity(0.0),
                                          ],
                                          stops: const [0.4, 0.5, 0.6]
                                      )
                                  ), 
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 40),
      error: (_, __) => const SizedBox(),
    );
  }
}
