import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For haptic feedback
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math'; // For random (stars)
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/games/stack_tower/domain/entities/stacked_block.dart';
import 'package:heartbit/features/games/stack_tower/presentation/providers/stack_tower_provider.dart';

/// Stack Tower Game Screen - Cooperative block stacking game
/// 
/// Partners take turns placing blocks. They work together to build
/// the tallest tower possible. Speed increases after each block.
class StackTowerScreen extends ConsumerStatefulWidget {
  const StackTowerScreen({super.key});

  @override
  ConsumerState<StackTowerScreen> createState() => _StackTowerScreenState();
}

class _StackTowerScreenState extends ConsumerState<StackTowerScreen>
    with TickerProviderStateMixin {
  // Animation Controller for block movement
  late AnimationController _moveController;
  
  // Current block position (0.0 - 1.0 ratio)
  double _currentLeftRatio = 0.3;
  bool _movingRight = true;
  
  // Flag to prevent double navigation
  bool _isLeaving = false;
  
  // Flag to prevent navigation loop during restart
  bool _isRestarting = false;
  bool _canPopNow = false; // Flag to allow popping after confirmation

  // SYSTEM STATE
  double _gameAreaHeight = 0; // Capture exact height of the game area

  // FALLING BLOCK STATE
  FallingBlock? _fallingBlock;
  bool _isDropping = false;

  // DYNAMIC BACKGROUND STATE
  final List<List<Color>> _bgGradients = [
    [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)], // Sunrise (Pink/Peach)
    [const Color(0xFF89F7FE), const Color(0xFF66A6FF)], // Day (Blue/Cyan)
    [const Color(0xFFFA709A), const Color(0xFFFEE140)], // Sunset (Orange/Pink)
    [const Color(0xFF243949), const Color(0xFF517FA4)], // Night (Dark Blue)
    [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)], // Space
  ];

  // Block Colors
  final List<Color> _blockColors = [
    const Color(0xFFFF6B6B), // Red
    const Color(0xFFFF8E53), // Orange
    const Color(0xFFFFD93D), // Yellow
    const Color(0xFF6BCB77), // Green
    const Color(0xFF4D96FF), // Blue
    const Color(0xFF9B59B6), // Purple
    const Color(0xFFE91E63), // Pink
    const Color(0xFF00BCD4), // Cyan
  ];
  
  // Falling debris list
  final List<Debris> _debrisList = [];
  late Ticker _ticker;

  // ATMOSPHERE STATE
  late AnimationController _bgController;
  final List<Cloud> _clouds = [];
  final List<Bird> _birds = [];
  final List<Butterfly> _butterflies = [];
  final Random _random = Random();
  
  // VISUAL FEEDBACK STATE
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
    
    // Auto-enter game when screen opens
    // This ensures the user is added to readyUsers whether they create or join
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterGame();
    });
  }

  void _initVisualFeedback() {
    _turnChangeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _flashController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
    );
  }


  void _initAtmosphere() {
    // Determine initial elements based on "Day" assumption or random
    // Clouds
    for (int i = 0; i < 5; i++) {
        List<List<double>> puffs = [];
        // Generate 5-8 puffs per cloud for organic shape
        int puffCount = 5 + _random.nextInt(4);
        for(int j=0; j<puffCount; j++) {
            puffs.add([
                (_random.nextDouble() - 0.5) * 0.8, // offsetX (-0.4 to 0.4 relative to width)
                (_random.nextDouble() - 0.5) * 0.4, // offsetY
                0.25 + _random.nextDouble() * 0.25, // radiusRatio (relative to width)
                0.3 + _random.nextDouble() * 0.3    // opacity
            ]);
        }

        _clouds.add(Cloud(
            x: _random.nextDouble(),
            y: 0.1 + _random.nextDouble() * 0.4,
            width: 0.15 + _random.nextDouble() * 0.15,
            speed: 0.0002 + _random.nextDouble() * 0.0003,
            puffs: puffs,
        ));
    }
    // Birds
    for (int i = 0; i < 3; i++) {
        _birds.add(Bird(
            x: _random.nextDouble(),
            y: 0.1 + _random.nextDouble() * 0.3,
            speed: 0.001 + _random.nextDouble() * 0.001,
            wingOffset: _random.nextDouble() * pi,
        ));
    }
    // Butterflies
    for (int i = 0; i < 5; i++) {
        _butterflies.add(Butterfly(
            x: _random.nextDouble(),
            y: 0.5 + _random.nextDouble() * 0.4,
            speedX: (0.5 - _random.nextDouble()) * 0.001,
            speedY: (0.5 - _random.nextDouble()) * 0.001,
            color: Color.fromARGB(255, _random.nextInt(255), _random.nextInt(255), _random.nextInt(255)),
        ));
    }
    
    _bgController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 20), // Long loop
    )..repeat();
  }

  void _initController() {
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateBlockPosition);

    _ticker = createTicker((elapsed) {
      // Update Falling Block
      if (_isDropping && _fallingBlock != null) {
        _updateFallingBlock();
      }

      // Update Particles
      if (_particles.isNotEmpty) {
        setState(() {
            _particles.removeWhere((p) {
                p.update();
                return p.opacity <= 0;
            });
        });
      }

      // Update Debris
      if (_debrisList.isNotEmpty) {
        setState(() {
          _debrisList.removeWhere((debris) {
            debris.top += debris.velocityY;
            debris.velocityY += 0.5; // Gravity
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
       // Gravity physics
       _fallingBlock!.velocityY += 1.5; 
       _fallingBlock!.top += _fallingBlock!.velocityY;

       // Calculate target Y (Top of the calculated stack)
       // Use _gameAreaHeight instead of MediaQuery to account for AppBar/StatusBar
       final screenHeight = _gameAreaHeight > 0 ? _gameAreaHeight : MediaQuery.of(context).size.height;
       
       // CORRECTION: The StackPainter is inside a Positioned(top: 150, bottom: 100).
       // Its paint bounds are height = ScreenHeight - 250.
       // Its base line is local height - 50.
       // Global Base Y = 150 + (ScreenHeight - 250 - 50) = ScreenHeight - 150.
       final globalBaseY = screenHeight - 150.0;
       
       const blockHeight = 30.0;
       // The target is ON TOP of the current stack
       final stackHeight = session.blocks.length * blockHeight;
       final targetY = globalBaseY - stackHeight;

       // Check collision
       if (_fallingBlock!.top >= targetY) {
         // Landed!
         _fallingBlock!.top = targetY; // Snap to grid
         _handleBlockLanding(targetY);
         _isDropping = false;
         
         // Keep falling block visible for a moment or let optimistic update handle it?
         // We set it to null, but we need to ensure the gap isn't visible.
         // Effectively, we rely on the server update or optimistic local state.
         // For now, let's rely on the speed of update, but fixing the coordinate 
         // is the most important step for the user's issue.
         _fallingBlock = null;
       }
     });
  }

  void _updateBlockPosition() {
    final session = ref.read(activeStackTowerSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    
    // Only animate if it's our turn and game is playing
    if (session == null || 
        session.status != 'playing' || 
        session.currentTurnUserId != userId) {
      return;
    }

    final topBlock = session.blocks.last;
    final currentWidth = topBlock.widthRatio;
    final speed = 0.008 * session.speed;

    setState(() {
      if (_movingRight) {
        _currentLeftRatio += speed;
        if (_currentLeftRatio + currentWidth >= 0.95) {
          _movingRight = false;
        }
      } else {
        _currentLeftRatio -= speed;
        if (_currentLeftRatio <= 0.05) {
          _movingRight = true;
        }
      }
    });
  }

  void _onTap() {
    final session = ref.read(activeStackTowerSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    
    // Validate turn and prevent double tapping while dropping
    if (session == null || 
        session.currentTurnUserId != userId || 
        _isDropping) {
      return;
    }

    HapticFeedback.lightImpact();

    final topBlock = session.blocks.last;

    // Start Dropping Sequence
    setState(() {
      _isDropping = true;
      _fallingBlock = FallingBlock(
        leftRatio: _currentLeftRatio,
        top: 100, // Start from the localized moving block position (top: 100)
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
    // Use the falling block's final position
    final leftRatio = _fallingBlock?.leftRatio ?? _currentLeftRatio;
    final widthRatio = topBlock.widthRatio;
    final newRight = leftRatio + widthRatio;
    final topRight = topBlock.leftRatio + topBlock.widthRatio;
    
    // Check overlapping
    final overlapLeft = leftRatio > topBlock.leftRatio ? leftRatio : topBlock.leftRatio;
    final overlapRight = newRight < topRight ? newRight : topRight;
    final overlapWidth = overlapRight - overlapLeft;

    // Use the passed valid landingY
    final landY = landingY;
    
    // Calculate Debris
    if (overlapWidth > 0 && overlapWidth < widthRatio) {
      double debrisLeft, debrisWidth;
      
      // If we are to the left of the stack
      if (leftRatio < topBlock.leftRatio) {
        debrisLeft = leftRatio;
        debrisWidth = topBlock.leftRatio - leftRatio;
      } 
      // If we are to the right of the stack
      else {
        debrisLeft = topRight;
        debrisWidth = newRight - topRight;
      }

      if (debrisWidth > 0.01) {
        final newDebris = Debris(
          leftRatio: debrisLeft,
          top: landY, // Spawn at landing height
          widthRatio: debrisWidth,
          height: 30,
          color: _blockColors[session.blocks.length % _blockColors.length],
          velocityY: -2.0, // Slight bounce up
          rotationSpeed: (0.1 - (0.2 * (leftRatio > topBlock.leftRatio ? 0 : 1))),
        );
        _debrisList.add(newDebris);
      }
    } else if (overlapWidth <= 0.01) {
       // Missed completely
       final newDebris = Debris(
          leftRatio: leftRatio,
          top: landY,
          widthRatio: widthRatio,
          height: 30,
          color: _blockColors[session.blocks.length % _blockColors.length],
          velocityY: 0, // Fall straight down
          rotationSpeed: 0.1,
        );
        _debrisList.add(newDebris);
    }
    
    // Optimistic Update is handled by the server response mostly, 
    // but we snap the moving block reset here
    setState(() {
      _currentLeftRatio = overlapLeft; 
    });
    
    // Check for "Perfect" stack (Visual Feedback)
    final diff = (overlapWidth - topBlock.widthRatio).abs();
    if (diff < 0.02) { // 2% margin for "Perfect"
        // Trigger Flash
        _flashController.forward(from: 0);
        
        // Trigger Particles
        final centerLeft = overlapLeft + overlapWidth / 2;
        // Top position is topBlock.top (or where the new block landed)
        // We need to map coordinate space. 
        // The stack is drawn relative to _gameAreaHeight.
        // But CustomPaint uses full screen/container.
        // Let's approximate: 30px per block. 
        // We know logical top of the landed block is session.blocks.length * 30 from bottom?
        // Actually, we can use _fallingBlock!.top
        
        for(int i=0; i<15; i++) {
            _particles.add(HeartParticle(
                x: centerLeft * MediaQuery.of(context).size.width, // Use screenWidth from context
                y: _fallingBlock!.top,
                color: _fallingBlock!.color,
            ));
        }
    }

    final success = await ref.read(stackTowerControllerProvider.notifier).placeBlock(
      leftRatio: _fallingBlock!.leftRatio,
      widthRatio: _fallingBlock!.widthRatio,
    );

    if (!success) {
      HapticFeedback.heavyImpact();
    }
  }

  void _enterGame() {
    ref.read(stackTowerControllerProvider.notifier).enterGame();
  }

  Future<void> _handleExitAttempt() async {
    final session = ref.read(activeStackTowerSessionProvider).valueOrNull;
    
    // If game is over or session is null, just leave
    if (session == null || session.status == 'gameover') {
        _forceLeave();
        return;
    }

    // Show confirmation dialog
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Oyundan Ayrıl?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
            'Çıkarsan oyun ikiniz için de biter.',
            style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ayrıl', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
        _forceLeave();
    }
  }

  void _forceLeave() {
    _isLeaving = true;
    ref.read(stackTowerControllerProvider.notifier).leaveGame();
    
    if (mounted) {
        setState(() {
            _canPopNow = true;
        });
        Navigator.of(context).pop();
    }
  }

  void _leaveGame() {
    // This method is kept for compatibility if called directly, 
    // but logic is moved to _handleExitAttempt
    _handleExitAttempt(); 
  }

  @override
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
    // 0-10: Sunrise -> Day
    // 10-20: Day -> Sunset
    // 20-30: Sunset -> Night
    // 30-50: Night -> Space
    
    double t = 0.0;
    int phase = 0;
    
    if (score < 10) {
      phase = 0;
      t = score / 10.0;
    } else if (score < 20) {
      phase = 1;
      t = (score - 10) / 10.0;
    } else if (score < 30) {
      phase = 2;
      t = (score - 20) / 10.0;
    } else if (score < 50) {
      phase = 3;
      t = (score - 30) / 20.0;
    } else {
      phase = 4;
      t = 1.0; // Stay at Space
    }
    
    // Ensure indices are valid
    final startGradient = _bgGradients[phase];
    final endGradient = _bgGradients[(phase + 1).clamp(0, _bgGradients.length - 1)];
    
    // Simple interpolation (lerp)
    // Since gradients can have different lengths, we simplify by just lerping the first and last colors
    // and reconstructing a simple 2-color gradient for smooth transition
    final c1 = Color.lerp(startGradient.first, endGradient.first, t)!;
    final c2 = Color.lerp(startGradient.last, endGradient.last, t)!;
    
    return [c1, c2];
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(activeStackTowerSessionProvider);
    final userId = ref.watch(authUserIdProvider);

    // Listen for session changes - auto-join and auto-start
    ref.listen(activeStackTowerSessionProvider, (prev, next) {
      final session = next.valueOrNull;
      
      if (session != null) {
        // Auto-start game when both users are ready
        if (session.status == 'waiting' && session.bothReady) {
          ref.read(stackTowerControllerProvider.notifier).startGame();
          _currentLeftRatio = 0.3;
          _movingRight = true;
        }
        
        // Start animation when game is playing
        if (session.status == 'playing') {
          if (!_moveController.isAnimating) {
            _moveController.repeat();
          }
        } else {
          _moveController.stop();
        }
      }
      
      // If session was cancelled (by partner leaving), go back
      // Only auto-navigate if user didn't initiate the leave AND we are not restarting
      // AND next state is not loading/error (which could return null value)
      if (prev?.valueOrNull != null && 
          next.valueOrNull == null && 
          !next.isLoading && 
          !next.hasError && // Don't pop on error (parsing/network)
          !_isLeaving && 
          !_isRestarting) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isLeaving && !_isRestarting && !next.isLoading && !next.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Partner oyundan ayrıldı'),
                  backgroundColor: AppColors.error,
                ),
              );
              Navigator.of(context).pop();
            }
          });
        }
      }
      
      // Log errors 
      if (next.hasError) {
          debugPrint('StackTower Session Error: ${next.error}');
          debugPrint('Stacktrace: ${next.stackTrace}');
      }
      
      // Reset restarting flag when we get a new valid session
      if (_isRestarting && next.valueOrNull != null) {
        _isRestarting = false;
      }
      
      // Turn Change Animation
      if (prev?.valueOrNull != null && next.valueOrNull != null) {
        final prevSession = prev!.valueOrNull!;
        final nextSession = next.valueOrNull!;
        final myId = ref.read(authUserIdProvider);
        
        // If turn changed FROM me TO partner
        if (prevSession.currentTurnUserId == myId && nextSession.currentTurnUserId != myId) {
            _turnChangeController.forward(from: 0);
            setState(() {
                _showTurnChangeHeart = true;
            });
        }
      }
    });

    return PopScope(
      canPop: _canPopNow,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleExitAttempt();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.maybePop(context), // Triggers PopScope
          ),
          title: const Text(
            'Stack Tower',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              shadows: [
                  Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Color(0x804A0E4E), // Deep plum shadow
                  ),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: sessionAsync.when(
          data: (session) {
            if (session == null) {
              // enterGame() is auto-called in initState, show loading while session is being created
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Oyun hazırlanıyor...',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }
            
            if (session.status == 'waiting') {
              return _buildWaitingRoom(session, userId);
            }
            
            if (session.status == 'gameover') {
              return _buildGameOverScreen(session);
            }
            
            return _buildGameScreen(session, userId);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text('Hata: $e', style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _enterGame,
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.layers,
              size: 80,
              color: AppColors.accent,
            ),
            const SizedBox(height: 24),
            const Text(
              'Stack Tower',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Partnerinle sırayla blok koyarak\nen yüksek kuleyi inşa edin!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _enterGame,
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text(
                'Oyuna Katıl',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingRoom(StackTowerSession session, String? userId) {
    final isUserReady = session.readyUsers.contains(userId);
    final partnerReady = session.readyUsers.length > 1;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated waiting icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 3.14159 * 2,
                  child: child,
                );
              },
              onEnd: () => setState(() {}),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.accent,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Bekleme Odası',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            // Debug Couple ID
            Text(
              'Couple ID: ${session.coupleId.substring(0, 4)}...',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            // Status indicators
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildPlayerStatus(
                    'Sen',
                    isUserReady,
                    Icons.person,
                  ),
                  const SizedBox(height: 12),
                  _buildPlayerStatus(
                    'Partner',
                    partnerReady,
                    Icons.favorite,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!partnerReady)
              Text(
                isUserReady
                  ? '⏳ Partnerin bağlanmasını bekliyorsun...\nPartnerin telefonuna bildirim gönderildi!'
                  : 'Partnerin seni bekliyor!\nOyuna katılmak için butona bas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              )
            else
              const Text(
                '🎮 Her ikiniz de hazır!\nOyun başlıyor...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 32),
            if (!isUserReady)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: _enterGame,
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text(
                    'Oyuna Katıl',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                ),
              ),
            OutlinedButton.icon(
              onPressed: _leaveGame,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Çık'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStatus(String label, bool ready, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ready ? AppColors.accent : AppColors.border,
          ),
          child: Icon(
            icon,
            color: ready ? Colors.white : AppColors.textSecondary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ready 
                ? AppColors.accent.withOpacity(0.2) 
                : AppColors.border.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            ready ? 'Hazır ✓' : 'Bekleniyor...',
            style: TextStyle(
              color: ready ? AppColors.accent : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_showTurnChangeHeart)
            AnimatedBuilder(
                animation: _turnChangeController,
                builder: (context, child) {
                    if (_turnChangeController.isCompleted) {
                        // Reset visibility after animation
                        // Using addPostFrameCallback to avoid build issues or just let it hide naturally if we use opacity
                        // But best to hide it to avoid hit testing
                        if (_showTurnChangeHeart) {
                             WidgetsBinding.instance.addPostFrameCallback((_) {
                                 if (mounted) setState(() => _showTurnChangeHeart = false);
                             });
                        }
                        return const SizedBox.shrink();
                    }
                    
                    final val = _turnChangeController.value;
                    // Start center, fly up-right (assuming partner logic visual)
                    // Or just fly UP
                    final dy = val * -600;
                    final scale = 1.0 + sin(val * pi) * 0.5;
                    final opacity = 1.0 - val;
                    
                    return Positioned(
                        top: MediaQuery.of(context).size.height / 2 + dy,
                        left: MediaQuery.of(context).size.width / 2 - 40,
                        child: Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                                scale: scale,
                                child: const Icon(
                                    Icons.favorite, 
                                    color: Colors.pinkAccent, 
                                    size: 80
                                ),
                            ),
                        ),
                    );
                },
            ),
            
        // Flash Effect
        IgnorePointer(
            child: AnimatedBuilder(
                animation: _flashController,
                builder: (context, child) {
                    return Container(
                        color: Colors.white.withOpacity(0.3 * (1 - _flashController.value)),
                    );
                },
            ),
        ),

      ],
    );
  }

  Widget _buildGameScreen(StackTowerSession session, String? userId) {
    final isMyTurn = session.currentTurnUserId == userId;
    final topBlock = session.blocks.last;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Update game area height
        _gameAreaHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth; // Use constraints width too for consistency

        // Smoothly animate the "score" visual (background/atmosphere) over time
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: session.blocks.length.toDouble(),
          ),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOutSine,
          builder: (context, animatedScore, child) {
            return GestureDetector(
              onTap: isMyTurn ? _onTap : null,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  // Dynamic Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: _getBackgroundColors(animatedScore),
                      ),
                    ),
                  ),
                  
                  // ATMOSPHERE LAYER (Sun, Moon, Clouds, Birds, Butterflies)
                  Positioned.fill(
                    child: AnimatedBuilder(
                        animation: _bgController,
                        builder: (context, child) {
                            return CustomPaint(
                                painter: _AtmospherePainter(
                                    score: animatedScore,
                                    animationValue: _bgController.value,
                                    clouds: _clouds,
                                    birds: _birds,
                                    butterflies: _butterflies,
                                ),
                            );
                        },
                    ),
                  ),
                  
                  // Stars Overlay for Night/Space phases
                  if (animatedScore > 20)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _StarFieldPainter(
                          density: (animatedScore - 20) / 40.0, // Increase stars as we go higher
                        ),
                      ),
                    ),
    
                  // Stacking Area
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    top: 150,
                    child: CustomPaint(
                      painter: _StackPainter(
                        blocks: session.blocks,
                        colors: _blockColors,
                      ),
                    ),
                  ),
    
                  // Moving Block
                  if (isMyTurn && !_isDropping)
                    Positioned(
                      top: 100,
                      left: _currentLeftRatio * screenWidth,
                      child: Container(
                        width: topBlock.widthRatio * screenWidth,
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _blockColors[session.blocks.length % _blockColors.length],
                              _blockColors[session.blocks.length % _blockColors.length].withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: _blockColors[session.blocks.length % _blockColors.length].withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Falling Block Animation
                  if (_fallingBlock != null)
                     Positioned(
                      top: _fallingBlock!.top,
                      left: _fallingBlock!.leftRatio * screenWidth,
                      child: Container(
                        width: _fallingBlock!.widthRatio * screenWidth,
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _fallingBlock!.color,
                              _fallingBlock!.color.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6), // Jellybean radius
                          border: Border.all(
                             color: Colors.white.withOpacity(0.4),
                             width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _fallingBlock!.color.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),

            // Particles
            if (_particles.isNotEmpty)
                Positioned.fill(
                    child: CustomPaint(
                        painter: _HeartParticlePainter(_particles),
                    ),
                ),

                  // Debris
                  ..._debrisList.map((debris) {
                    return Positioned(
                      left: debris.leftRatio * screenWidth,
                      top: debris.top,
                      child: Transform.rotate(
                        angle: debris.rotation,
                        child: Container(
                          width: debris.widthRatio * screenWidth,
                          height: debris.height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                debris.color,
                                debris.color.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6), // Jellybean radius
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: debris.color.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  
                  // Score Display
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            session.score.toString(),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Color(0xFF4A0E4E), // Deep plum/purple shadow
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Kat: ${session.blocks.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Color(0xFF4A0E4E), // Deep plum shadow
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Speed Indicator (Optional) - Re-adding based on user feedback
                  Positioned(
                    top: 10,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.speed, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${session.speed.toStringAsFixed(1)}x',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Turn Indicator
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMyTurn 
                              ? AppColors.primary.withOpacity(0.2) 
                              : AppColors.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isMyTurn ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isMyTurn 
                                  ? AppColors.primary.withOpacity(0.3) 
                                  : Colors.black12,
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          isMyTurn ? '👆 SENİN SIRAN!' : '⏳ PARTNERİN OYNUYOR',
                          style: TextStyle(
                            color: isMyTurn ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildGameOverScreen(StackTowerSession session) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 64,
                color: AppColors.accent,
              ),
              const SizedBox(height: 16),
              const Text(
                'BİRLİKTE BAŞARDINIZ!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Skor: ${session.score}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${session.blocks.length} blok dizdiniz!',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: _leaveGame,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Çık'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Set restarting flag to prevent navigation
                      setState(() {
                        _isRestarting = true;
                      });
                      
                      // Cancel current session
                      await ref.read(stackTowerControllerProvider.notifier).restartGame();
                      
                      // Wait a bit to ensure session updates
                      await Future.delayed(const Duration(milliseconds: 500));

                      // Enter game again (join the reset session)
                      _enterGame();
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      'Tekrar Oyna',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for rendering stacked blocks
class _StackPainter extends CustomPainter {
  final List<StackedBlock> blocks;
  final List<Color> colors;

  _StackPainter({required this.blocks, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (blocks.isEmpty) return;

    final width = size.width;
    final height = size.height;
    
    // Base block height (approximate, since we don't have exact screen height here, 
    // but typically we want them to look like the falling one which is 30px)
    const blockHeight = 30.0;

    for (int i = 0; i < blocks.length; i++) {
        final block = blocks[i];
        final blockColor = colors[block.colorIndex % colors.length];
        
        // Calculate position from bottom
        // Index 0 is at bottom (height - blockHeight)
        // Index 1 is at height - 2*blockHeight, etc.
        // We might need to adjust based on camera/scroll later, but for now fixed stack
        final top = height - ((i + 1) * blockHeight) - 100; // -100 to match the Positioned bottom offset
        
        final rect = Rect.fromLTWH(
            block.leftRatio * width,
            top,
            block.widthRatio * width,
            blockHeight,
        );

        final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

        // Gradient Paint
        final paint = Paint()
            ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                    blockColor,
                    blockColor.withOpacity(0.7),
                ],
            ).createShader(rect);

        // Shadow Paint (simplified for performance)
        final shadowPath = Path()..addRRect(rRect.shift(const Offset(0, 4)));
        final shadowPaint = Paint()
            ..color = blockColor.withOpacity(0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        canvas.drawPath(shadowPath, shadowPaint);
        canvas.drawRRect(rRect, paint);
        
        // Glassmorphism Highlight (Top Border)
        final highlightPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = Colors.white.withOpacity(0.4);
            
        // Draw just the top part or full border? Full border looks cleaner for "jelly"
        canvas.drawRRect(rRect, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StackPainter oldDelegate) {
    return blocks.length != oldDelegate.blocks.length;
  }
}

/// Represents a falling piece of block (debris)
class Debris {
  double leftRatio;
  double top; // in pixels (since screen height varies)
  double widthRatio;
  double height;
  Color color;
  double velocityY;
  double rotation;
  double rotationSpeed;

  Debris({
    required this.leftRatio,
    required this.top,
    required this.widthRatio,
    required this.height,
    required this.color,
    this.velocityY = 0,
    this.rotation = 0,
    this.rotationSpeed = 0,
  });
}

class _StarFieldPainter extends CustomPainter {
  final double density; // 0.0 to 1.0
  
  _StarFieldPainter({this.density = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    if (density <= 0) return;
    
    final paint = Paint()..color = Colors.white.withOpacity(0.6 * density.clamp(0.0, 1.0));
    final random = Random(42); // Fixed seed for consistent stars
    
    final starCount = (100 * density).toInt();
    
    for (int i = 0; i < starCount; i++) {
        final x = random.nextDouble() * size.width;
        final y = random.nextDouble() * size.height;
        final radius = random.nextDouble() * 1.5;
        canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) {
    return oldDelegate.density != density;
  }
}

// --- ATMOSPHERE CLASSES ---

class Cloud {
  double x, y, width, speed;
  List<List<double>> puffs; // [offsetX, offsetY, radius, opacity]
  Cloud({required this.x, required this.y, required this.width, required this.speed, required this.puffs});
}

class Bird {
  double x, y, speed, wingOffset;
  Bird({required this.x, required this.y, required this.speed, required this.wingOffset});
}

class Butterfly {
  double x, y, speedX, speedY;
  Color color;
  Butterfly({required this.x, required this.y, required this.speedX, required this.speedY, required this.color});
}

class _AtmospherePainter extends CustomPainter {
  final double score;
  final double animationValue;
  final List<Cloud> clouds;
  final List<Bird> birds;
  final List<Butterfly> butterflies;

  _AtmospherePainter({
    required this.score,
    required this.animationValue,
    required this.clouds,
    required this.birds,
    required this.butterflies,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Celestial Body (Sun/Moon) based on Score
    _drawCelestialBody(canvas, size);

    // 2. Draw Clouds (Day/Sunset)
    if (score < 30) {
        _drawClouds(canvas, size);
    }
    
    // 3. Draw Birds (Sunrise/Day)
    if (score < 20) {
        _drawBirds(canvas, size);
    }
    
    // 4. Draw Butterflies (Day only)
    if (score >= 10 && score < 20) {
        _drawButterflies(canvas, size);
    }
  }

  void _drawCelestialBody(Canvas canvas, Size size) {
    // Cycle: 0-10 Rise, 10-20 High, 20-30 Set, 30+ Moon
    double sunX = 0;
    double sunY = 0;
    Color glowColor = Colors.yellow;
    bool drawSun = true;
    bool drawMoon = false;

    if (score < 10) {
        // Sunrise: Bottom-Left to Top-Center
        final t = score / 10.0;
        sunX = size.width * (0.2 + 0.3 * t);
        sunY = size.height * (0.8 - 0.6 * t);
        glowColor = Colors.orangeAccent;
    } else if (score < 20) {
        // Day: Hovering Top-Center
        final t = (score - 10) / 10.0;
        sunX = size.width * 0.5;
        sunY = size.height * 0.2 + sin(animationValue * 2 * pi) * 20; // Slight bobbing
        glowColor = Colors.yellowAccent;
    } else if (score < 30) {
        // Sunset: Top-Center to Bottom-Right
        final t = (score - 20) / 10.0;
        sunX = size.width * (0.5 + 0.3 * t);
        sunY = size.height * (0.2 + 0.6 * t);
        glowColor = Colors.deepOrangeAccent;
    } else {
        // Night: Moon Moves across
        drawSun = false;
        drawMoon = true;
        final t = ((score - 30) % 50) / 50.0; // Cycle across sky
        sunX = size.width * t;
        sunY = size.height * 0.2;
    }

    if (drawSun) {
        final paint = Paint()
            ..color = glowColor.withOpacity(0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
        canvas.drawCircle(Offset(sunX, sunY), 40, paint);
        
        paint.color = Colors.white.withOpacity(0.9);
        paint.maskFilter = null;
        canvas.drawCircle(Offset(sunX, sunY), 20, paint);
    }

    if (drawMoon) {
        final paint = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(sunX, sunY), 15, paint);
        // Crater/Shadow
        paint.color = Colors.black.withOpacity(0.2); // Background color hack
        canvas.drawCircle(Offset(sunX + 5, sunY - 2), 12, paint);
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    for (var cloud in clouds) {
        // Move cloud
        double currentX = (cloud.x + animationValue * 5 * cloud.speed) % 1.5 - 0.25; 
        
        final center = Offset(currentX * size.width, cloud.y * size.height);
        final w = cloud.width * size.width;
        
        // Draw organic puffs
        for (var puff in cloud.puffs) {
           final paint = Paint()..color = Colors.white.withOpacity(puff[3] * 0.6); // Base opacity
           
           // Puffs are drawn relative to cloud center
           canvas.drawCircle(
               center + Offset(puff[0] * w, puff[1] * w),
               puff[2] * w,
               paint
           );
        }
    }
  }

  void _drawBirds(Canvas canvas, Size size) {
    final paint = Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

    for (var bird in birds) {
        // Move bird
        double currentX = (bird.x + animationValue * 15 * bird.speed) % 1.2 - 0.1;
        
        final center = Offset(currentX * size.width, bird.y * size.height);
        // Smoother sine wave flapping
        final flap = sin(animationValue * 25 + bird.wingOffset);
        final wingY = flap * 6;
        
        final path = Path();
        
        // Left Wing (Bezier for curve)
        path.moveTo(center.dx - 12, center.dy + wingY);
         path.quadraticBezierTo(
            center.dx - 5, center.dy - wingY * 0.5, // Control point
            center.dx, center.dy + 3 // Body center (dipping slightly)
        );
        
        // Right Wing
        path.quadraticBezierTo(
            center.dx + 5, center.dy - wingY * 0.5,
            center.dx + 12, center.dy + wingY
        );
        
        canvas.drawPath(path, paint);
    }
  }

  void _drawButterflies(Canvas canvas, Size size) {
    for (var bf in butterflies) {
        // Chaotic movement
        double currentX = (bf.x + sin(animationValue * 20 + bf.y*10) * 0.05 + bf.speedX * animationValue * 100) % 1.0;
        double currentY = (bf.y + cos(animationValue * 15 + bf.x*10) * 0.05 + bf.speedY * animationValue * 100) % 1.0;
        
        final center = Offset(currentX * size.width, currentY * size.height);
        final wingSize = 4.0 * (1 + sin(animationValue * 30));
        
        final paint = Paint()..color = bf.color;
        canvas.drawCircle(center + Offset(-wingSize, 0), 3, paint);
        canvas.drawCircle(center + Offset(wingSize, 0), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.score != score;
  }
}

/// Represents the active block falling down
class FallingBlock {
  double leftRatio;
  double top;
  double widthRatio;
  Color color;
  double velocityY;

  FallingBlock({
    required this.leftRatio,
    required this.top,
    required this.widthRatio,
    required this.color,
    this.velocityY = 0,
  });
}

class HeartParticle {
  double x, y;
  double vx, vy;
  double life; // 1.0 to 0.0
  double scale;
  Color color;
  
  HeartParticle({
    required this.x, 
    required this.y, 
    required this.color,
  }) : 
    vx = (Random().nextDouble() - 0.5) * 4,
    vy = -Random().nextDouble() * 5 - 2,
    life = 1.0,
    scale = 0.5 + Random().nextDouble() * 0.5;

  void update() {
    x += vx;
    y += vy;
    vy += 0.1; // gravity
    life -= 0.02;
  }
  
  double get opacity => life.clamp(0.0, 1.0);
}

class _HeartParticlePainter extends CustomPainter {
  final List<HeartParticle> particles;
  
  _HeartParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
        final paint = Paint()..color = p.color.withOpacity(p.opacity);
        
        // Draw heart shape or just circle for performance? 
        // User asked for "Heart particles". Let's draw simple hearts using path.
        final path = Path();
        final width = 10 * p.scale;
        final height = 10 * p.scale;
        
        path.moveTo(p.x, p.y + height / 4);
        path.cubicTo(p.x, p.y, p.x - width / 2, p.y, p.x - width / 2, p.y + height / 4);
        path.cubicTo(p.x - width / 2, p.y + height / 2, p.x, p.y + height, p.x, p.y + height);
        path.cubicTo(p.x, p.y + height, p.x + width / 2, p.y + height / 2, p.x + width / 2, p.y + height / 4);
        path.cubicTo(p.x + width / 2, p.y, p.x, p.y, p.x, p.y + height / 4);
        
        canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeartParticlePainter oldDelegate) {
    return true; // Always repaint animated particles
  }
}
