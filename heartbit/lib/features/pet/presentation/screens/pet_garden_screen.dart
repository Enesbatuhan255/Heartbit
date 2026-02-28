import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/home/presentation/widgets/pet_display.dart';
import 'package:heartbit/features/pet/domain/entities/pet.dart';
import 'package:heartbit/features/pet/domain/entities/pet_garden_types.dart';
import 'package:heartbit/features/pet/presentation/providers/pet_garden_provider.dart';
import 'package:heartbit/features/pet/presentation/providers/pet_provider.dart';

class PetGardenScreen extends ConsumerStatefulWidget {
  const PetGardenScreen({super.key});

  @override
  ConsumerState<PetGardenScreen> createState() => _PetGardenScreenState();
}

class _PetGardenScreenState extends ConsumerState<PetGardenScreen> {
  final List<_SceneFeedbackCue> _feedbackCues = [];
  int _feedbackSeed = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petControllerProvider.notifier).createPetIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(petGardenSelectedTabProvider);
    final items = ref.watch(petGardenFilteredItemsProvider);
    final inventoryAsync = ref.watch(petGardenInventoryProvider);
    final petAsync = ref.watch(petStateProvider);
    final activeDecorId = ref.watch(petGardenActiveDecorProvider);
    final animationState = ref.watch(petAnimationStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8EFE3),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 11,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: _ScenePanel(
                  petAsync: petAsync,
                  activeDecorId: activeDecorId,
                  animationState: animationState,
                  feedbackCues: _feedbackCues,
                  onFeedbackDone: _removeFeedbackCue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: _TabBar(
                selected: tab,
                onChanged: (value) => ref
                    .read(petGardenSelectedTabProvider.notifier)
                    .state = value,
              ),
            ),
            Expanded(
              flex: 9,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: inventoryAsync.when(
                  data: (inventory) => GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.96,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final quantity = inventory[item.id] ?? 0;
                      return _ItemCard(
                        item: item,
                        quantity: quantity,
                        onTap: () => _onUseItem(item, quantity),
                      );
                    },
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Envanter yuklenemedi: $e',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onUseItem(PetGardenItem item, int quantity) async {
    if (quantity <= 0) {
      _showSnack('${item.title} kalmadi.');
      return;
    }

    final ok = await ref.read(petGardenControllerProvider).useItem(item);
    if (!mounted) return;

    if (!ok) {
      _showSnack('Islem su anda yapilamiyor. Tekrar dene.');
      return;
    }

    _spawnSceneFeedback(item);
    _showSnack(
      item.category == PetGardenTab.feed
          ? '${item.title} verildi. Pet mutlu!'
          : '${item.title} aktif edildi.',
    );
  }

  void _spawnSceneFeedback(PetGardenItem item) {
    setState(() {
      if (item.category == PetGardenTab.feed) {
        if (item.hungerGain > 0) {
          _feedbackCues.add(
            _SceneFeedbackCue(
              id: _feedbackSeed++,
              text: '+${item.hungerGain} Tokluk',
              icon: Icons.restaurant_rounded,
              color: const Color(0xFF8B5A2B),
              xOffset: -30,
              yBase: 208,
            ),
          );
        }
        if (item.happinessGain > 0) {
          _feedbackCues.add(
            _SceneFeedbackCue(
              id: _feedbackSeed++,
              text: '+${item.happinessGain} Mutluluk',
              icon: Icons.favorite_rounded,
              color: const Color(0xFFB54872),
              xOffset: 28,
              yBase: 188,
            ),
          );
        }
      } else {
        _feedbackCues.add(
          _SceneFeedbackCue(
            id: _feedbackSeed++,
            text: '${item.title} aktif',
            icon: Icons.auto_awesome_rounded,
            color: const Color(0xFF3F7AB8),
            xOffset: 0,
            yBase: 198,
          ),
        );
      }

      final overflow = _feedbackCues.length - 8;
      if (overflow > 0) {
        _feedbackCues.removeRange(0, overflow);
      }
    });
  }

  void _removeFeedbackCue(int cueId) {
    if (!mounted) return;
    setState(() {
      _feedbackCues.removeWhere((cue) => cue.id == cueId);
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ScenePanel extends ConsumerStatefulWidget {
  const _ScenePanel({
    required this.petAsync,
    required this.activeDecorId,
    required this.animationState,
    required this.feedbackCues,
    required this.onFeedbackDone,
  });

  final AsyncValue<Pet?> petAsync;
  final String? activeDecorId;
  final PetAnimationState animationState;
  final List<_SceneFeedbackCue> feedbackCues;
  final ValueChanged<int> onFeedbackDone;

  @override
  ConsumerState<_ScenePanel> createState() => _ScenePanelState();
}

class _ScenePanelState extends ConsumerState<_ScenePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientController;
  late final List<_AmbientParticle> _particles;

  bool get _isNight {
    final hour = DateTime.now().hour;
    return hour >= 19 || hour < 6;
  }

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _particles = _buildParticles();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.petAsync.valueOrNull;

    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, child) {
        final phase = _ambientController.value;
        final drift = math.sin(phase * math.pi * 2);
        final bob = math.sin((phase + 0.18) * math.pi * 2);

        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: const Color(0xFFF5EAD8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE1CFB6)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: _RoomBackground(
                  drift: drift,
                  phase: phase,
                  isNight: _isNight,
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: _AmbientParticleLayer(
                    particles: _particles,
                    phase: phase,
                    isNight: _isNight,
                  ),
                ),
              ),
              if (widget.activeDecorId != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: _ActiveDecorLayer(
                      decorId: widget.activeDecorId!,
                      phase: phase,
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                left: 12,
                child: _CircleIconButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => context.pop(),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: const [
                    _MiniBadge(icon: 'G'),
                    SizedBox(width: 8),
                    _MiniBadge(icon: 'S'),
                  ],
                ),
              ),
              Positioned(
                top: 64,
                left: 14,
                child: _StatCard(pet: pet),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 18,
                child: Column(
                  children: [
                    SizedBox(
                      height: 205,
                      child: Transform.translate(
                        offset: Offset(drift * 2.5, bob * 3.5),
                        child: widget.petAsync.when(
                          data: (value) {
                            if (value == null) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'PET',
                                    style: TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text('Pet hazirlaniyor...'),
                                ],
                              );
                            }
                            return PetDisplay(pet: value);
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                          error: (_, __) => const Center(
                              child: Text('Pet verisi okunamadi.')),
                        ),
                      ),
                    ),
                    _AnimationPill(state: widget.animationState),
                    if (widget.activeDecorId != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEFE0),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFFFB06B)),
                        ),
                        child: Text(
                          'Aktif dekor: ${_decorLabel(widget.activeDecorId!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8D5315),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ...widget.feedbackCues.map(
                (cue) => Positioned(
                  left: 0,
                  right: 0,
                  bottom: cue.yBase,
                  child: _FloatingCueChip(
                    key: ValueKey(cue.id),
                    cue: cue,
                    onDone: () => widget.onFeedbackDone(cue.id),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_AmbientParticle> _buildParticles() {
    final random = math.Random(23);
    return List.generate(14, (index) {
      return _AmbientParticle(
        xFactor: 0.08 + random.nextDouble() * 0.84,
        yFactor: 0.12 + random.nextDouble() * 0.74,
        size: 3.5 + random.nextDouble() * 3.2,
        opacity: 0.16 + random.nextDouble() * 0.36,
        amplitude: 3 + random.nextDouble() * 10,
        phaseOffset: random.nextDouble() * math.pi * 2,
      );
    });
  }

  String _decorLabel(String id) {
    for (final item in PetGardenCatalog.decorItems) {
      if (item.id == id) return item.title;
    }
    return 'Dekor';
  }
}

class _SceneFeedbackCue {
  const _SceneFeedbackCue({
    required this.id,
    required this.text,
    required this.icon,
    required this.color,
    required this.xOffset,
    required this.yBase,
  });

  final int id;
  final String text;
  final IconData icon;
  final Color color;
  final double xOffset;
  final double yBase;
}

class _AmbientParticle {
  const _AmbientParticle({
    required this.xFactor,
    required this.yFactor,
    required this.size,
    required this.opacity,
    required this.amplitude,
    required this.phaseOffset,
  });

  final double xFactor;
  final double yFactor;
  final double size;
  final double opacity;
  final double amplitude;
  final double phaseOffset;
}

class _RoomBackground extends StatelessWidget {
  const _RoomBackground({
    required this.drift,
    required this.phase,
    required this.isNight,
  });

  final double drift;
  final double phase;
  final bool isNight;

  @override
  Widget build(BuildContext context) {
    final pulse = (math.sin((phase + 0.12) * math.pi * 2) + 1) / 2;
    final overlay = isNight
        ? Color.lerp(
            Colors.transparent,
            const Color(0x2C132946),
            0.3 + pulse * 0.15,
          )!
        : Color.lerp(
            Colors.transparent,
            const Color(0x22FFE8C2),
            0.2 + pulse * 0.15,
          )!;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isNight
                    ? const [
                        Color(0xFFF1E6D8),
                        Color(0xFFECDDCA),
                        Color(0xFFF4D9BF),
                      ]
                    : const [
                        Color(0xFFF8F0E3),
                        Color(0xFFF4E9D7),
                        Color(0xFFF7DFC2),
                      ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 24 + drift * 7,
          right: 92 + drift * 6,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isNight
                    ? const [Color(0x26D6E6FF), Colors.transparent]
                    : const [Color(0x4DFFF5D4), Colors.transparent],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: Offset(drift * 8, 0),
            child: Container(
              height: 165,
              margin: const EdgeInsets.symmetric(horizontal: 72),
              decoration: BoxDecoration(
                color:
                    isNight ? const Color(0xFFD5DFF0) : const Color(0xFFDCEBFF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isNight
                      ? const Color(0xFFBCC7DE)
                      : const Color(0xFFC8DCF5),
                  width: 4,
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 110,
                  width: 4,
                  color: isNight
                      ? const Color(0x66FFFFFF)
                      : const Color(0x55B7C8E5),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0 + drift * 4,
          child: Container(
            width: 76,
            height: 234,
            decoration: const BoxDecoration(
              color: Color(0xFFCAE5A3),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(72),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0 - drift * 4,
          child: Container(
            width: 76,
            height: 234,
            decoration: const BoxDecoration(
              color: Color(0xFFCAE5A3),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(72),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 142,
            decoration: const BoxDecoration(
              color: Color(0xFFF7DFC2),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: -12,
                  child: _FloorLine(width: 112, angle: 0.06),
                ),
                Positioned(
                  top: 26,
                  left: 84,
                  child: _FloorLine(width: 134, angle: -0.08),
                ),
                Positioned(
                  top: 34,
                  right: 58,
                  child: _FloorLine(width: 126, angle: 0.05),
                ),
                Positioned(
                  top: 74,
                  left: 26,
                  child: _FloorLine(width: 102, angle: -0.06),
                ),
                Positioned(
                  top: 84,
                  right: 26,
                  child: _FloorLine(width: 118, angle: 0.05),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(child: ColoredBox(color: overlay)),
      ],
    );
  }
}

class _FloorLine extends StatelessWidget {
  const _FloorLine({required this.width, required this.angle});

  final double width;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: 3,
        decoration: BoxDecoration(
          color: const Color(0x2EBB9774),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _ActiveDecorLayer extends StatelessWidget {
  const _ActiveDecorLayer({
    required this.decorId,
    required this.phase,
  });

  final String decorId;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final pulse = (math.sin(phase * math.pi * 2) + 1) / 2;
    final toyX = math.sin((phase + 0.34) * math.pi * 2) * 9;
    final toyY = math.cos((phase + 0.34) * math.pi * 2) * 5;

    return Stack(
      children: [
        if (decorId == 'decor_rug')
          Align(
            alignment: const Alignment(0, 0.82),
            child: Transform.scale(
              scale: 1 + pulse * 0.04,
              child: Container(
                width: 176,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8CB),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFC7A47B), width: 2),
                ),
              ),
            ),
          ),
        if (decorId == 'decor_pillow')
          Positioned(
            left: 60,
            bottom: 52,
            child: _DecorChip(
              icon: Icons.bed_rounded,
              color: const Color(0xFFE5ECFF),
            ),
          ),
        if (decorId == 'decor_plant')
          Positioned(
            left: 34,
            bottom: 56,
            child: _DecorChip(
              icon: Icons.local_florist_rounded,
              color: const Color(0xFFDDF4E5),
            ),
          ),
        if (decorId == 'decor_lamp')
          Positioned(
            right: 56,
            top: 92,
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0x55FFE8B2).withOpacity(0.6 + pulse * 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                _DecorChip(
                  icon: Icons.light_rounded,
                  color: const Color(0xFFFFF0DB),
                ),
              ],
            ),
          ),
        if (decorId == 'decor_speaker')
          Positioned(
            right: 50,
            bottom: 66,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (final radius in [22.0, 30.0])
                  Container(
                    width: radius * 2,
                    height: radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0x663F7AB8)
                            .withOpacity(0.15 + pulse * 0.25),
                      ),
                    ),
                  ),
                _DecorChip(
                  icon: Icons.speaker_rounded,
                  color: const Color(0xFFE8EEFF),
                ),
              ],
            ),
          ),
        if (decorId == 'decor_toy')
          Positioned(
            right: 84 + toyX,
            bottom: 62 + toyY,
            child: _DecorChip(
              icon: Icons.toys_rounded,
              color: const Color(0xFFFFF1D6),
            ),
          ),
      ],
    );
  }
}

class _DecorChip extends StatelessWidget {
  const _DecorChip({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFCFB697)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 22, color: const Color(0xFF785132)),
    );
  }
}

class _AmbientParticleLayer extends StatelessWidget {
  const _AmbientParticleLayer({
    required this.particles,
    required this.phase,
    required this.isNight,
  });

  final List<_AmbientParticle> particles;
  final double phase;
  final bool isNight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return Stack(
          children: particles.map((particle) {
            final wave = phase * math.pi * 2 + particle.phaseOffset;
            final dx = math.cos(wave) * particle.amplitude * 0.6;
            final dy = math.sin(wave) * particle.amplitude;
            return Positioned(
              left: width * particle.xFactor + dx,
              top: height * particle.yFactor + dy,
              child: Opacity(
                opacity: particle.opacity,
                child: Container(
                  width: particle.size,
                  height: particle.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isNight
                        ? const Color(0xFFE9F3FF)
                        : const Color(0xFFFFF8EA),
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

class _FloatingCueChip extends StatelessWidget {
  const _FloatingCueChip({
    super.key,
    required this.cue,
    required this.onDone,
  });

  final _SceneFeedbackCue cue;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1050),
        curve: Curves.easeOutCubic,
        onEnd: onDone,
        builder: (context, value, child) {
          final opacity = (1 - value).clamp(0.0, 1.0);
          return Transform.translate(
            offset: Offset(cue.xOffset, -52 * value),
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: 0.96 + value * 0.08,
                child: child,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cue.color.withOpacity(0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(cue.icon, size: 14, color: cue.color),
              const SizedBox(width: 6),
              Text(
                cue.text,
                style: TextStyle(
                  color: cue.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.pet});

  final Pet? pet;

  @override
  Widget build(BuildContext context) {
    final level = pet?.level ?? 1;
    final progress = ((pet?.levelProgress ?? 0.0) * 100).round();
    final hunger = pet?.hunger ?? 100;
    final happiness = pet?.happiness ?? 100;
    final energy = ((hunger + happiness) / 40).clamp(1, 5).round();

    return Container(
      width: 136,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3DCD3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: Color(0xFFCDEFA9),
                child: Icon(Icons.person, size: 13, color: Color(0xFF4D7A2B)),
              ),
              SizedBox(width: 6),
              CircleAvatar(
                radius: 10,
                backgroundColor: Color(0xFFFFE3BF),
                child: Icon(Icons.pets, size: 13, color: Color(0xFF9A6218)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'LV.$level',
            style: const TextStyle(
              color: Color(0xFF4E8E32),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bugun Exp',
            style: TextStyle(fontSize: 12, color: Color(0xFF4F4F4F)),
          ),
          Text(
            '$progress/100',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE37A16),
            ),
          ),
          const Divider(height: 16),
          Row(
            children: List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.bolt_rounded,
                  size: 15,
                  color: index < energy
                      ? const Color(0xFFC46D14)
                      : const Color(0xFFD9C7AD),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.selected, required this.onChanged});

  final PetGardenTab selected;
  final ValueChanged<PetGardenTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabButton(
            label: 'Feed',
            icon: Icons.restaurant_rounded,
            selected: selected == PetGardenTab.feed,
            onTap: () => onChanged(PetGardenTab.feed),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabButton(
            label: 'Decor',
            icon: Icons.chair_alt_rounded,
            selected: selected == PetGardenTab.decor,
            onTap: () => onChanged(PetGardenTab.decor),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFF8D5A2B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF8D5A2B), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? const Color(0xFF8D5A2B) : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? const Color(0xFF8D5A2B) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.quantity,
    required this.onTap,
  });

  final PetGardenItem item;
  final int quantity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = quantity <= 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: disabled ? 0.56 : 1,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE0D6C7)),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 42, color: const Color(0xFF6D4C2D)),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3B362F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description ?? '',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7C6E5D),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8D5A2B),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'x$quantity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFE6DACA)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF4C4C4C)),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE6DACA)),
      ),
      child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
    );
  }
}

class _AnimationPill extends StatelessWidget {
  const _AnimationPill({required this.state});

  final PetAnimationState state;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      PetAnimationState.hungry => ('Acikmis', const Color(0xFFD96127)),
      PetAnimationState.happy => ('Mutlu', const Color(0xFF3E9E56)),
      PetAnimationState.feeding => ('Yiyor', const Color(0xFFB1742A)),
      PetAnimationState.loving => ('Seviliyor', const Color(0xFFB54872)),
      PetAnimationState.idle => ('Rahat', const Color(0xFF6A6A6A)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
