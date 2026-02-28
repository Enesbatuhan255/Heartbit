import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/games/emoji_game/domain/entities/emoji_game_session.dart';
import 'package:heartbit/features/games/emoji_game/presentation/providers/emoji_game_provider.dart';

/// Emoji Tahmin Game Screen
///
/// One partner describes a secret word using emojis,
/// the other partner tries to guess it.
class EmojiGameScreen extends ConsumerStatefulWidget {
  const EmojiGameScreen({super.key});

  @override
  ConsumerState<EmojiGameScreen> createState() => _EmojiGameScreenState();
}

class _EmojiGameScreenState extends ConsumerState<EmojiGameScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emojiController = TextEditingController();
  final TextEditingController _guessController = TextEditingController();
  bool _isLeaving = false;
  bool _canPopNow = false;
  bool _isRestarting = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rebuild when text changes so send/guess buttons enable correctly
    _emojiController.addListener(() => setState(() {}));
    _guessController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emojiGameControllerProvider.notifier).enterGame();
    });
  }

  @override
  void dispose() {
    _emojiController.dispose();
    _guessController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleExitAttempt() async {
    final session = ref.read(activeEmojiGameSessionProvider).valueOrNull;

    if (session == null || session.status == 'gameover') {
      _forceLeave();
      return;
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Oyundan Ayrıl?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Çıkarsan oyun ikiniz için de biter.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
                const Text('Ayrıl', style: TextStyle(color: AppColors.error)),
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
    ref.read(emojiGameControllerProvider.notifier).leaveGame();

    if (mounted) {
      setState(() => _canPopNow = true);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(activeEmojiGameSessionProvider);
    final userId = ref.watch(authUserIdProvider);

    // Listen for session changes
    ref.listen(activeEmojiGameSessionProvider, (prev, next) {
      final session = next.valueOrNull;

      if (session != null) {
        // Auto-start when both ready
        if (session.status == 'waiting' && session.bothReady) {
          ref.read(emojiGameControllerProvider.notifier).startGame();
        }
      }

      // If session was cancelled by partner
      if (prev?.valueOrNull != null &&
          next.valueOrNull == null &&
          !next.isLoading &&
          !next.hasError &&
          !_isLeaving &&
          !_isRestarting) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isLeaving && !_isRestarting) {
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

      if (_isRestarting && next.valueOrNull != null) {
        _isRestarting = false;
      }
    });

    return PopScope(
      canPop: _canPopNow,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleExitAttempt();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppColors.textPrimary),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text(
            'Emoji Tahmin',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: sessionAsync.when(
          data: (session) {
            if (session == null) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text('Oyun hazırlanıyor...',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }

            switch (session.status) {
              case 'waiting':
                return _buildWaitingRoom(session, userId);
              case 'sending':
                return _buildSendingPhase(session, userId);
              case 'guessing':
                return _buildGuessingPhase(session, userId);
              case 'roundEnd':
                return _buildRoundEnd(session, userId);
              case 'gameover':
                return _buildGameOver(session);
              default:
                return const Center(
                    child: Text('Bilinmeyen durum',
                        style: TextStyle(color: AppColors.textSecondary)));
            }
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
                Text('Hata: $e',
                    style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(emojiGameControllerProvider.notifier).enterGame(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tekrar Dene',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== WAITING ROOM ====================
  Widget _buildWaitingRoom(EmojiGameSession session, String? userId) {
    final isUserReady = session.readyUsers.contains(userId);
    final partnerReady = session.readyUsers.length > 1;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated emoji icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                );
              },
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
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🧩', style: TextStyle(fontSize: 48)),
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
            const SizedBox(height: 8),
            const Text(
              'Partnerini bekliyorsun...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // Status container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildPlayerStatus('Sen', isUserReady, Icons.person),
                  const SizedBox(height: 12),
                  _buildPlayerStatus(
                      'Partner', partnerReady, Icons.favorite),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              partnerReady ? 'Oyun başlıyor!' : 'Partner bekleniyor...',
              style: TextStyle(
                fontSize: 14,
                color:
                    partnerReady ? AppColors.accent : AppColors.textSecondary,
                fontWeight:
                    partnerReady ? FontWeight.bold : FontWeight.normal,
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ready
                ? AppColors.accent.withOpacity(0.2)
                : AppColors.surface,
            border: Border.all(
              color: ready ? AppColors.accent : AppColors.border,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: ready ? AppColors.accent : AppColors.textSecondary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  ready ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ready
                ? AppColors.accent.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ready ? AppColors.accent : AppColors.border,
            ),
          ),
          child: Text(
            ready ? 'Hazır ✓' : 'Bekleniyor...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ready ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== SENDING PHASE ====================
  Widget _buildSendingPhase(EmojiGameSession session, String? userId) {
    final isSender = session.senderId == userId;

    if (isSender) {
      return _buildSenderView(session);
    } else {
      return _buildWaitingForEmojis(session);
    }
  }

  Widget _buildSenderView(EmojiGameSession session) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Round indicator
          _buildRoundIndicator(session),
          const SizedBox(height: 24),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B6B).withOpacity(0.3),
                  const Color(0xFFFF8E53).withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('✏️', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  'Sen Anlatıyorsun',
                  style: TextStyle(
                    color: Color(0xFFFF8E53),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Secret word card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFFFF5EE)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Gizli Kelime',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  session.secretWord,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bu kelimeyi emojilerle anlat!',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Emoji input
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _emojiController,
              style: const TextStyle(fontSize: 32, color: Colors.white),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '🎬🍕🌙...',
                hintStyle: TextStyle(
                  fontSize: 32,
                  color: AppColors.textSecondary.withOpacity(0.4),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
              maxLines: 2,
              minLines: 1,
            ),
          ),
          const Spacer(),
          // Send button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _emojiController.text.trim().isEmpty
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(emojiGameControllerProvider.notifier)
                          .sendEmojis(_emojiController.text.trim());
                      _emojiController.clear();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Gönder 🚀',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Skip button
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(emojiGameControllerProvider.notifier).skipRound();
            },
            child: const Text(
              'Bu turu geç',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForEmojis(EmojiGameSession session) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoundIndicator(session),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                );
              },
              child: const Text('🤔', style: TextStyle(fontSize: 80)),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4D96FF).withOpacity(0.3),
                    const Color(0xFF6BCB77).withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF4D96FF).withOpacity(0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🔍', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Sen Tahmin Edeceksin',
                    style: TextStyle(
                      color: Color(0xFF4D96FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Partnerin emojileri hazırlıyor...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== GUESSING PHASE ====================
  Widget _buildGuessingPhase(EmojiGameSession session, String? userId) {
    final isGuesser = session.guesserId == userId;

    if (isGuesser) {
      return _buildGuesserView(session);
    } else {
      return _buildWaitingForGuess(session);
    }
  }

  Widget _buildGuesserView(EmojiGameSession session) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildRoundIndicator(session),
          const SizedBox(height: 24),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4D96FF).withOpacity(0.3),
                  const Color(0xFF6BCB77).withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF4D96FF).withOpacity(0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🔍', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  'Sen Tahmin Ediyorsun',
                  style: TextStyle(
                    color: Color(0xFF4D96FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Emoji display card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFFFF5EE)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Partnerinin İpucu',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  session.emojis,
                  style: const TextStyle(fontSize: 48),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Previous guesses
          if (session.guesses.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: session.guesses.map((g) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(
                    '❌ $g',
                    style: TextStyle(
                      color: AppColors.error.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          const Spacer(),
          // Guess input
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _guessController,
              style: const TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Tahminin...',
                hintStyle: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary.withOpacity(0.4),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onSubmitted: (_) => _submitGuess(),
            ),
          ),
          const SizedBox(height: 12),
          // Submit guess button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _guessController.text.trim().isEmpty
                  ? null
                  : _submitGuess,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D96FF),
                disabledBackgroundColor:
                    const Color(0xFF4D96FF).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Tahmin Et 💡',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitGuess() async {
    final guess = _guessController.text.trim();
    if (guess.isEmpty) return;

    HapticFeedback.mediumImpact();
    _guessController.clear();

    final correct =
        await ref.read(emojiGameControllerProvider.notifier).submitGuess(guess);

    if (correct && mounted) {
      HapticFeedback.heavyImpact();
    }
  }

  Widget _buildWaitingForGuess(EmojiGameSession session) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoundIndicator(session),
            const SizedBox(height: 32),
            // Show the emojis that were sent
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFFFF5EE)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Text(
                    'Senin Emojilerin',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session.emojis,
                    style: const TextStyle(fontSize: 48),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kelime: ${session.secretWord}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Show partner's guesses
            if (session.guesses.isNotEmpty) ...[
              const Text(
                'Partnerinin Tahminleri',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: session.guesses.map((g) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '❌ $g',
                      style: TextStyle(
                        color: AppColors.error.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                );
              },
              child: const Text('🤞', style: TextStyle(fontSize: 60)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Partnerin tahmin ediyor...',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ROUND END ====================
  Widget _buildRoundEnd(EmojiGameSession session, String? userId) {
    final isCorrect = session.lastRoundCorrect ?? false;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoundIndicator(session),
            const SizedBox(height: 40),
            // Result icon
            Text(
              isCorrect ? '🎉' : '😅',
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 16),
            Text(
              isCorrect ? 'Doğru Tahmin!' : 'Bu Tur Geçildi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isCorrect ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            // Show the word
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Text(
                    'Kelime:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.secretWord,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (session.emojis.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      session.emojis,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Score
            Text(
              'Skor: ${session.score} / ${session.round}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            // Next round or Game Over button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(emojiGameControllerProvider.notifier).nextRound();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  session.round >= session.maxRounds
                      ? 'Sonuçları Gör'
                      : 'Sonraki Tur ▶',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== GAME OVER ====================
  Widget _buildGameOver(EmojiGameSession session) {
    final percentage = session.maxRounds > 0
        ? (session.score / session.maxRounds * 100).round()
        : 0;

    String emoji;
    String message;
    if (percentage >= 80) {
      emoji = '🏆';
      message = 'Mükemmel uyum!';
    } else if (percentage >= 60) {
      emoji = '🌟';
      message = 'Harika ikiniz!';
    } else if (percentage >= 40) {
      emoji = '💪';
      message = 'Fena değil!';
    } else {
      emoji = '😄';
      message = 'Pratik yapın!';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            const Text(
              'Oyun Bitti!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            // Score card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFFFF5EE)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Text(
                    'Final Skor',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${session.score} / ${session.maxRounds}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '%$percentage başarı',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        _forceLeave();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Çık',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _isRestarting = true;
                        ref
                            .read(emojiGameControllerProvider.notifier)
                            .restartGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Tekrar Oyna',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SHARED WIDGETS ====================
  Widget _buildRoundIndicator(EmojiGameSession session) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(session.maxRounds, (index) {
        final isCurrent = index == session.round - 1;
        final isPast = index < session.round - 1;

        return Container(
          width: isCurrent ? 32 : 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: isCurrent
                ? AppColors.primary
                : isPast
                    ? AppColors.accent
                    : AppColors.surface,
            border: Border.all(
              color: isCurrent
                  ? AppColors.primary
                  : isPast
                      ? AppColors.accent
                      : AppColors.border,
            ),
          ),
        );
      }),
    );
  }
}
