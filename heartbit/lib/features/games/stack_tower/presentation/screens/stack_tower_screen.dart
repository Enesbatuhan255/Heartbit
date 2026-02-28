import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/games/stack_tower/domain/entities/stacked_block.dart';
import 'package:heartbit/features/games/stack_tower/presentation/providers/stack_tower_provider.dart';

// ─── Premium palette ──────────────────────────────────────────────────────
class _P {
  static const bg      = Color(0xFFFDF6F0);
  static const surface = Color(0xFFFFFFFF);
  static const border  = Color(0x18000000);  // %9 black
  static const gold    = Color(0xFFC8A96E);
  static const gold2   = Color(0xFFE8C87E);
  static const text    = Color(0xFF2D2B3D);  // deep purple-gray
  static const muted   = Color(0x592D2B3D);  // %35 text
  static const dim     = Color(0x262D2B3D);  // %15 text
  static const error   = Color(0xFFEF4444);
}

class StackTowerScreen extends ConsumerStatefulWidget {
  const StackTowerScreen({super.key});

  @override
  ConsumerState<StackTowerScreen> createState() => _StackTowerScreenState();
}

class _StackTowerScreenState extends ConsumerState<StackTowerScreen>
    with TickerProviderStateMixin {
  late AnimationController _moveController;
  double _currentLeftRatio = 0.3;
  bool _movingRight = true;
  bool _isLeaving = false;
  bool _isRestarting = false;
  bool _canPopNow = false;
  bool _hasSeenActiveSession = false;
  int _nullSessionDebounceToken = 0;
  double _gameAreaHeight = 0;
  FallingBlock? _fallingBlock;
  bool _isDropping = false;

  final List<List<Color>> _bgGradients = [
    [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)],
    [const Color(0xFF89F7FE), const Color(0xFF66A6FF)],
    [const Color(0xFFFA709A), const Color(0xFFFEE140)],
    [const Color(0xFF243949), const Color(0xFF517FA4)],
    [const Color(0xFFE8F4F8), const Color(0xFFF0F7FA), const Color(0xFFF5FBFF)],
  ];

  final List<Color> _blockColors = [
    const Color(0xFFFF6B6B),
    const Color(0xFFFF8E53),
    const Color(0xFFFFD93D),
    const Color(0xFF6BCB77),
    const Color(0xFF4D96FF),
    const Color(0xFF9B59B6),
    const Color(0xFFE91E63),
    const Color(0xFF00BCD4),
  ];

  final List<Debris> _debrisList = [];
  late Ticker _ticker;
  late AnimationController _bgController;
  final List<Cloud> _clouds = [];
  final List<Bird> _birds = [];
  final List<Butterfly> _butterflies = [];
  final Random _random = Random();
  final List<HeartParticle> _particles = [];
  late AnimationController _turnChangeController;
  late AnimationController _flashController;
  bool _showTurnChangeHeart = false;

  @override
  void initState() {
    super.initState();
    _initController();
    _initAtmosphere();
    _initVisualFeedback();
    WidgetsBinding.instance.addPostFrameCallback((_) => _enterGame());
  }

  void _initVisualFeedback() {
    _turnChangeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _flashController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  void _initAtmosphere() {
    for (int i = 0; i < 5; i++) {
      List<List<double>> puffs = [];
      int puffCount = 5 + _random.nextInt(4);
      for (int j = 0; j < puffCount; j++) {
        puffs.add([
          (_random.nextDouble() - 0.5) * 0.8,
          (_random.nextDouble() - 0.5) * 0.4,
          0.25 + _random.nextDouble() * 0.25,
          0.3 + _random.nextDouble() * 0.3,
        ]);
      }
      _clouds.add(Cloud(
        x: _random.nextDouble(), y: 0.1 + _random.nextDouble() * 0.4,
        width: 0.15 + _random.nextDouble() * 0.15,
        speed: 0.0002 + _random.nextDouble() * 0.0003, puffs: puffs,
      ));
    }
    for (int i = 0; i < 3; i++) {
      _birds.add(Bird(
        x: _random.nextDouble(), y: 0.1 + _random.nextDouble() * 0.3,
        speed: 0.001 + _random.nextDouble() * 0.001,
        wingOffset: _random.nextDouble() * pi,
      ));
    }
    for (int i = 0; i < 5; i++) {
      _butterflies.add(Butterfly(
        x: _random.nextDouble(), y: 0.5 + _random.nextDouble() * 0.4,
        speedX: (0.5 - _random.nextDouble()) * 0.001,
        speedY: (0.5 - _random.nextDouble()) * 0.001,
        color: Color.fromARGB(255, _random.nextInt(255), _random.nextInt(255), _random.nextInt(255)),
      ));
    }
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  void _initController() {
    _moveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))
      ..addListener(_updateBlockPosition);
    _ticker = createTicker((elapsed) {
      if (_isDropping && _fallingBlock != null) _updateFallingBlock();
      if (_particles.isNotEmpty) {
        setState(() { _particles.removeWhere((p) { p.update(); return p.opacity <= 0; }); });
      }
      if (_debrisList.isNotEmpty) {
        setState(() {
          _debrisList.removeWhere((debris) {
            debris.top += debris.velocityY;
            debris.velocityY += 0.5;
            debris.rotation += debris.rotationSpeed;
            return debris.top > MediaQuery.of(context).size.height;
          });
        });
      }
    });
    _ticker.start();
  }

  void _updateFallingBlock() {
    final session = ref.read(activeStackTowerSessionProvider).valueOrNull;
    if (session == null) return;
    setState(() {
      _fallingBlock!.velocityY += 1.5;
      _fallingBlock!.top += _fallingBlock!.velocityY;
      final screenHeight = _gameAreaHeight > 0 ? _gameAreaHeight : MediaQuery.of(context).size.height;
      final globalBaseY = screenHeight - 150.0;
      const blockHeight = 30.0;
      final stackHeight = session.blocks.length * blockHeight;
      final targetY = globalBaseY - stackHeight;
      if (_fallingBlock!.top >= targetY) {
        _fallingBlock!.top = targetY;
        _handleBlockLanding(targetY);
        _isDropping = false;
        _fallingBlock = null;
      }
    });
  }

  void _updateBlockPosition() {
    final session = ref.read(activeStackTowerSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    if (session == null || session.status != 'playing' || session.currentTurnUserId != userId) return;
    final topBlock = session.blocks.last;
    final currentWidth = topBlock.widthRatio;
    final speed = 0.008 * session.speed;
    setState(() {
      if (_movingRight) {
        _currentLeftRatio += speed;
        if (_currentLeftRatio + currentWidth >= 0.95) _movingRight = false;
      } else {
        _currentLeftRatio -= speed;
        if (_currentLeftRatio <= 0.05) _movingRight = true;
      }
    });
  }

  void _onTap() {
    final session = ref.read(activeStackTowerSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    if (session == null || session.currentTurnUserId != userId || _isDropping) return;
    HapticFeedback.lightImpact();
    final topBlock = session.blocks.last;
    setState(() {
      _isDropping = true;
      _fallingBlock = FallingBlock(
        leftRatio: _currentLeftRatio, top: 100,
        widthRatio: topBlock.widthRatio,
        color: _blockColors[session.blocks.length % _blockColors.length],
        velocityY: 0,
      );
    });
  }

  void _handleBlockLanding(double landingY) async {
    final session = ref.read(activeStackTowerSessionProvider).valueOrNull;
    if (session == null) return;
    HapticFeedback.mediumImpact();
    final topBlock = session.blocks.last;
    final leftRatio = _fallingBlock?.leftRatio ?? _currentLeftRatio;
    final widthRatio = topBlock.widthRatio;
    final newRight = leftRatio + widthRatio;
    final topRight = topBlock.leftRatio + topBlock.widthRatio;
    final overlapLeft = leftRatio > topBlock.leftRatio ? leftRatio : topBlock.leftRatio;
    final overlapRight = newRight < topRight ? newRight : topRight;
    final overlapWidth = overlapRight - overlapLeft;
    final landY = landingY;
    if (overlapWidth > 0 && overlapWidth < widthRatio) {
      double debrisLeft, debrisWidth;
      if (leftRatio < topBlock.leftRatio) { debrisLeft = leftRatio; debrisWidth = topBlock.leftRatio - leftRatio; }
      else { debrisLeft = topRight; debrisWidth = newRight - topRight; }
      if (debrisWidth > 0.01) {
        _debrisList.add(Debris(
          leftRatio: debrisLeft, top: landY, widthRatio: debrisWidth, height: 30,
          color: _blockColors[session.blocks.length % _blockColors.length],
          velocityY: -2.0, rotationSpeed: (0.1 - (0.2 * (leftRatio > topBlock.leftRatio ? 0 : 1))),
        ));
      }
    } else if (overlapWidth <= 0.01) {
      _debrisList.add(Debris(
        leftRatio: leftRatio, top: landY, widthRatio: widthRatio, height: 30,
        color: _blockColors[session.blocks.length % _blockColors.length],
        velocityY: 0, rotationSpeed: 0.1,
      ));
    }
    setState(() { _currentLeftRatio = overlapLeft; });
    final diff = (overlapWidth - topBlock.widthRatio).abs();
    if (diff < 0.02) {
      _flashController.forward(from: 0);
      final centerLeft = overlapLeft + overlapWidth / 2;
      for (int i = 0; i < 15; i++) {
        _particles.add(HeartParticle(
          x: centerLeft * MediaQuery.of(context).size.width,
          y: _fallingBlock!.top, color: _fallingBlock!.color,
        ));
      }
    }
    final success = await ref.read(stackTowerControllerProvider.notifier).placeBlock(
      leftRatio: _fallingBlock!.leftRatio, widthRatio: _fallingBlock!.widthRatio,
    );
    if (!success) HapticFeedback.heavyImpact();
  }

  void _enterGame() => ref.read(stackTowerControllerProvider.notifier).enterGame();

  Future<void> _handleExitAttempt() async {
    final session = ref.read(activeStackTowerSessionProvider).valueOrNull;
    if (session == null || session.status == 'gameover') { _forceLeave(); return; }
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _P.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Oyundan Ayrıl?',
          style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.w600, color: _P.text)),
        content: const Text('Çıkarsan oyun ikiniz için de biter.',
          style: TextStyle(color: _P.muted, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç', style: TextStyle(color: _P.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ayrıl', style: TextStyle(color: _P.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (shouldLeave == true) _forceLeave();
  }

  void _forceLeave() {
    _isLeaving = true;
    ref.read(stackTowerControllerProvider.notifier).leaveGame();
    if (mounted) { setState(() => _canPopNow = true); Navigator.of(context).pop(); }
  }

  void _leaveGame() => _handleExitAttempt();

  @override
  void dispose() {
    _moveController.dispose();
    _bgController.dispose();
    _turnChangeController.dispose();
    _flashController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  List<Color> _getBackgroundColors(double score) {
    double t = 0.0;
    int phase = 0;
    if (score < 10) { phase = 0; t = score / 10.0; }
    else if (score < 20) { phase = 1; t = (score - 10) / 10.0; }
    else if (score < 30) { phase = 2; t = (score - 20) / 10.0; }
    else if (score < 50) { phase = 3; t = (score - 30) / 20.0; }
    else { phase = 4; t = 1.0; }
    final startGradient = _bgGradients[phase];
    final endGradient = _bgGradients[(phase + 1).clamp(0, _bgGradients.length - 1)];
    final c1 = Color.lerp(startGradient.first, endGradient.first, t)!;
    final c2 = Color.lerp(startGradient.last, endGradient.last, t)!;
    return [c1, c2];
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(activeStackTowerSessionProvider);
    final userId = ref.watch(authUserIdProvider);

    ref.listen(activeStackTowerSessionProvider, (prev, next) {
      final session = next.valueOrNull;
      if (session != null) {
        _hasSeenActiveSession = true;
        _nullSessionDebounceToken++;
        if (session.status == 'waiting' && session.bothReady) {
          ref.read(stackTowerControllerProvider.notifier).startGame();
          _currentLeftRatio = 0.3; _movingRight = true;
        }
        if (session.status == 'playing') { if (!_moveController.isAnimating) _moveController.repeat(); }
        else { _moveController.stop(); }
      }
      if (prev?.valueOrNull != null && next.valueOrNull == null && !next.isLoading &&
          !next.hasError && !_isLeaving && !_isRestarting && _hasSeenActiveSession) {
        final token = ++_nullSessionDebounceToken;
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted || token != _nullSessionDebounceToken) return;
          final latest = ref.read(activeStackTowerSessionProvider);
          final stillNull = latest.valueOrNull == null && !latest.isLoading && !latest.hasError && !_isLeaving && !_isRestarting;
          if (!stillNull) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Partner oyundan ayrıldı'), backgroundColor: _P.error));
          Navigator.of(context).pop();
        });
      }
      if (next.hasError) debugPrint('StackTower Error: ${next.error}');
      if (_isRestarting && next.valueOrNull != null) _isRestarting = false;
      if (prev?.valueOrNull != null && next.valueOrNull != null) {
        final prevSession = prev!.valueOrNull!;
        final nextSession = next.valueOrNull!;
        final myId = ref.read(authUserIdProvider);
        if (prevSession.currentTurnUserId == myId && nextSession.currentTurnUserId != myId) {
          _turnChangeController.forward(from: 0);
          setState(() => _showTurnChangeHeart = true);
        }
      }
    });

    return PopScope(
      canPop: _canPopNow,
      onPopInvoked: (didPop) { if (didPop) return; _handleExitAttempt(); },
      child: Scaffold(
        backgroundColor: _P.bg,
        // ── Premium AppBar ──────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: _P.text, size: 18),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            'Stack Tower',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22, fontWeight: FontWeight.w600, color: _P.text, letterSpacing: 0.5),
          ),
          centerTitle: true,
        ),
        body: sessionAsync.when(
          data: (session) {
            if (session == null) return _buildLoading();
            if (session.status == 'waiting') return _buildWaitingRoom(session, userId);
            if (session.status == 'gameover') return _buildGameOverScreen(session);
            return _buildGameScreen(session, userId);
          },
          loading: _buildLoading,
          error: (e, _) => Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, color: _P.error, size: 48),
              const SizedBox(height: 16),
              Text('Hata: $e', style: const TextStyle(color: _P.error)),
              const SizedBox(height: 16),
              _goldButton('Tekrar Dene', _enterGame),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const CircularProgressIndicator(color: _P.gold, strokeWidth: 2),
      const SizedBox(height: 16),
      const Text('Oyun hazırlanıyor...', style: TextStyle(color: _P.muted, fontSize: 14)),
    ]),
  );

  // ── WAITING ROOM ──────────────────────────────────────────────────────────
  Widget _buildWaitingRoom(StackTowerSession session, String? userId) {
    final isUserReady = session.readyUsers.contains(userId);
    final partnerReady = session.readyUsers.length > 1;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Gold spinning ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 3),
            onEnd: () => setState(() {}),
            builder: (context, value, child) => Transform.rotate(
              angle: value * 2 * pi,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _P.gold, width: 2),
                  gradient: RadialGradient(colors: [
                    _P.gold.withOpacity(0.1), Colors.transparent,
                  ]),
                ),
                child: const Center(child: Icon(Icons.hourglass_empty, size: 32, color: _P.gold)),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text('Bekleme Odası',
            style: GoogleFonts.cormorantGaramond(fontSize: 26, fontWeight: FontWeight.w600, color: _P.text)),
          const SizedBox(height: 20),

          // Status card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _P.surface, borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _P.border),
            ),
            child: Column(children: [
              _buildPlayerStatus('Sen', isUserReady, Icons.person_outline),
              const SizedBox(height: 12),
              Container(height: 1, color: _P.border),
              const SizedBox(height: 12),
              _buildPlayerStatus('Partner', partnerReady, Icons.favorite_outline),
            ]),
          ),
          const SizedBox(height: 20),

          Text(
            partnerReady
              ? 'Her ikiniz de hazır! Oyun başlıyor...'
              : isUserReady
                ? 'Partnerin bağlanmasını bekliyorsun...'
                : 'Partnerin seni bekliyor!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: partnerReady ? _P.gold : _P.muted, fontSize: 13),
          ),
          const SizedBox(height: 24),

          if (!isUserReady) ...[
            _goldButton('Oyuna Katıl', _enterGame),
            const SizedBox(height: 10),
          ],
          _outlineButton('Çık', _leaveGame),
        ]),
      ),
    );
  }

  Widget _buildPlayerStatus(String label, bool ready, IconData icon) {
    return Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ready ? _P.gold.withOpacity(0.15) : _P.surface,
          border: Border.all(color: ready ? _P.gold.withOpacity(0.4) : _P.border),
        ),
        child: Icon(icon, color: ready ? _P.gold : _P.muted, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(color: _P.text, fontSize: 15))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: ready ? _P.gold.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ready ? _P.gold.withOpacity(0.3) : _P.border),
        ),
        child: Text(
          ready ? 'Hazır ✓' : 'Bekleniyor',
          style: TextStyle(
            color: ready ? _P.gold : _P.muted, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    ]);
  }

  // ── GAME SCREEN ───────────────────────────────────────────────────────────
  Widget _buildGameScreen(StackTowerSession session, String? userId) {
    final isMyTurn = session.currentTurnUserId == userId;
    final topBlock = session.blocks.last;

    return LayoutBuilder(builder: (context, constraints) {
      _gameAreaHeight = constraints.maxHeight;
      final screenWidth = constraints.maxWidth;

      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: session.blocks.length.toDouble()),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInOutSine,
        builder: (context, animatedScore, child) {
          return GestureDetector(
            onTap: isMyTurn ? _onTap : null,
            behavior: HitTestBehavior.opaque,
            child: Stack(children: [
              // Dynamic BG (unchanged — this is game-specific)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: _getBackgroundColors(animatedScore),
                  ),
                ),
              ),

              Positioned.fill(child: AnimatedBuilder(
                animation: _bgController,
                builder: (context, child) => CustomPaint(
                  painter: _AtmospherePainter(
                    score: animatedScore, animationValue: _bgController.value,
                    clouds: _clouds, birds: _birds, butterflies: _butterflies),
                ),
              )),

              if (animatedScore > 20)
                Positioned.fill(child: CustomPaint(
                  painter: _StarFieldPainter(density: (animatedScore - 20) / 40.0))),

              Positioned(bottom: 100, left: 0, right: 0, top: 150,
                child: CustomPaint(painter: _StackPainter(blocks: session.blocks, colors: _blockColors))),

              if (isMyTurn && !_isDropping)
                Positioned(
                  top: 100, left: _currentLeftRatio * screenWidth,
                  child: Container(
                    width: topBlock.widthRatio * screenWidth, height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [
                          _blockColors[session.blocks.length % _blockColors.length],
                          _blockColors[session.blocks.length % _blockColors.length].withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [BoxShadow(
                        color: _blockColors[session.blocks.length % _blockColors.length].withOpacity(0.5),
                        blurRadius: 12, offset: const Offset(0, 4),
                      )],
                    ),
                  ),
                ),

              if (_fallingBlock != null)
                Positioned(
                  top: _fallingBlock!.top, left: _fallingBlock!.leftRatio * screenWidth,
                  child: Container(
                    width: _fallingBlock!.widthRatio * screenWidth, height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [_fallingBlock!.color, _fallingBlock!.color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                      boxShadow: [BoxShadow(
                        color: _fallingBlock!.color.withOpacity(0.4),
                        blurRadius: 8, offset: const Offset(0, 4),
                      )],
                    ),
                  ),
                ),

              if (_particles.isNotEmpty)
                Positioned.fill(child: CustomPaint(painter: _HeartParticlePainter(_particles))),

              ..._debrisList.map((debris) => Positioned(
                left: debris.leftRatio * screenWidth, top: debris.top,
                child: Transform.rotate(
                  angle: debris.rotation,
                  child: Container(
                    width: debris.widthRatio * screenWidth, height: debris.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [debris.color, debris.color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                    ),
                  ),
                ),
              )).toList(),

              // ── Score — premium style ─────────────────────────────────
              Positioned(
                top: 50, left: 0, right: 0,
                child: Center(child: Column(children: [
                  SelectionContainer.disabled(child: Text(
                    session.score.toString(),
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 52, fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: const [Shadow(offset: Offset(0, 2), blurRadius: 8, color: Color(0x66000000))],
                    ),
                  )),
                  SelectionContainer.disabled(child: Text(
                    'KAT ${session.blocks.length}',
                    style: const TextStyle(
                      fontSize: 10, letterSpacing: 2.5, fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      shadows: [Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x44000000))],
                    ),
                  )),
                ])),
              ),

              // ── Speed badge — premium style ───────────────────────────
              Positioned(
                top: 12, left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.speed, color: Colors.white60, size: 13),
                    const SizedBox(width: 4),
                    Text('${session.speed.toStringAsFixed(1)}x',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),

              // ── Turn indicator — premium style ────────────────────────
              Positioned(
                bottom: 32, left: 0, right: 0,
                child: Center(child: _buildTurnIndicator(isMyTurn)),
              ),

              // Flash effect
              IgnorePointer(child: AnimatedBuilder(
                animation: _flashController,
                builder: (context, child) => Container(
                  color: Colors.white.withOpacity(0.25 * (1 - _flashController.value)),
                ),
              )),
            ]),
          );
        },
      );
    });
  }

  Widget _buildTurnIndicator(bool isMyTurn) {
    if (isMyTurn) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(
          color: _P.gold,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Color(0x66C8A96E), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Text('✦', style: TextStyle(color: Color(0xFF5D4E37), fontSize: 12)),
          SizedBox(width: 8),
          Text('SENİN SIRAN',
            style: TextStyle(
              color: Color(0xFF5D4E37), fontWeight: FontWeight.w800,
              fontSize: 13, letterSpacing: 1.5)),
        ]),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 12, height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54),
          ),
          SizedBox(width: 10),
          Text('PARTNERİN OYNUYOR',
            style: TextStyle(
              color: Colors.white70, fontWeight: FontWeight.w600,
              fontSize: 12, letterSpacing: 1.2)),
        ]),
      );
    }
  }

  // ── GAME OVER ─────────────────────────────────────────────────────────────
  Widget _buildGameOverScreen(StackTowerSession session) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(28),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _P.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _P.gold.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: _P.gold.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 10))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Gold trophy
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _P.gold.withOpacity(0.08),
                border: Border.all(color: _P.gold.withOpacity(0.3)),
              ),
              child: const Center(child: Text('🏆', style: TextStyle(fontSize: 32))),
            ),
            const SizedBox(height: 20),
            Text('BİRLİKTE BAŞARDINIZ!',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22, fontWeight: FontWeight.w700, color: _P.text, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            // Score
            Text(session.score.toString(),
              style: GoogleFonts.cormorantGaramond(
                fontSize: 56, fontWeight: FontWeight.w700, color: _P.gold, height: 1)),
            const Text('PUAN', style: TextStyle(fontSize: 10, letterSpacing: 2, color: _P.muted)),
            const SizedBox(height: 6),
            Text('${session.blocks.length} blok dizdiniz!',
              style: const TextStyle(color: _P.muted, fontSize: 14)),
            const SizedBox(height: 32),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _outlineButton('Çık', _leaveGame),
              const SizedBox(width: 12),
              _goldButton('Tekrar Oyna', () async {
                setState(() => _isRestarting = true);
                await ref.read(stackTowerControllerProvider.notifier).restartGame();
                await Future.delayed(const Duration(milliseconds: 500));
                _enterGame();
              }),
            ]),
          ]),
        ),
      ),
    );
  }

  // ── Button helpers ────────────────────────────────────────────────────────
  Widget _goldButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        decoration: BoxDecoration(
          color: _P.gold, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x44C8A96E), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Text(label,
          style: const TextStyle(color: Color(0xFF5D4E37), fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }

  Widget _outlineButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.transparent, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _P.border),
        ),
        child: Text(label, style: const TextStyle(color: _P.muted, fontSize: 14)),
      ),
    );
  }
}

// ─── Unchanged game classes below ────────────────────────────────────────────

class _StackPainter extends CustomPainter {
  final List<StackedBlock> blocks;
  final List<Color> colors;
  _StackPainter({required this.blocks, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (blocks.isEmpty) return;
    final width = size.width;
    final height = size.height;
    const blockHeight = 30.0;
    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final blockColor = colors[block.colorIndex % colors.length];
      final top = height - ((i + 1) * blockHeight) - 100;
      final rect = Rect.fromLTWH(block.leftRatio * width, top, block.widthRatio * width, blockHeight);
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
      final shadowPath = Path()..addRRect(rRect.shift(const Offset(0, 4)));
      canvas.drawPath(shadowPath, Paint()..color = blockColor.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawRRect(rRect, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [blockColor, blockColor.withOpacity(0.7)]).createShader(rect));
      canvas.drawRRect(rRect, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = Colors.white.withOpacity(0.4));
    }
  }

  @override
  bool shouldRepaint(covariant _StackPainter oldDelegate) => blocks.length != oldDelegate.blocks.length;
}

class Debris {
  double leftRatio, top, widthRatio, height, velocityY, rotation, rotationSpeed;
  Color color;
  Debris({required this.leftRatio, required this.top, required this.widthRatio, required this.height, required this.color, this.velocityY = 0, this.rotation = 0, this.rotationSpeed = 0});
}

class _StarFieldPainter extends CustomPainter {
  final double density;
  _StarFieldPainter({this.density = 0.0});
  @override
  void paint(Canvas canvas, Size size) {
    if (density <= 0) return;
    final paint = Paint()..color = Colors.white.withOpacity(0.6 * density.clamp(0.0, 1.0));
    final random = Random(42);
    final starCount = (100 * density).toInt();
    for (int i = 0; i < starCount; i++) {
      canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), random.nextDouble() * 1.5, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _StarFieldPainter old) => old.density != density;
}

class Cloud { double x, y, width, speed; List<List<double>> puffs; Cloud({required this.x, required this.y, required this.width, required this.speed, required this.puffs}); }
class Bird { double x, y, speed, wingOffset; Bird({required this.x, required this.y, required this.speed, required this.wingOffset}); }
class Butterfly { double x, y, speedX, speedY; Color color; Butterfly({required this.x, required this.y, required this.speedX, required this.speedY, required this.color}); }

class _AtmospherePainter extends CustomPainter {
  final double score, animationValue;
  final List<Cloud> clouds;
  final List<Bird> birds;
  final List<Butterfly> butterflies;
  _AtmospherePainter({required this.score, required this.animationValue, required this.clouds, required this.birds, required this.butterflies});

  @override
  void paint(Canvas canvas, Size size) {
    _drawCelestialBody(canvas, size);
    if (score < 30) _drawClouds(canvas, size);
    if (score < 20) _drawBirds(canvas, size);
    if (score >= 10 && score < 20) _drawButterflies(canvas, size);
  }

  void _drawCelestialBody(Canvas canvas, Size size) {
    double sunX = 0, sunY = 0; Color glowColor = Colors.yellow; bool drawSun = true, drawMoon = false;
    if (score < 10) { final t = score / 10.0; sunX = size.width * (0.2 + 0.3 * t); sunY = size.height * (0.8 - 0.6 * t); glowColor = Colors.orangeAccent; }
    else if (score < 20) { sunX = size.width * 0.5; sunY = size.height * 0.2 + sin(animationValue * 2 * pi) * 20; glowColor = Colors.yellowAccent; }
    else if (score < 30) { final t = (score - 20) / 10.0; sunX = size.width * (0.5 + 0.3 * t); sunY = size.height * (0.2 + 0.6 * t); glowColor = Colors.deepOrangeAccent; }
    else { drawSun = false; drawMoon = true; final t = ((score - 30) % 50) / 50.0; sunX = size.width * t; sunY = size.height * 0.2; }
    if (drawSun) {
      canvas.drawCircle(Offset(sunX, sunY), 40, Paint()..color = glowColor.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
      canvas.drawCircle(Offset(sunX, sunY), 20, Paint()..color = Colors.white.withOpacity(0.9));
    }
    if (drawMoon) {
      canvas.drawCircle(Offset(sunX, sunY), 15, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(sunX + 5, sunY - 2), 12, Paint()..color = Colors.black.withOpacity(0.2));
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    for (var cloud in clouds) {
      double currentX = (cloud.x + animationValue * 5 * cloud.speed) % 1.5 - 0.25;
      final center = Offset(currentX * size.width, cloud.y * size.height);
      final w = cloud.width * size.width;
      for (var puff in cloud.puffs) {
        canvas.drawCircle(center + Offset(puff[0] * w, puff[1] * w), puff[2] * w, Paint()..color = Colors.white.withOpacity(puff[3] * 0.6));
      }
    }
  }

  void _drawBirds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    for (var bird in birds) {
      double currentX = (bird.x + animationValue * 15 * bird.speed) % 1.2 - 0.1;
      final center = Offset(currentX * size.width, bird.y * size.height);
      final flap = sin(animationValue * 25 + bird.wingOffset);
      final wingY = flap * 6;
      final path = Path();
      path.moveTo(center.dx - 12, center.dy + wingY);
      path.quadraticBezierTo(center.dx - 5, center.dy - wingY * 0.5, center.dx, center.dy + 3);
      path.quadraticBezierTo(center.dx + 5, center.dy - wingY * 0.5, center.dx + 12, center.dy + wingY);
      canvas.drawPath(path, paint);
    }
  }

  void _drawButterflies(Canvas canvas, Size size) {
    for (var bf in butterflies) {
      double currentX = (bf.x + sin(animationValue * 20 + bf.y * 10) * 0.05 + bf.speedX * animationValue * 100) % 1.0;
      double currentY = (bf.y + cos(animationValue * 15 + bf.x * 10) * 0.05 + bf.speedY * animationValue * 100) % 1.0;
      final center = Offset(currentX * size.width, currentY * size.height);
      final wingSize = 4.0 * (1 + sin(animationValue * 30));
      final paint = Paint()..color = bf.color;
      canvas.drawCircle(center + Offset(-wingSize, 0), 3, paint);
      canvas.drawCircle(center + Offset(wingSize, 0), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter old) => old.animationValue != animationValue || old.score != score;
}

class FallingBlock {
  double leftRatio, top, widthRatio, velocityY;
  Color color;
  FallingBlock({required this.leftRatio, required this.top, required this.widthRatio, required this.color, this.velocityY = 0});
}

class HeartParticle {
  double x, y, vx, vy, life, scale;
  Color color;
  HeartParticle({required this.x, required this.y, required this.color})
    : vx = (Random().nextDouble() - 0.5) * 4,
      vy = -Random().nextDouble() * 5 - 2,
      life = 1.0,
      scale = 0.5 + Random().nextDouble() * 0.5;
  void update() { x += vx; y += vy; vy += 0.1; life -= 0.02; }
  double get opacity => life.clamp(0.0, 1.0);
}

class _HeartParticlePainter extends CustomPainter {
  final List<HeartParticle> particles;
  _HeartParticlePainter(this.particles);
  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()..color = p.color.withOpacity(p.opacity);
      final width = 10 * p.scale; final height = 10 * p.scale;
      final path = Path();
      path.moveTo(p.x, p.y + height / 4);
      path.cubicTo(p.x, p.y, p.x - width / 2, p.y, p.x - width / 2, p.y + height / 4);
      path.cubicTo(p.x - width / 2, p.y + height / 2, p.x, p.y + height, p.x, p.y + height);
      path.cubicTo(p.x, p.y + height, p.x + width / 2, p.y + height / 2, p.x + width / 2, p.y + height / 4);
      path.cubicTo(p.x + width / 2, p.y, p.x, p.y, p.x, p.y + height / 4);
      canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _HeartParticlePainter old) => true;
}