import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/games/story_chain/domain/entities/story_chain_session.dart';
import 'package:heartbit/features/games/story_chain/presentation/providers/story_chain_provider.dart';

class StoryChainScreen extends ConsumerStatefulWidget {
  const StoryChainScreen({super.key});

  @override
  ConsumerState<StoryChainScreen> createState() => _StoryChainScreenState();
}

class _StoryChainScreenState extends ConsumerState<StoryChainScreen> {
  final TextEditingController _textController = TextEditingController();
  StoryMode _selectedMode = StoryMode.singleWord;

  bool _isLeaving = false;
  bool _canPopNow = false;
  bool _isRestarting = false;
  bool _hasSeenActiveSession = false;
  int _nullSessionDebounceToken = 0;
  String? _autoJoinAttemptSessionId;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _startWithMode(StoryMode mode) async {
    HapticFeedback.selectionClick();
    await ref.read(storyChainControllerProvider.notifier).enterGame(mode);
  }

  Future<void> _submitCurrentTurn() async {
    final rawText = _textController.text.trim();
    if (rawText.isEmpty) return;

    final error = await ref
        .read(storyChainControllerProvider.notifier)
        .submitTurn(rawText);

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
    _textController.clear();
  }

  Future<void> _passTurn() async {
    final error =
        await ref.read(storyChainControllerProvider.notifier).passTurn();

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

    _textController.clear();
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pas gecildi. Sira partnerine gecti.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _endGame() async {
    final error =
        await ref.read(storyChainControllerProvider.notifier).endGame();

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
  }

  Future<void> _handleExitAttempt() async {
    final session = ref.read(activeStoryChainSessionProvider).valueOrNull;

    if (session == null || session.status == StoryStatus.completed) {
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
          'Cikarsan aktif oyun kapanir ve ayni yerden devam etmez.',
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
    Navigator.of(context).pop();
  }

  void _forceLeave() {
    _isLeaving = true;
    unawaited(ref.read(storyChainControllerProvider.notifier).leaveGame());

    if (!mounted) return;
    setState(() => _canPopNow = true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(activeStoryChainSessionProvider);
    final userId = ref.watch(authUserIdProvider);
    final controllerState = ref.watch(storyChainControllerProvider);

    ref.listen(activeStoryChainSessionProvider, (previous, next) {
      final session = next.valueOrNull;

      if (session != null) {
        _hasSeenActiveSession = true;
        _nullSessionDebounceToken++;

        final shouldAutoJoin = session.status == StoryStatus.waiting &&
            userId != null &&
            !session.readyUsers.contains(userId) &&
            _autoJoinAttemptSessionId != session.id;
        if (shouldAutoJoin) {
          _autoJoinAttemptSessionId = session.id;
          unawaited(
            ref
                .read(storyChainControllerProvider.notifier)
                .enterGame(session.mode),
          );
        }

        if (session.status == StoryStatus.waiting && session.bothReady) {
          unawaited(
              ref.read(storyChainControllerProvider.notifier).startGame());
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
          final latest = ref.read(activeStoryChainSessionProvider);
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
            'Story Chain',
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

            if (session.status == StoryStatus.waiting) {
              return _buildWaitingRoom(session, userId);
            }
            if (session.status == StoryStatus.playing) {
              return _buildGameScreen(session, userId);
            }
            return _buildCompletedScreen(session, userId);
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
            'Partnerinle sirayla yazarak ortak hikaye olustur.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          _modeTile(
            mode: StoryMode.singleWord,
            title: 'Tek Kelime',
            subtitle: 'Her tur tam 1 kelime yazilir.',
            icon: Icons.short_text,
          ),
          const SizedBox(height: 10),
          _modeTile(
            mode: StoryMode.increasing,
            title: 'Artan',
            subtitle: 'Hedef her tur +1 artar, 10 kelimede sabitlenir.',
            icon: Icons.trending_up,
          ),
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
    required StoryMode mode,
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
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
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

  Widget _buildWaitingRoom(StoryChainSession session, String? userId) {
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
              child: const Icon(Icons.menu_book,
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
              _modeLabel(session.mode),
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

  Widget _buildGameScreen(StoryChainSession session, String? userId) {
    final isMyTurn = session.currentTurnUserId == userId;
    final requiredWords = session.requiredWordCount;
    final helperText = isMyTurn
        ? (requiredWords == 1
            ? 'Bu tur tam 1 kelime yaz.'
            : 'Bu tur tam $requiredWords kelime yaz.')
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
                      'Ilerleme: ${session.successfulTurnCount}/${session.maxTurns}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (session.successfulTurnCount / session.maxTurns)
                        .clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _infoChip(
                  title: 'Mod',
                  value: _modeLabel(session.mode),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoChip(
                  title: 'Hedef Kelime',
                  value: '$requiredWords',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoChip(
            title: 'Yardim',
            value: helperText,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hikaye Akisi (${session.turns.length})',
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
              child: session.turns.isEmpty
                  ? const Center(
                      child: Text(
                        'Ilk turu sen baslatabilirsin.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: session.turns.length,
                      itemBuilder: (context, index) {
                        final turn = session.turns[index];
                        final mine = turn.userId == userId;

                        return Align(
                          alignment: mine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
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
                            child: Column(
                              crossAxisAlignment: mine
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  turn.text,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${turn.wordCount} kelime',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            enabled: isMyTurn,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submitCurrentTurn(),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: helperText,
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isMyTurn ? _submitCurrentTurn : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.border,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Gonder',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: isMyTurn ? _passTurn : null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isMyTurn ? AppColors.primary : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: AppColors.primary,
                    ),
                    child: Text(
                      'Pas Gec',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isMyTurn
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _endGame,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text(
                      'Bitir',
                      style: TextStyle(fontWeight: FontWeight.w700),
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
      width: double.infinity,
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
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedScreen(StoryChainSession session, String? userId) {
    final isEndedByMe =
        session.endedByUserId != null && session.endedByUserId == userId;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 14),
          const Text(
            'Hikaye Tamamlandi',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _endReasonLabel(session.endReason, isEndedByMe),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
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
                _summaryRow('Mod', _modeLabel(session.mode)),
                _summaryRow(
                    'Tur Sayisi', session.successfulTurnCount.toString()),
                _summaryRow(
                    'Memory Kaydi', session.memorySaved ? 'Kaydedildi' : 'Bos'),
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
              child: SingleChildScrollView(
                child: Text(
                  session.storyText.isEmpty
                      ? 'Hikaye olusmadi.'
                      : session.storyText,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                          .read(storyChainControllerProvider.notifier)
                          .restartGame(session.mode);
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

  String _modeLabel(StoryMode mode) {
    switch (mode) {
      case StoryMode.singleWord:
        return 'Tek Kelime';
      case StoryMode.increasing:
        return 'Artan';
    }
  }

  String _endReasonLabel(String? reason, bool isEndedByMe) {
    switch (reason) {
      case 'max_turns':
        return '120 tura ulasildigi icin oyun otomatik tamamlandi.';
      case 'ended_by_user':
        return isEndedByMe
            ? 'Oyunu sen tamamladin.'
            : 'Partner oyunu tamamlandi olarak bitirdi.';
      case 'left':
        return 'Bir oyuncu oyundan ayrildi.';
      default:
        return 'Oyun tamamlandi.';
    }
  }
}
