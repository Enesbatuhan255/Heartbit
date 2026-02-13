import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/drawing/domain/entities/drawing_session.dart';
import 'package:heartbit/features/drawing/presentation/providers/drawing_provider.dart';
import 'package:heartbit/features/drawing/presentation/widgets/drawing_canvas.dart';
import 'package:confetti/confetti.dart';

class DrawAndGuessScreen extends ConsumerStatefulWidget {
  const DrawAndGuessScreen({super.key});

  @override
  ConsumerState<DrawAndGuessScreen> createState() => _DrawAndGuessScreenState();
}

class _DrawAndGuessScreenState extends ConsumerState<DrawAndGuessScreen> {
  // Drawer state
  List<DrawingPoint> _localPoints = [];
  Timer? _timer;
  int _timeLeft = 60;
  
  // Guesser state
  final TextEditingController _guessController = TextEditingController();
  late ConfettiController _confettiController;

  // Session management
  late DateTime _entryTime;
  bool _isCancellingStale = false;
  String? _lastHandledSolvedSessionId; // Track which session we already handled auto-start for

  @override
  void initState() {
    super.initState();
    _entryTime = DateTime.now();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _guessController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startTimer(String sessionId) {
    if (_timer != null && _timer!.isActive) return;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
          _finishDrawing(sessionId);
        }
      });
    });
  }
  
  void _finishDrawing(String sessionId) {
    ref.read(drawingGameControllerProvider.notifier).finishDrawing(sessionId);
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    final x = (details.localPosition.dx / size.width).clamp(0.0, 1.0);
    final y = (details.localPosition.dy / size.height).clamp(0.0, 1.0);
    
    setState(() {
      _localPoints.add(DrawingPoint(x: x, y: y));
    });
  }

  void _onPanEnd(DragEndDetails details, String sessionId) {
    if (_localPoints.isNotEmpty) {
      // Add marker. Use -1, -1 to ensure it's off-screen even if drawn
      _localPoints.add(const DrawingPoint(x: -1, y: -1, isEnd: true)); 
      ref.read(drawingGameControllerProvider.notifier).updateDrawing(sessionId, _localPoints);
    }
  }

  Future<void> _onExit() async {
    final session = ref.read(activeDrawingSessionProvider).valueOrNull;
    
    // Cancel session if there's an active one (regardless of drawer/guesser)
    if (session != null && session.status != 'solved' && session.status != 'cancelled') {
      try {
        await ref.read(drawingGameControllerProvider.notifier).cancelSession(session.id);
      } catch (e) {
        debugPrint('Error cancelling session on exit: $e');
        // Continue to navigation regardless of error
      }
    }
    
    if (mounted) {
      context.go('/dashboard');
    }
  }

  Future<void> _handlePartnerExit() async {
    if (!mounted) return;
    
    // Stop timers and animations
    _timer?.cancel();
    _confettiController.stop();

    // Show blocking dialog to inform user
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Oyun Bitti', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Partneriniz oyunu terk etti.', 
          style: TextStyle(color: Colors.white70)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: const Text('Tamam', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    
    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(activeDrawingSessionProvider);
    final userId = ref.watch(authUserIdProvider);
    final coupleAsync = ref.watch(coupleStateProvider);
    final controllerState = ref.watch(drawingGameControllerProvider);
    
    // Listen for controller errors and show snackbar
    ref.listen(drawingGameControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${next.error}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    // Listen for 'solved' state to trigger confetti and auto-start next game
    ref.listen(activeDrawingSessionProvider, (previous, next) {
      final session = next.valueOrNull;
      if (session != null && session.status == 'solved') {
        // Only handle each solved session ONCE using session ID
        if (_lastHandledSolvedSessionId != session.id) {
           _lastHandledSolvedSessionId = session.id;
           _confettiController.play();
           
           // Only the GUESSER triggers auto-start (drawer waits for stream)
           final isGuesser = session.drawerId != userId;
           if (isGuesser) {
             Future.delayed(const Duration(seconds: 3), () {
               if (mounted) {
                 ref.read(drawingGameControllerProvider.notifier).startGame(
                   previousDrawerId: session.drawerId,
                 );
               }
             });
           }
        }
      }
    });

    // Listen for partner exit - session becomes null when cancelled
    ref.listen(activeDrawingSessionProvider, (previous, next) {
      final previousSession = previous?.valueOrNull;
      final currentSession = next.valueOrNull;
      
      // If we had an active session (not solved) and now it's gone, partner exited
      if (previousSession != null && 
          previousSession.status != 'solved' && 
          currentSession == null &&
          !next.isLoading) {
        _handlePartnerExit();
      }
    });

    return PopScope(
      canPop: false, // Handle manually
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onExit();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Draw & Guess', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(
            color: Colors.white, 
            onPressed: _onExit,
          ),
        ),
        body: Stack(
          children: [
            sessionAsync.when(
              data: (session) {
                if (session == null) {
                  _isCancellingStale = false;
                  _confettiController.stop();
                  
                  // Check if couple is loaded
                  final couple = coupleAsync.valueOrNull;
                  final isLoading = controllerState is AsyncLoading;
                  
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // DEBUG INFO - Remove after testing
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'DEBUG - CoupleID: ${couple?.id ?? "null"}',
                                style: const TextStyle(color: Colors.yellow, fontSize: 10),
                              ),
                              Text(
                                'UserID: ${userId ?? "null"}',
                                style: const TextStyle(color: Colors.yellow, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        if (couple == null)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Çift bilgisi yükleniyor...',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ElevatedButton.icon(
                          onPressed: (couple != null && !isLoading) 
                            ? () {
                                ref.read(drawingGameControllerProvider.notifier).startGame();
                              }
                            : null,
                          icon: isLoading 
                            ? const SizedBox(
                                width: 20, 
                                height: 20, 
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, 
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.brush, color: Colors.white),
                          label: Text(
                            isLoading ? 'Başlatılıyor...' : 'Start New Game', 
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // Stale Session Check
                // If the session was created before I entered this screen, it's stale.
                // Only if I am the drawer (owner).
                // Add 5 second tolerance for clock skew
                final staleThreshold = _entryTime.subtract(const Duration(seconds: 5));
                final isStale = session.drawerId == userId && session.createdAt.isBefore(staleThreshold);
                
                print('[DrawingGame] Stale check: drawerId=${session.drawerId}, myId=$userId, sessionCreatedAt=${session.createdAt}, entryTime=$_entryTime, isStale=$isStale');
                
                if (isStale) {
                  if (!_isCancellingStale) {
                    _isCancellingStale = true;
                    print('[DrawingGame] Cancelling stale session ${session.id}');
                    Future.microtask(() => 
                      ref.read(drawingGameControllerProvider.notifier).cancelSession(session.id)
                    );
                  }
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                
                if (session.status == 'solved') {
                  _timer?.cancel();
                  return _buildSolvedScreen(session);
                }
  
                final isDrawer = session.drawerId == userId;
                
                // PHASE 0: PENDING (Invitation)
                if (session.status == 'pending') {
                  _timer?.cancel();
                  if (isDrawer) {
                    return _buildWaitingForPartnerUI(session);
                  } else {
                    return _buildInvitationUI(session);
                  }
                }

                // PHASE 1: DRAWING
                if (session.status == 'drawing') {
                  if (isDrawer) {
                     // Ensure timer is running
                     if (_timer == null || !_timer!.isActive) _startTimer(session.id);
                     return _buildDrawerUI(session);
                  } else {
                     return _buildWaitingForDrawingUI(session);
                  }
                }
                
                // PHASE 2: GUESSING
                // Both can see the drawing now.
                // Drawer waits, Guesser inputs.
                _timer?.cancel(); // Ensure timer stopped
                if (isDrawer) {
                  return _buildDrawerWaitingForGuessUI(session);
                } else {
                  return _buildGuesserUI(session);
                }
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
            ),
            
            IgnorePointer(
              child: Align(
                 alignment: Alignment.topCenter,
                 child: ConfettiWidget(
                   confettiController: _confettiController,
                   blastDirectionality: BlastDirectionality.explosive,
                   shouldLoop: false,
                   colors: const [AppColors.primary, AppColors.secondary, AppColors.accent],
                 ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerUI(DrawingSession session) {
    if (_localPoints.isEmpty && session.points.isNotEmpty) {
         _localPoints = List.from(session.points);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Padding(
               padding: const EdgeInsets.all(16.0),
               child: Text('Draw: ${session.secretWord}', style: const TextStyle(color: AppColors.accent, fontSize: 20, fontWeight: FontWeight.bold)),
             ),
             Padding(
               padding: const EdgeInsets.all(16.0),
               child: Text('$_timeLeft s', style: const TextStyle(color: Colors.white, fontSize: 18)),
             ),
          ],
        ),
        
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onPanUpdate: (details) => _onPanUpdate(details, Size(constraints.maxWidth, constraints.maxHeight)),
                onPanEnd: (details) => _onPanEnd(details, session.id),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: AppColors.surface,
                  margin: const EdgeInsets.all(16),
                  child: ClipRect(
                    child: DrawingCanvas(points: _localPoints),
                  ),
                ),
              );
            },
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => _finishDrawing(session.id),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Done Drawing', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingForDrawingUI(DrawingSession session) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Partnerin Çiziyor... 🎨', 
            style: TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold)
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: ClipRect(
              child: DrawingCanvas(points: session.points),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Çizimin bitmesini bekle...', 
            style: TextStyle(color: AppColors.textSecondary)
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerWaitingForGuessUI(DrawingSession session) {
    return Column(
      children: [
        Container(
           padding: const EdgeInsets.all(16),
           child: const Text('Partnerin Tahmin Ediyor...', style: TextStyle(color: AppColors.accent, fontSize: 18)),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: ClipRect(child: DrawingCanvas(points: session.points)),
          ),
        ),
      ],
    );
  }

  Widget _buildGuesserUI(DrawingSession session) {
    return Column(
      children: [
         Container(
          padding: const EdgeInsets.all(16),
          child: const Text('Tahmin Et!', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.surface,
            margin: const EdgeInsets.all(16),
            child: ClipRect(
              child: DrawingCanvas(points: session.points),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _guessController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cevabın ne?',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _submitGuess(session.id),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _submitGuess(session.id),
                icon: const Icon(Icons.send, color: AppColors.primary),
                style: IconButton.styleFrom(backgroundColor: AppColors.background),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _submitGuess(String sessionId) async {
    final guess = _guessController.text.trim();
    if (guess.isEmpty) return;
    
    // Show Loading Feedback? State management for loading is better, but SnackBar works for now.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kontrol ediliyor...'), duration: Duration(milliseconds: 500)),
    );

    try {
      final success = await ref.read(drawingGameControllerProvider.notifier).submitGuess(sessionId, guess);
      
      if (success) {
        if (mounted) {
           _guessController.clear();
           _confettiController.play();
           ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Yanlış: "$guess". Tekrar dene!'), backgroundColor: AppColors.error),
           );
        }
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
         );
      }
    }
  }

  Widget _buildSolvedScreen(DrawingSession session) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text(
            'Tebrikler!',
            style: TextStyle(
              fontSize: 36, 
              fontWeight: FontWeight.bold, 
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Doğru Bildiniz!',
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.w500, 
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'Cevap',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  session.secretWord,
                  style: const TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pets, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  '+50 XP',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Auto-transition message instead of button
          OutlinedButton.icon(
            onPressed: () => context.go('/dashboard'),
            icon: const Icon(Icons.home, color: Colors.white70),
            label: const Text('Çıkış', style: TextStyle(color: Colors.white70)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '3 saniye içinde yeni oyuna geçiliyor...',
                  style: TextStyle(
                    fontSize: 14, 
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForPartnerUI(DrawingSession session) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          const Text('Partnerine davet gönderildi...', style: TextStyle(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 12),
          const Text('Kabul etmesi bekleniyor', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => ref.read(drawingGameControllerProvider.notifier).cancelSession(session.id),
            child: const Text('İptal Et', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationUI(DrawingSession session) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videogame_asset, size: 64, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text('Oyun Daveti!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Partnerin seninle Draw & Guess oynamak istiyor.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(drawingGameControllerProvider.notifier).cancelSession(session.id),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                    child: const Text('Reddet', style: TextStyle(color: AppColors.error)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ref.read(drawingGameControllerProvider.notifier).acceptSession(session.id),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Kabul Et', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
