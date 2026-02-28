import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/games/word_chain/domain/entities/word_chain_session.dart';
import 'package:heartbit/features/games/word_chain/presentation/providers/word_chain_provider.dart';

class WordChainScreen extends ConsumerStatefulWidget {
  const WordChainScreen({super.key});

  @override
  ConsumerState<WordChainScreen> createState() => _WordChainScreenState();
}

class _WordChainScreenState extends ConsumerState<WordChainScreen> {
  final TextEditingController _wordController = TextEditingController();
  WordChainMode _selectedMode = WordChainMode.lastLetter;
  String _selectedCategory = 'hayvanlar';

  Timer? _tickTimer;
  DateTime _now = DateTime.now();

  bool _isLeaving = false;
  bool _canPopNow = false;
  bool _isRestarting = false;
  bool _hasSeenActiveSession = false;
  int _nullSessionDebounceToken = 0;
  String? _timeoutHandledKey;
  String? _autoJoinAttemptSessionId;

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      _handleTurnTimeout();
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _wordController.dispose();
    super.dispose();
  }

  void _handleTurnTimeout() {
    final session = ref.read(activeWordChainSessionProvider).valueOrNull;
    if (session == null || session.status != WordChainStatus.playing) {
      _timeoutHandledKey = null;
      return;
    }

    final deadline = session.turnDeadline;
    if (deadline == null) return;

    if (_now.isBefore(deadline)) return;

    final timeoutKey = '${session.id}:${deadline.millisecondsSinceEpoch}';
    if (_timeoutHandledKey == timeoutKey) return;

    _timeoutHandledKey = timeoutKey;
    unawaited(
        ref.read(wordChainControllerProvider.notifier).timeoutCurrentTurn());
  }

  int _remainingSeconds(WordChainSession session) {
    final deadline = session.turnDeadline;
    if (deadline == null) return 0;
    final remainingMs = deadline.difference(_now).inMilliseconds;
    if (remainingMs <= 0) return 0;
    return (remainingMs / 1000).ceil();
  }

  double _remainingProgress(WordChainSession session) {
    final deadline = session.turnDeadline;
    if (deadline == null) return 0;

    final totalMs = Duration(seconds: session.turnSeconds).inMilliseconds;
    final remainingMs = deadline.difference(_now).inMilliseconds;
    if (remainingMs <= 0) return 0;
    if (remainingMs >= totalMs) return 1;
    return remainingMs / totalMs;
  }

  Future<void> _startWithMode(WordChainMode mode) async {
    HapticFeedback.selectionClick();
    final category = mode == WordChainMode.category ? _selectedCategory : null;
    await ref
        .read(wordChainControllerProvider.notifier)
        .enterGame(mode, category: category);
  }

  Future<void> _submitCurrentWord() async {
    final rawWord = _wordController.text.trim();
    if (rawWord.isEmpty) return;

    final error = await ref
        .read(wordChainControllerProvider.notifier)
        .submitWord(rawWord);

    if (!mounted) return;

    if (error != null) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    _wordController.clear();
  }

  Future<void> _useJoker() async {
    final error =
        await ref.read(wordChainControllerProvider.notifier).useJoker();
    if (!mounted) return;

    if (error != null) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _wordController.clear();
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Joker kullanildi. Sira partnerine gecti.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _handleExitAttempt() async {
    final session = ref.read(activeWordChainSessionProvider).valueOrNull;

    if (session == null || session.status == WordChainStatus.gameover) {
      _forceLeave();
      return;
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Oyundan ayril?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Cikarsan oyun ikiniz icin de bitecek.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Vazgec',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Ayril',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (shouldLeave == true) {
      _forceLeave();
    }
  }

  void _handlePartnerSessionGone() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Partner oyundan ayrildi.'),
        backgroundColor: AppColors.error,
      ),
    );
    context.pop();
  }

  void _forceLeave() {
    _isLeaving = true;
    unawaited(ref.read(wordChainControllerProvider.notifier).leaveGame());

    if (!mounted) return;
    setState(() => _canPopNow = true);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(activeWordChainSessionProvider);
    final userId = ref.watch(authUserIdProvider);
    final controllerState = ref.watch(wordChainControllerProvider);

    ref.listen(activeWordChainSessionProvider, (previous, next) {
      final session = next.valueOrNull;

      if (session != null) {
        _hasSeenActiveSession = true;
        _nullSessionDebounceToken++;

        final shouldAutoJoin = session.status == WordChainStatus.waiting &&
            userId != null &&
            !session.readyUsers.contains(userId) &&
            _autoJoinAttemptSessionId != session.id;
        if (shouldAutoJoin) {
          _autoJoinAttemptSessionId = session.id;
          unawaited(
            ref.read(wordChainControllerProvider.notifier).enterGame(
                  session.mode,
                  category: session.category,
                ),
          );
        }

        if (session.status == WordChainStatus.waiting && session.bothReady) {
          unawaited(ref.read(wordChainControllerProvider.notifier).startGame());
        }
      }

      if (previous?.valueOrNull != null &&
          next.valueOrNull == null &&
          !next.isLoading &&
          !next.hasError &&
          !_isLeaving &&
          !_isRestarting &&
          _hasSeenActiveSession) {
        final token = ++_nullSessionDebounceToken;
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted || token != _nullSessionDebounceToken) return;
          final latest = ref.read(activeWordChainSessionProvider);
          final stillNull = latest.valueOrNull == null &&
              !latest.isLoading &&
              !latest.hasError &&
              !_isLeaving &&
              !_isRestarting;
          if (!stillNull) return;
          _handlePartnerSessionGone();
        });
      }

      if (_isRestarting && session != null) {
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
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text(
            'Word Chain',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: sessionAsync.when(
          data: (session) {
            if (session == null) {
              if (controllerState is AsyncLoading<void>) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              return _buildModeSelect();
            }

            if (session.status == WordChainStatus.waiting) {
              return _buildWaitingRoom(session, userId);
            }
            if (session.status == WordChainStatus.playing) {
              return _buildGameScreen(session, userId);
            }
            return _buildGameOver(session, userId);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 44),
                  const SizedBox(height: 12),
                  Text(
                    'Hata: $error',
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelect() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mod sec',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Partnerinle kelime zinciri kur.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          _modeTile(
            mode: WordChainMode.lastLetter,
            title: 'Son Harf',
            subtitle: '5/10 kelimede son 2-3 harfe zorlasir.',
            icon: Icons.text_fields,
          ),
          const SizedBox(height: 10),
          _modeTile(
            mode: WordChainMode.category,
            title: 'Kategori',
            subtitle: 'Ayni kategoriden tekrar olmadan yaz.',
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 10),
          _modeTile(
            mode: WordChainMode.free,
            title: 'Serbest',
            subtitle: 'Serbest akista kademe kademe zorlasir.',
            icon: Icons.auto_awesome,
          ),
          if (_selectedMode == WordChainMode.category) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                        value: 'hayvanlar', child: Text('Hayvanlar')),
                    DropdownMenuItem(
                        value: 'yiyecekler', child: Text('Yiyecekler')),
                    DropdownMenuItem(
                        value: 'sehirler', child: Text('Sehirler')),
                    DropdownMenuItem(value: 'filmler', child: Text('Filmler')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedCategory = value);
                  },
                ),
              ),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => _startWithMode(_selectedMode),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Oyunu Baslat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeTile({
    required WordChainMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _selectedMode == mode;
    return InkWell(
      onTap: () => setState(() => _selectedMode = mode),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.10)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingRoom(WordChainSession session, String? userId) {
    final meReady = userId != null && session.readyUsers.contains(userId);
    final partnerReady = session.readyUsers.length > 1;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: const Icon(Icons.hourglass_top,
                  color: AppColors.primary, size: 42),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bekleme Odasi',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _modeLabel(session.mode, session.category),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            _statusTile('Sen', meReady),
            const SizedBox(height: 8),
            _statusTile('Partner', partnerReady),
            const SizedBox(height: 18),
            Text(
              partnerReady ? 'Baslatiliyor...' : 'Partner bekleniyor...',
              style: TextStyle(
                color:
                    partnerReady ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTile(String label, bool ready) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ready ? AppColors.success : AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            ready ? Icons.check_circle : Icons.watch_later_outlined,
            color: ready ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            ready ? 'Hazir' : 'Bekliyor',
            style: TextStyle(
              color: ready ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen(WordChainSession session, String? userId) {
    final isMyTurn = session.currentTurnUserId == userId;
    final expectedPrefix = session.expectedPrefix;
    final secondsLeft = _remainingSeconds(session);
    final progress = _remainingProgress(session);
    final isCritical = secondsLeft <= 5;
    final myJokers =
        userId == null ? 0 : (session.jokersRemaining[userId] ?? 0);
    final partnerId = userId == null ? null : session.partnerOf(userId);
    final partnerJokers =
        partnerId == null ? 0 : (session.jokersRemaining[partnerId] ?? 0);
    final requiredSuffixLength = session.requiredSuffixLength;

    final ruleText = requiredSuffixLength <= 1
        ? 'Son 1 harf'
        : 'Son $requiredSuffixLength harf';
    final inputHint = isMyTurn
        ? (expectedPrefix == null
            ? 'Kelime yaz...'
            : 'Kelime "$expectedPrefix" ile baslamali')
        : 'Sira partnerinde...';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      isMyTurn ? 'Sira sende' : 'Partnerin sirasi',
                      style: TextStyle(
                        color: isMyTurn
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$secondsLeft sn / ${session.turnSeconds} sn',
                      style: TextStyle(
                        color: isCritical
                            ? AppColors.error
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCritical ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _infoChip(
                  title: 'Mod',
                  value: _modeLabel(session.mode, session.category),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoChip(
                  title: 'Kademe',
                  value: '${session.currentStage}/3',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _infoChip(
                  title: 'Kural',
                  value: ruleText,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoChip(
                  title: 'Beklenen Baslangic',
                  value: expectedPrefix ?? '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoChip(
            title: 'Joker',
            value: 'Sen: $myJokers | Partner: $partnerJokers',
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Zincir (${session.words.length})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: session.words.isEmpty
                  ? const Center(
                      child: Text(
                        'Ilk kelimeyi yazan kazanir.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: session.words.length,
                      itemBuilder: (context, index) {
                        final item =
                            session.words[session.words.length - 1 - index];
                        final mine = item.userId == userId;

                        return Align(
                          alignment: mine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: mine
                                  ? AppColors.primary.withOpacity(0.14)
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    mine ? AppColors.primary : AppColors.border,
                              ),
                            ),
                            child: Text(
                              item.word,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _wordController,
                  enabled: isMyTurn,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitCurrentWord(),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: inputHint,
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 52,
                height: 52,
                child: ElevatedButton(
                  onPressed: isMyTurn ? _submitCurrentWord : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.border,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 86,
                height: 52,
                child: OutlinedButton(
                  onPressed: isMyTurn && myJokers > 0 ? _useJoker : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isMyTurn && myJokers > 0
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: AppColors.primary,
                  ),
                  child: Text(
                    'Joker $myJokers',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isMyTurn && myJokers > 0
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver(WordChainSession session, String? userId) {
    final isWinner =
        session.winnerUserId != null && session.winnerUserId == userId;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 14),
          Text(
            isWinner ? 'Kazandin' : 'Oyun Bitti',
            style: TextStyle(
              color: isWinner ? AppColors.success : AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _gameOverReason(session.loserReason),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _summaryRow('Mod', _modeLabel(session.mode, session.category)),
                _summaryRow('Toplam Kelime', session.words.length.toString()),
                _summaryRow(
                  'Kazanan',
                  session.winnerUserId == null
                      ? '-'
                      : (isWinner ? 'Sen' : 'Partner'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.builder(
                itemCount: session.words.length,
                itemBuilder: (context, index) {
                  final item = session.words[index];
                  final mine = item.userId == userId;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '${index + 1}. ${item.word}${mine ? ' (sen)' : ''}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _forceLeave,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cik',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      _isRestarting = true;
                      await ref
                          .read(wordChainControllerProvider.notifier)
                          .restartGame(session.mode,
                              category: session.category);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tekrar Oyna',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _modeLabel(WordChainMode mode, String? category) {
    switch (mode) {
      case WordChainMode.lastLetter:
        return 'Son Harf';
      case WordChainMode.category:
        return category == null || category.isEmpty
            ? 'Kategori'
            : 'Kategori: $category';
      case WordChainMode.free:
        return 'Serbest';
    }
  }

  String _gameOverReason(String? reason) {
    switch (reason) {
      case 'timeout':
        return 'Sure doldugu icin oyun bitti.';
      case 'invalid_word':
        return 'Kurala uymayan kelime nedeniyle oyun bitti.';
      case 'left':
        return 'Bir oyuncu oyundan ayrildi.';
      default:
        return 'Oyun tamamlandi.';
    }
  }
}
