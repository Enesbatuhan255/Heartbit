import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/games/rhythm_copy/domain/entities/rhythm_copy_session.dart';
import 'package:heartbit/features/games/rhythm_copy/presentation/providers/rhythm_copy_provider.dart';

class RhythmCopyScreen extends ConsumerStatefulWidget {
  const RhythmCopyScreen({super.key});

  @override
  ConsumerState<RhythmCopyScreen> createState() => _RhythmCopyScreenState();
}

class _RhythmCopyScreenState extends ConsumerState<RhythmCopyScreen> {
  final List<_TimedTap> _patternDraft = <_TimedTap>[];
  final List<_TimedTap> _copyDraft = <_TimedTap>[];

  DateTime? _patternStartedAt;
  DateTime? _copyStartedAt;
  bool _isPlayingPattern = false;
  bool _audioAvailable = true;
  bool _audioWarningShown = false;

  final Map<int, AudioPlayer> _padPlayers = <int, AudioPlayer>{};
  final Map<int, String> _padAudioPaths = <int, String>{};

  @override
  void initState() {
    super.initState();
    unawaited(_initPadAudio());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rhythmCopyControllerProvider.notifier).enterGame();
    });
  }

  @override
  void dispose() {
    for (final player in _padPlayers.values) {
      player.dispose();
    }
    // Clean up temp audio files
    for (final path in _padAudioPaths.values) {
      try {
        File(path).deleteSync();
      } catch (_) {}
    }
    super.dispose();
  }

  Future<void> _leaveAndPop() async {
    await ref.read(rhythmCopyControllerProvider.notifier).leaveGame();
    if (!mounted) return;
    context.pop();
  }

  Future<void> _initPadAudio() async {
    // Pentatonic-friendly frequencies for pleasant, distinguishable tones
    const frequencies = <int, int>{
      1: 330,  // E4
      2: 392,  // G4
      3: 494,  // B4
      4: 587,  // D5
    };

    try {
      // Generate WAV files and save to temp directory for reliable playback
      final tempDir = Directory.systemTemp;
      for (final entry in frequencies.entries) {
        final pad = entry.key;
        final frequency = entry.value;
        final wavBytes = _buildMusicalWav(
          frequencyHz: frequency,
          durationMs: 280,
        );

        final file = File('${tempDir.path}/rhythm_pad_$pad.wav');
        await file.writeAsBytes(wavBytes, flush: true);
        _padAudioPaths[pad] = file.path;

        final player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.stop);
        _padPlayers[pad] = player;
      }
    } on MissingPluginException catch (_) {
      _audioAvailable = false;
      await _showAudioWarning();
    } on PlatformException catch (_) {
      _audioAvailable = false;
      await _showAudioWarning();
    } catch (_) {
      _audioAvailable = false;
      await _showAudioWarning();
    }
  }

  Future<void> _showAudioWarning() async {
    if (!mounted || _audioWarningShown) return;
    _audioWarningShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Ses motoru başlatılamadı. Oyun sessiz modda devam edecek.'),
      ),
    );
  }

  /// Builds a musical-sounding WAV with ADSR envelope and harmonics
  Uint8List _buildMusicalWav({
    required int frequencyHz,
    required int durationMs,
    int sampleRate = 44100,
  }) {
    final samples = (sampleRate * durationMs / 1000).round();
    final dataSize = samples * 2;
    final byteData = ByteData(44 + dataSize);

    void writeString(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        byteData.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    // WAV header
    writeString(0, 'RIFF');
    byteData.setUint32(4, 36 + dataSize, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    byteData.setUint32(16, 16, Endian.little);     // PCM
    byteData.setUint16(20, 1, Endian.little);       // Audio format
    byteData.setUint16(22, 1, Endian.little);       // Mono
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * 2, Endian.little);
    byteData.setUint16(32, 2, Endian.little);       // Block align
    byteData.setUint16(34, 16, Endian.little);      // Bits per sample
    writeString(36, 'data');
    byteData.setUint32(40, dataSize, Endian.little);

    // ADSR envelope parameters (in seconds)
    const attackTime = 0.008;   // 8ms attack
    const decayTime = 0.04;     // 40ms decay
    const sustainLevel = 0.7;
    final releaseStart = (durationMs / 1000.0) - 0.08; // last 80ms for release

    for (var i = 0; i < samples; i++) {
      final t = i / sampleRate;

      // Fundamental + harmonics for richer tone
      final fundamental = math.sin(2 * math.pi * frequencyHz * t);
      final harmonic2 = math.sin(2 * math.pi * frequencyHz * 2 * t) * 0.3;
      final harmonic3 = math.sin(2 * math.pi * frequencyHz * 3 * t) * 0.1;
      final raw = fundamental + harmonic2 + harmonic3;

      // ADSR envelope
      double envelope;
      if (t < attackTime) {
        envelope = t / attackTime; // Attack: ramp up
      } else if (t < attackTime + decayTime) {
        final decayProgress = (t - attackTime) / decayTime;
        envelope = 1.0 - (1.0 - sustainLevel) * decayProgress; // Decay
      } else if (t < releaseStart) {
        envelope = sustainLevel; // Sustain
      } else {
        final releaseProgress = (t - releaseStart) / 0.08;
        envelope = sustainLevel * (1.0 - releaseProgress.clamp(0.0, 1.0)); // Release
      }

      final sample = raw * envelope * 0.45; // Overall volume
      final pcm = (sample * 32767).round().clamp(-32768, 32767);
      byteData.setInt16(44 + (i * 2), pcm, Endian.little);
    }

    return byteData.buffer.asUint8List();
  }

  Future<void> _playPadSound(int value) async {
    if (!_audioAvailable) return;

    final player = _padPlayers[value];
    final path = _padAudioPaths[value];
    if (player == null || path == null) return;

    try {
      await player.stop();
      await player.play(DeviceFileSource(path), volume: 1.0);
    } on MissingPluginException catch (_) {
      _audioAvailable = false;
      await _showAudioWarning();
    } on PlatformException catch (_) {
      _audioAvailable = false;
      await _showAudioWarning();
    } catch (_) {
      _audioAvailable = false;
      await _showAudioWarning();
    }
  }

  Future<void> _playPatternWithTiming(
      List<int> values, List<int> timingsMs) async {
    if (_isPlayingPattern || values.isEmpty) return;

    final safeTimings = timingsMs.length == values.length
        ? timingsMs
        : List<int>.generate(values.length, (index) => index * 400);

    setState(() => _isPlayingPattern = true);
    try {
      for (var i = 0; i < values.length; i++) {
        if (i > 0) {
          final delta = (safeTimings[i] - safeTimings[i - 1]).clamp(40, 1200);
          await Future.delayed(Duration(milliseconds: delta));
        }
        await _playPadSound(values[i]);
      }
    } finally {
      if (mounted) {
        setState(() => _isPlayingPattern = false);
      }
    }
  }

  void _onPatternPadTap(int value) {
    if (_patternDraft.length >= 8) return;
    unawaited(_playPadSound(value));

    final now = DateTime.now();
    _patternStartedAt ??= now;
    final elapsed = now.difference(_patternStartedAt!).inMilliseconds;
    setState(() {
      _patternDraft.add(_TimedTap(value: value, elapsedMs: elapsed));
    });
  }

  void _onCopyPadTap(int value, int maxAllowed) {
    if (_copyDraft.length >= maxAllowed) return;
    unawaited(_playPadSound(value));

    final now = DateTime.now();
    _copyStartedAt ??= now;
    final elapsed = now.difference(_copyStartedAt!).inMilliseconds;
    setState(() {
      _copyDraft.add(_TimedTap(value: value, elapsedMs: elapsed));
    });
  }

  List<int> _valuesFrom(List<_TimedTap> taps) =>
      taps.map((tap) => tap.value).toList(growable: false);

  List<int> _timingsFrom(List<_TimedTap> taps) =>
      taps.map((tap) => tap.elapsedMs).toList(growable: false);

  void _clearPatternDraft() {
    setState(() {
      _patternDraft.clear();
      _patternStartedAt = null;
    });
  }

  void _clearCopyDraft() {
    setState(() {
      _copyDraft.clear();
      _copyStartedAt = null;
    });
  }

  Widget _buildSessionBody(RhythmCopySession session, String userId) {
    Widget child;
    if (session.status == 'waiting') {
      child = _buildWaitingState(session);
    } else if (session.status == 'composing') {
      child = _buildComposingState(session, userId);
    } else if (session.status == 'copying') {
      child = _buildCopyingState(session, userId);
    } else if (session.status == 'roundEnd') {
      child = _buildRoundEndState(session, userId);
    } else if (session.status == 'gameover') {
      child = _buildGameOverState(session, userId);
    } else {
      child = const Center(
      child: Text(
          'Session is not active.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(rhythmCopyControllerProvider,
        (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rhythm Copy error: ${next.error}')),
        );
      }
    });

    final sessionAsync = ref.watch(activeRhythmCopySessionProvider);
    final userId = ref.watch(authUserIdProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _leaveAndPop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF6F0),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFDF6F0),
          title: const Text('Rhythm Copy'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: _leaveAndPop,
          ),
        ),
        body: sessionAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Failed to load game session.\n$error',
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (session) {
            if (session == null || userId == null) {
              return Center(
                child: ElevatedButton(
                  onPressed: () => ref
                      .read(rhythmCopyControllerProvider.notifier)
                      .enterGame(),
                  child: const Text('Join Game'),
                ),
              );
            }
            return _buildSessionBody(session, userId);
          },
        ),
      ),
    );
  }

  Widget _buildWaitingState(RhythmCopySession session) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Waiting Room',
            style: TextStyle(
                color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            'Ready players: ${session.readyUsers.length}/2',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: session.bothReady
                ? () =>
                    ref.read(rhythmCopyControllerProvider.notifier).startGame()
                : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _leaveAndPop,
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Widget _buildComposingState(RhythmCopySession session, String userId) {
    final isComposer = session.composerId == userId;
    final patternValues = _valuesFrom(_patternDraft);
    final patternTimings = _timingsFrom(_patternDraft);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Round ${session.round}/${session.maxRounds}',
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildScores(session, userId),
          const SizedBox(height: 16),
          if (!isComposer)
            const Text(
              'Partner is creating a rhythm pattern...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            )
          else ...[
            const Text(
              'Create a rhythm pattern (3 to 8 taps).',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Each pad has a different sound. Keep your rhythm intentional.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            _buildPatternPreview(patternValues),
            const SizedBox(height: 12),
            _buildPads(onTap: _onPatternPadTap),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        patternValues.isEmpty ? null : _clearPatternDraft,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: patternValues.length < 3
                        ? null
                        : () async {
                            await ref
                                .read(rhythmCopyControllerProvider.notifier)
                                .submitPattern(
                                  patternValues,
                                  patternTimings,
                                );
                            if (!mounted) return;
                            _clearPatternDraft();
                          },
                    child: const Text('Send Pattern'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCopyingState(RhythmCopySession session, String userId) {
    final isCopyUser = session.copyUserId == userId;
    final copyValues = _valuesFrom(_copyDraft);
    final copyTimings = _timingsFrom(_copyDraft);
    final maxAllowed = session.pattern.length + 2;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Round ${session.round}/${session.maxRounds}',
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildScores(session, userId),
          const SizedBox(height: 16),
          if (!isCopyUser)
            const Text(
              'Partner is copying your rhythm...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            )
          else ...[
            const Text(
              'Copy this pattern with the same rhythm:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildPatternPreview(session.pattern),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _isPlayingPattern
                  ? null
                  : () => _playPatternWithTiming(
                        session.pattern,
                        session.patternTimingsMs,
                      ),
              icon: const Icon(Icons.volume_up_rounded),
              label: Text(_isPlayingPattern ? 'Playing...' : 'Play Pattern'),
            ),
            const SizedBox(height: 14),
            const Text(
              'Your input:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildPatternPreview(copyValues),
            const SizedBox(height: 12),
            _buildPads(
              onTap: (value) => _onCopyPadTap(value, maxAllowed),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: copyValues.isEmpty ? null : _clearCopyDraft,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: copyValues.isEmpty
                        ? null
                        : () async {
                            await ref
                                .read(rhythmCopyControllerProvider.notifier)
                                .submitCopy(
                                  copyValues,
                                  copyTimings,
                                );
                            if (!mounted) return;
                            _clearCopyDraft();
                          },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoundEndState(RhythmCopySession session, String userId) {
    final winnerLabel = session.lastRoundWinnerId == null
        ? 'No winner this round'
        : session.lastRoundWinnerId == userId
            ? 'You won this round'
            : 'Partner won this round';

    final accuracyPercent = session.lastAccuracy == null
        ? '-'
        : '${(session.lastAccuracy! * 100).round()}%';
    final noteAccuracyPercent = session.lastNoteAccuracy == null
        ? '-'
        : '${(session.lastNoteAccuracy! * 100).round()}%';
    final timingAccuracyPercent = session.lastTimingAccuracy == null
        ? '-'
        : '${(session.lastTimingAccuracy! * 100).round()}%';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Round Complete',
            style: TextStyle(
                color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildScores(session, userId),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Accuracy: $accuracyPercent',
                    style: const TextStyle(color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text('Notes: $noteAccuracyPercent',
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Text('Rhythm Timing: $timingAccuracyPercent',
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Text(
                  'Response: ${session.lastResponseMs ?? '-'} ms',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(winnerLabel, style: const TextStyle(color: AppColors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () =>
                ref.read(rhythmCopyControllerProvider.notifier).nextRound(),
            child: Text(session.round >= session.maxRounds
                ? 'Show Result'
                : 'Next Round'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverState(RhythmCopySession session, String userId) {
    final partnerId = session.partnerOf(userId);
    final myScore = session.scoreOf(userId);
    final partnerScore = partnerId == null ? 0 : session.scoreOf(partnerId);
    final resultLabel = myScore == partnerScore
        ? 'Draw'
        : (myScore > partnerScore ? 'You win' : 'Partner wins');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Game Over',
            style: TextStyle(
                color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            resultLabel,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildScores(session, userId),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                ref.read(rhythmCopyControllerProvider.notifier).restartGame(),
            child: const Text('Play Again'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _leaveAndPop,
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Widget _buildScores(RhythmCopySession session, String userId) {
    final partnerId = session.partnerOf(userId);
    final myScore = session.scoreOf(userId);
    final partnerScore = partnerId == null ? 0 : session.scoreOf(partnerId);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('You', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  '$myScore',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('Partner', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  '$partnerScore',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPads({required void Function(int value) onTap}) {
    final items = [
      (value: 1, color: const Color(0xFF4F86F7)),
      (value: 2, color: const Color(0xFF43C4A1)),
      (value: 3, color: const Color(0xFFF7A33E)),
      (value: 4, color: const Color(0xFFF05B79)),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        return SizedBox(
          width: 72,
          height: 72,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: item.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => onTap(item.value),
            child: Text(
              '${item.value}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPatternPreview(List<int> pattern) {
    if (pattern.isEmpty) {
      return Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            const Text('No taps yet', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: pattern.map((value) {
          return Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF2A3242),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$value',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimedTap {
  final int value;
  final int elapsedMs;

  const _TimedTap({
    required this.value,
    required this.elapsedMs,
  });
}
