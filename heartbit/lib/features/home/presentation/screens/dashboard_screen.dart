import 'dart:async';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heartbit/features/memory_vault/presentation/screens/memory_vault_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';

import 'package:heartbit/features/user/presentation/providers/partner_provider.dart';

import 'package:heartbit/features/daily_question/presentation/providers/daily_question_provider.dart';

import 'package:heartbit/features/activity_hub/presentation/providers/draft_session_provider.dart';
import 'package:heartbit/features/daily_question/presentation/widgets/sync_celebration.dart';
import 'package:heartbit/features/daily_question/domain/utils/answer_similarity.dart';

import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:heartbit/features/nudge/domain/entities/nudge_type.dart';
import 'package:heartbit/features/nudge/presentation/providers/nudge_provider.dart';
import 'package:heartbit/features/nudge/presentation/widgets/nudge_overlay.dart';
import 'package:heartbit/features/drawing/domain/entities/drawing_session.dart';
import 'package:heartbit/features/drawing/presentation/providers/drawing_provider.dart';

import 'package:heartbit/features/home/presentation/widgets/heart_pulse.dart';
import 'package:heartbit/features/user/presentation/providers/user_provider.dart';
import 'package:heartbit/features/home/presentation/providers/connection_score_provider.dart';
import 'package:heartbit/features/user/presentation/managers/presence_manager.dart';
import 'package:heartbit/features/games/stack_tower/presentation/providers/stack_tower_invite_provider.dart';
import 'package:heartbit/features/games/rhythm_copy/presentation/providers/rhythm_copy_invite_provider.dart';
import 'package:heartbit/features/games/emoji_game/presentation/providers/emoji_game_invite_provider.dart';
import 'package:heartbit/features/games/word_chain/presentation/providers/word_chain_invite_provider.dart';
import 'package:heartbit/features/games/story_chain/presentation/providers/story_chain_invite_provider.dart';

// Color palette
class _P {
  static const bg = Color(0xFFF8F4FF);
  static const bg2 = Color(0xFFFFFAF3);
  static const surface = Color(0x9EFFFFFF);
  static const surfaceStrong = Color(0xC4FFFFFF);
  static const border = Color(0x38FFFFFF);
  static const accent = Color(0xFF9B60E0);
  static const accent2 = Color(0xFFC58AF3);
  static const gold = accent;
  static const blush = Color(0xFFFFB8D4);
  static const mint = Color(0xFFAEEFD7);
  static const sky = Color(0xFFB7D9FF);
  static const text = Color(0xFF2D1A4A);
  static const muted = Color(0x8A2D1A4A);
  static const dim = Color(0x4F2D1A4A);
  static const green = Color(0xFF59C98A);
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  static const int _feedPageCount = 3;
  int _currentTabIndex = 0;
  final PageController _feedController = PageController();
  bool _isWheelPaging = false;

  bool _showSyncCelebration = false;
  SyncLevel? _currentSyncLevel;

  bool _showNudgeOverlay = false;
  NudgeType? _receivedNudgeType;
  DateTime? _lastNudgeShownTime;

  final bool _showMoodFeedback = false;
  final bool _showFloatingHearts = false;

  // Egg float
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  // Fire flicker
  late AnimationController _fireController;
  late Animation<double> _fireScaleY;
  late Animation<double> _fireScaleX;

  // Online dot pulse
  late AnimationController _onlinePulseController;
  late Animation<double> _onlinePulseAnim;

  // Progress bar fill
  late AnimationController _barController;
  late Animation<double> _barAnim;

  // Streak number pop-in
  late AnimationController _streakPopController;
  late Animation<double> _streakPopAnim;

  @override
  void initState() {
    super.initState();

    // Egg float
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Fire flicker
    _fireController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _fireScaleY = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(parent: _fireController, curve: Curves.easeInOut),
    );
    _fireScaleX = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _fireController, curve: Curves.easeInOut),
    );

    // Online dot pulse
    _onlinePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _onlinePulseAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _onlinePulseController, curve: Curves.easeOut),
    );

    // Bar fill
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _barAnim = CurvedAnimation(
      parent: _barController,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _barController.forward();
    });

    // Streak pop-in
    _streakPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _streakPopAnim = CurvedAnimation(
      parent: _streakPopController,
      curve: Curves.elasticOut,
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _streakPopController.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/images/egg_v2.png'), context);
      final couple = ref.read(coupleStateProvider).valueOrNull;
      if (couple != null) {
        ref.read(dailyQuestionControllerProvider.notifier).initTodaysQuestion();
      }
    });
  }

  @override
  void dispose() {
    _feedController.dispose();
    _floatController.dispose();
    _fireController.dispose();
    _onlinePulseController.dispose();
    _barController.dispose();
    _streakPopController.dispose();
    super.dispose();
  }

  Future<void> _goToFeedPage(int targetPage) async {
    if (!_feedController.hasClients) return;

    final safeTarget = targetPage.clamp(0, _feedPageCount - 1);
    final currentPage =
        (_feedController.page ?? _currentTabIndex.toDouble()).round();
    if (safeTarget == currentPage) return;

    await _feedController.animateToPage(
      safeTarget,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handlePointerScroll(PointerScrollEvent event) async {
    if (_isWheelPaging || !_feedController.hasClients) return;

    final deltaY = event.scrollDelta.dy;
    if (deltaY.abs() < 6) return;

    final currentPage =
        (_feedController.page ?? _currentTabIndex.toDouble()).round();
    final nextPage = deltaY > 0 ? currentPage + 1 : currentPage - 1;
    if (nextPage < 0 || nextPage >= _feedPageCount) return;

    _isWheelPaging = true;
    try {
      await _goToFeedPage(nextPage);
    } finally {
      _isWheelPaging = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(coupleStateProvider, (previous, next) {
      if (next.valueOrNull != null) {
        ref.read(dailyQuestionControllerProvider.notifier).initTodaysQuestion();
      }
    });

    ref.listen(nudgeStateProvider, (previous, next) {
      final data = next.valueOrNull;
      if (data != null && data['type'] != null) {
        final nudgeTime = data['time'] as DateTime?;
        if (_lastNudgeShownTime == null ||
            nudgeTime == null ||
            nudgeTime.isAfter(_lastNudgeShownTime!)) {
          setState(() {
            _receivedNudgeType =
                NudgeTypeExtension.fromKey(data['type'] as String);
            _showNudgeOverlay = true;
            _lastNudgeShownTime = nudgeTime ?? DateTime.now();
          });
        }
      }
    });

    ref.listen<AsyncValue<DrawingSession?>>(activeDrawingSessionProvider,
        (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Oyun Hatasi: ${next.error}'),
          backgroundColor: Colors.red,
        ));
        return;
      }
      final session = next.valueOrNull;
      if (session != null &&
          (session.status == 'pending' || session.status == 'drawing')) {
        final previousSession = previous?.valueOrNull;
        if (previousSession?.id != session.id) context.push('/draw-game');
      }
    });

    ref.listen(stackTowerInvitesProvider, (previous, next) {
      final invites = next.valueOrNull;
      final previousInvites = previous?.valueOrNull;
      if (invites != null && invites.isNotEmpty) {
        final invite = invites.first;
        final hadSameInvite =
            previousInvites?.any((p) => p.id == invite.id) ?? false;
        if (hadSameInvite) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Partnerin seni Stack Tower oynamaya cagiriyor!'),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'KATIL',
            textColor: _P.gold,
            onPressed: () {
              ref.read(dismissStackTowerInviteProvider(invite.id));
              context.push('/stack-tower');
            },
          ),
        ));
      }
    });

    ref.listen(rhythmCopyInvitesProvider, (previous, next) {
      final invites = next.valueOrNull;
      final previousInvites = previous?.valueOrNull;
      if (invites != null && invites.isNotEmpty) {
        final invite = invites.first;
        final hadSameInvite =
            previousInvites?.any((p) => p.id == invite.id) ?? false;
        if (hadSameInvite) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Partnerin seni Rhythm Copy\'a cagiriyor!'),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'KATIL',
            textColor: _P.gold,
            onPressed: () {
              ref.read(dismissRhythmCopyInviteProvider(invite.id));
              context.push('/rhythm-copy');
            },
          ),
        ));
      }
    });

    ref.listen(emojiGameInvitesProvider, (previous, next) {
      final invites = next.valueOrNull;
      final previousInvites = previous?.valueOrNull;
      if (invites != null && invites.isNotEmpty) {
        final invite = invites.first;
        final hadSameInvite =
            previousInvites?.any((p) => p.id == invite.id) ?? false;
        if (hadSameInvite) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Partnerin seni Emoji Tahmin\'e cagiriyor!'),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'KATIL',
            textColor: _P.gold,
            onPressed: () {
              ref.read(dismissEmojiGameInviteProvider(invite.id));
              context.push('/emoji-game');
            },
          ),
        ));
      }
    });

    ref.listen(wordChainInvitesProvider, (previous, next) {
      final invites = next.valueOrNull;
      final previousInvites = previous?.valueOrNull;
      if (invites != null && invites.isNotEmpty) {
        final invite = invites.first;
        final hadSameInvite =
            previousInvites?.any((p) => p.id == invite.id) ?? false;
        if (hadSameInvite) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Partnerin seni Word Chain oynamaya cagiriyor!'),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'KATIL',
            textColor: _P.gold,
            onPressed: () {
              ref.read(dismissWordChainInviteProvider(invite.id));
              context.push('/word-chain');
            },
          ),
        ));
      }
    });

    ref.listen(storyChainInvitesProvider, (previous, next) {
      final invites = next.valueOrNull;
      final previousInvites = previous?.valueOrNull;
      if (invites != null && invites.isNotEmpty) {
        final invite = invites.first;
        final hadSameInvite =
            previousInvites?.any((p) => p.id == invite.id) ?? false;
        if (hadSameInvite) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Partnerin seni Story Chain oynamaya cagiriyor!'),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'KATIL',
            textColor: _P.gold,
            onPressed: () {
              ref.read(dismissStoryChainInviteProvider(invite.id));
              context.push('/story-chain');
            },
          ),
        ));
      }
    });

    ref.listen(sharedDraftSessionProvider, (previous, next) {
      final userId = ref.read(authUserIdProvider);
      final draft = next.valueOrNull;
      if (userId == null || draft == null) return;
      final isPartnerReady = draft.readyUsers.any((id) => id != userId);
      final isMeReady = draft.readyUsers.contains(userId);
      final wasPartnerReady =
          previous?.valueOrNull?.readyUsers.any((id) => id != userId) ?? false;
      if (isPartnerReady && !isMeReady && !wasPartnerReady) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Partnerin Activity Hub\'da seni bekliyor!'),
          backgroundColor: _P.gold,
          action: SnackBarAction(
            label: 'KATIL',
            textColor: Colors.black,
            onPressed: () => context.push('/swipe-setup'),
          ),
          duration: const Duration(seconds: 5),
        ));
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PresenceManager(
          builder: (context, speed) {
            return Stack(
              children: [
                Positioned.fill(child: _buildBackdrop()),
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(child: _buildTopIsland()),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final userId = ref.read(authUserIdProvider);
                    if (userId != null) {
                      ref
                          .read(userRepositoryProvider)
                          .updateInteraction(userId);
                    }
                  },
                  behavior: HitTestBehavior.translucent,
                  child: SafeArea(child: _buildHomeSwipeFeed()),
                ),
                if (_showSyncCelebration && _currentSyncLevel != null)
                  SyncCelebration(
                    syncLevel: _currentSyncLevel!,
                    onComplete: () =>
                        setState(() => _showSyncCelebration = false),
                  ),
                if (_showNudgeOverlay && _receivedNudgeType != null)
                  NudgeOverlay(
                    nudgeType: _receivedNudgeType!,
                    onDismiss: () => setState(() => _showNudgeOverlay = false),
                  ),
                if (_showMoodFeedback)
                  Center(child: HeartPulse(size: 100, onComplete: () {})),
                if (_showFloatingHearts)
                  const Positioned(
                    bottom: 200,
                    left: 0,
                    right: 0,
                    child: Center(child: FloatingHearts(count: 5)),
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildHomeSwipeFeed() {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          unawaited(_handlePointerScroll(event));
        }
      },
      child: PageView.builder(
        controller: _feedController,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        pageSnapping: true,
        itemCount: _feedPageCount,
        onPageChanged: (index) {
          HapticFeedback.selectionClick();
          setState(() => _currentTabIndex = index);
        },
        itemBuilder: (context, index) {
          if (index == 0) return _buildHomePage();
          if (index == 1) return _buildGamesPage();
          return MemoryVaultScreen(
            onBack: () => unawaited(_goToFeedPage(0)),
          );
        },
      ),
    );
  }

  TextStyle _emoji(double size) => TextStyle(
        fontSize: size,
        fontFamilyFallback: const ['Apple Color Emoji', 'Noto Color Emoji'],
      );

  Widget _buildBackdrop() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_P.bg, _P.bg2],
        ),
      ),
      child: Stack(
        children: [
          _orb(top: -120, left: -60, size: 260, color: _P.blush),
          _orb(top: 110, right: -90, size: 300, color: _P.sky),
          _orb(bottom: -120, left: 40, size: 280, color: _P.mint),
          _orb(bottom: 50, right: 60, size: 180, color: _P.accent2),
        ],
      ),
    );
  }

  Positioned _orb({
    double? top,
    double? right,
    double? bottom,
    double? left,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopIsland() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: 128,
          height: 30,
          decoration: BoxDecoration(
            color: _P.surfaceStrong.withOpacity(0.7),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: _P.border),
            boxShadow: [
              BoxShadow(
                color: _P.accent.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    BorderRadius? radius,
    Color? tint,
  }) {
    final cardRadius = radius ?? BorderRadius.circular(20);
    return ClipRRect(
      borderRadius: cardRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint ?? _P.surface,
            borderRadius: cardRadius,
            border: Border.all(color: _P.border),
            boxShadow: [
              BoxShadow(
                color: _P.accent.withOpacity(0.10),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // HOME PAGE
  Widget _buildHomePage() {
    return SingleChildScrollView(
      // Keep vertical swipe priority on the parent PageView.
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildStreakBanner(),
          _buildEggCard(),
          _buildNudgeButtons(),
          _buildQuickActivity(),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final days = [
      'Pazartesi',
      'Sali',
      'Carsamba',
      'Persembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    final months = [
      'Ocak',
      'Subat',
      'Mart',
      'Nisan',
      'Mayis',
      'Haziran',
      'Temmuz',
      'Agustos',
      'Eylul',
      'Ekim',
      'Kasim',
      'Aralik',
    ];
    final dateStr =
        '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: _P.text,
                    letterSpacing: 0.5,
                  ),
                  children: const [
                    TextSpan(text: 'Heart'),
                    TextSpan(text: 'Bit', style: TextStyle(color: _P.gold)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 11,
                  color: _P.muted,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.push('/profile-edit'),
            child: _glassCard(
              radius: BorderRadius.circular(11),
              tint: _P.surfaceStrong.withOpacity(0.72),
              child: const SizedBox(
                width: 34,
                height: 34,
                child: Center(
                  child: Text('\u{1F464}', style: TextStyle(fontSize: 14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBanner() {
    final streakDays = ref.watch(coupleStateProvider).valueOrNull?.streak ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      child: _glassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        radius: BorderRadius.circular(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _fireController,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..scale(_fireScaleX.value, _fireScaleY.value),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: _P.accent.withOpacity(
                            0.20 + 0.25 * _fireController.value,
                          ),
                          blurRadius: 14 + 10 * _fireController.value,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text('\u{1F525}', style: _emoji(32)),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            ScaleTransition(
              scale: _streakPopAnim,
              child: Text(
                '$streakDays',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: _P.text,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'gunluk seri',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _P.text,
                  ),
                ),
                Text(
                  'Bugun de giris yaptiniz',
                  style: TextStyle(
                    fontSize: 10,
                    color: _P.muted,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEggCard() {
    final partnerAsync = ref.watch(partnerStateProvider);
    final score = ref.watch(connectionScoreProvider);
    final targetPct = (score.todayScore / 100).clamp(0.01, 1.0).toDouble();

    return GestureDetector(
      onTap: () => context.push('/pet-garden'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: _glassCard(
          padding: const EdgeInsets.all(20),
          radius: BorderRadius.circular(22),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7B67C2), Color(0xFFB584E7)],
                          ),
                          border: Border.all(
                            color: _P.accent.withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child:
                              Text('\u{1F465}', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partnerAsync.valueOrNull?.displayName ?? 'Partner',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _P.text,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Row(
                            children: [
                              AnimatedBuilder(
                                animation: _onlinePulseAnim,
                                builder: (context, _) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 5 + 8 * _onlinePulseAnim.value,
                                        height: 5 + 8 * _onlinePulseAnim.value,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _P.green.withOpacity(
                                            0.4 * (1 - _onlinePulseAnim.value),
                                          ),
                                        ),
                                      ),
                                      const DecoratedBox(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _P.green,
                                        ),
                                        child: SizedBox(width: 5, height: 5),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Su an aktif',
                                style: TextStyle(fontSize: 9, color: _P.muted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: _P.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _P.accent.withOpacity(0.20)),
                    ),
                    child: const Text(
                      'Seviye 1',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1,
                        color: _P.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _P.accent.withOpacity(0.24),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/egg_v2.png',
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Baby Egg',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _P.text,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Bari doldurarak yumurtayi buyutun',
                style: TextStyle(
                  fontSize: 11,
                  color: _P.muted,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 18),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'BAGLANTI GUCU',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: _P.dim,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${score.todayScore} / 100',
                        style: const TextStyle(
                          fontSize: 10,
                          color: _P.accent,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedBuilder(
                        animation: _barAnim,
                        builder: (context, _) {
                          final fillWidth =
                              constraints.maxWidth * targetPct * _barAnim.value;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: _P.border,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              Container(
                                height: 3,
                                width: fillWidth,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_P.accent, _P.accent2],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              if (fillWidth > 6)
                                Positioned(
                                  left: fillWidth - 5,
                                  top: -3,
                                  child: Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _P.accent2,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x889B60E0),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNudgeButtons() {
    final nudges = [
      NudgeType.fire,
      NudgeType.water,
      NudgeType.smile,
      NudgeType.missYou,
      NudgeType.thinking,
      NudgeType.love,
    ];
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final extraTileHeight =
        ((textScale - 1.0) * 12.0).clamp(0.0, 8.0).toDouble();
    final nudgeTileHeight = 78.0 + extraTileHeight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PARTNERA GONDER',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 2,
              color: _P.dim,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nudges.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: nudgeTileHeight,
            ),
            itemBuilder: (context, index) {
              final type = nudges[index];
              return _nudgeBtn(type.emoji, type.label, type);
            },
          ),
        ],
      ),
    );
  }

  Widget _nudgeBtn(String icon, String label, NudgeType type) {
    final isPrimary = type == NudgeType.love;

    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        try {
          await ref.read(nudgeControllerProvider.notifier).sendNudge(type);
        } catch (_) {}
      },
      child: _glassCard(
        radius: BorderRadius.circular(14),
        tint: isPrimary
            ? _P.accent.withOpacity(0.80)
            : _P.surfaceStrong.withOpacity(0.72),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: _emoji(18)),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : _P.muted,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActivity() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HIZLI AKTIVITE',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 2,
              color: _P.dim,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/draw-game'),
                  child: _quickCard(
                      '\u270F\uFE0F', 'Draw & Guess', 'Cizerek anlat'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/memory-vault'),
                  child: _quickCard('\u2728', 'Ani Ekle', 'Bir an paylas'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickCard(String icon, String title, String subtitle) {
    return _glassCard(
      padding: const EdgeInsets.all(13),
      radius: BorderRadius.circular(14),
      tint: _P.surfaceStrong.withOpacity(0.70),
      child: Row(
        children: [
          Text(icon, style: _emoji(15)),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _P.text,
                    letterSpacing: 0.1,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 9, color: _P.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesPage() {
    const games = <({
      String title,
      String route,
      String subtitle,
      String iconEmoji,
      Color accentColor,
      String? tag
    })>[
      (
        title: 'Draw & Guess',
        route: '/draw-game',
        subtitle: 'Birlikte ciz, tahmin et.',
        iconEmoji: '\u270F\uFE0F',
        accentColor: Color(0xFFA064FF),
        tag: 'Populer'
      ),
      (
        title: 'Stack Tower',
        route: '/stack-tower',
        subtitle: 'Dengeyi birlikte koru.',
        iconEmoji: '\u{1F3D7}\uFE0F',
        accentColor: Color(0xFF4D9FFF),
        tag: null
      ),
      (
        title: 'Emoji Tahmin',
        route: '/emoji-game',
        subtitle: 'Hislerin emoji diliyle.',
        iconEmoji: '\u{1F60A}',
        accentColor: Color(0xFFFF4D80),
        tag: 'Yeni'
      ),
      (
        title: 'Rhythm Copy',
        route: '/rhythm-copy',
        subtitle: 'Beat yarat, partner kopyala.',
        iconEmoji: '\u{1F3B5}',
        accentColor: Color(0xFFFF9F4D),
        tag: null
      ),
      (
        title: 'Word Chain',
        route: '/word-chain',
        subtitle: 'Kelime zinciri kur, kazan.',
        iconEmoji: '\u{1F517}',
        accentColor: Color(0xFF4DC8A0),
        tag: 'Yeni'
      ),
      (
        title: 'Story Chain',
        route: '/story-chain',
        subtitle: 'Sirayla yaz, ortak hikaye olustur.',
        iconEmoji: '\u{1F4D6}',
        accentColor: Color(0xFF7E6BFF),
        tag: 'Yeni'
      ),
      (
        title: 'Activity Hub',
        route: '/activity-hub',
        subtitle: 'Hizli etkilesim gorevleri.',
        iconEmoji: '\u{1F3AF}',
        accentColor: _P.gold,
        tag: null
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BIRLIKTE OYNA',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 2.5,
                  color: _P.dim,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gunluk Baglanti',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: _P.text,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/draw-game'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: _glassCard(
              padding: const EdgeInsets.all(18),
              radius: BorderRadius.circular(18),
              tint: _P.surfaceStrong.withOpacity(0.70),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _P.gold.withOpacity(0.12),
                            Colors.transparent
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BUGUNUN OYUNU',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                          color: _P.gold,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        'Draw & Guess',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: _P.text,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Es zamanli ciz, partnerini sasirt!',
                        style: TextStyle(
                          fontSize: 12,
                          color: _P.muted,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\u270F\uFE0F  \u2194\uFE0F  \u{1F91D}',
                              style: _emoji(20)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: _P.gold,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x55C8A96E),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Basla ->',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF5D4E37),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 10),
          child: Text(
            'TUM OYUNLAR',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 2,
              color: _P.dim,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.45,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return GestureDetector(
                onTap: () => context.push(game.route),
                child: _glassCard(
                  radius: BorderRadius.circular(16),
                  tint: _P.surfaceStrong.withOpacity(0.68),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(game.iconEmoji, style: _emoji(22)),
                            const SizedBox(height: 8),
                            Text(
                              game.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _P.text,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              game.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: _P.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (game.tag != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: game.accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: game.accentColor.withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              game.tag!,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: game.accentColor,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                game.accentColor.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: _P.surfaceStrong.withOpacity(0.76),
            border: const Border(top: BorderSide(color: _P.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => unawaited(_goToFeedPage(0)),
                child: _navItem('\u{1F3E0}', 'Home', _currentTabIndex == 0),
              ),
              GestureDetector(
                onTap: () => unawaited(_goToFeedPage(1)),
                child: _navItem('\u{1F3AE}', 'Games', _currentTabIndex == 1),
              ),
              GestureDetector(
                onTap: () => unawaited(_goToFeedPage(2)),
                child: _navItem('\u{1F4DA}', 'Memories', _currentTabIndex == 2),
              ),
              GestureDetector(
                onTap: () => context.push('/profile-edit'),
                child: _navItem('\u{1F464}', 'Profile', false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(String icon, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: active
          ? BoxDecoration(
              color: _P.accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: _emoji(17)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              letterSpacing: 0.5,
              color: active ? _P.accent : _P.dim,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
// Heart particle data
