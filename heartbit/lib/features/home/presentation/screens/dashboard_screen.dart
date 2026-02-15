import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // For ImageFilter
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/home/domain/entities/mood.dart';
import 'package:heartbit/features/home/presentation/providers/mood_provider.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/config/design_tokens/design_tokens.dart';
import 'package:heartbit/features/pet/presentation/providers/pet_provider.dart';
import 'package:heartbit/features/user/presentation/providers/partner_provider.dart';
import 'package:heartbit/features/task/presentation/providers/task_provider.dart';
import 'package:heartbit/features/daily_question/presentation/providers/daily_question_provider.dart';
import 'package:heartbit/features/daily_question/presentation/widgets/reaction_bar.dart';
import 'package:heartbit/features/activity_hub/presentation/providers/draft_session_provider.dart';
import 'package:heartbit/features/daily_question/presentation/widgets/sync_celebration.dart';
import 'package:heartbit/features/daily_question/domain/utils/answer_similarity.dart';
import 'package:heartbit/core/widgets/animated_background.dart';
import 'package:heartbit/features/home/presentation/widgets/pet_display.dart';
import 'package:lottie/lottie.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:heartbit/features/nudge/domain/entities/nudge_type.dart';
import 'package:heartbit/features/nudge/presentation/providers/nudge_provider.dart';
import 'package:heartbit/features/nudge/presentation/widgets/nudge_picker.dart';
import 'package:heartbit/features/nudge/presentation/widgets/nudge_overlay.dart';
import 'package:heartbit/features/drawing/domain/entities/drawing_session.dart';
import 'package:heartbit/features/drawing/presentation/providers/drawing_provider.dart';
import 'package:heartbit/features/home/presentation/providers/connection_score_provider.dart';
import 'package:heartbit/features/home/presentation/widgets/relationship_hub.dart';
import 'package:heartbit/features/home/presentation/widgets/mood_pill.dart';
import 'package:heartbit/features/home/presentation/widgets/mood_bottom_sheet.dart';
import 'package:heartbit/features/home/presentation/widgets/heart_pulse.dart';
import 'package:heartbit/features/user/presentation/providers/user_provider.dart';
import 'package:heartbit/features/egg/presentation/widgets/egg_widget.dart';
import 'package:heartbit/features/egg/presentation/widgets/warmth_bar.dart';
import 'package:heartbit/features/user/presentation/managers/presence_manager.dart';
import 'package:heartbit/features/games/stack_tower/presentation/providers/stack_tower_invite_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final PageController _pageController = PageController();
  bool _showSyncCelebration = false;
  SyncLevel? _currentSyncLevel;
  String? _lastCelebratedDate;
  bool _showNudgeOverlay = false;
  NudgeType? _receivedNudgeType;
  DateTime? _lastNudgeShownTime;
  
  // Mood feedback animations
  bool _showMoodFeedback = false;
  bool _showFloatingHearts = false;

  @override
  void initState() {
    super.initState();
    // Robust Initialization: Check initial state AND listen for updates.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final couple = ref.read(coupleStateProvider).valueOrNull;
      if (couple != null) {
        ref.read(dailyQuestionControllerProvider.notifier).initTodaysQuestion();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Robust Initialization: Listen to couple state.
    // Once couple data is loaded, trigger daily question initialization.
    ref.listen(coupleStateProvider, (previous, next) {
      if (next.valueOrNull != null) {
        ref.read(dailyQuestionControllerProvider.notifier).initTodaysQuestion();
      }
    });

    // Listen for incoming nudges
    ref.listen(nudgeStateProvider, (previous, next) {
      final data = next.valueOrNull;
      if (data != null && data['type'] != null) {
        final nudgeTime = data['time'] as DateTime?;
        // Prevent duplicate display
        if (_lastNudgeShownTime == null ||
            nudgeTime == null ||
            nudgeTime.isAfter(_lastNudgeShownTime!)) {
          setState(() {
            _receivedNudgeType = NudgeTypeExtension.fromKey(data['type'] as String);
            _showNudgeOverlay = true;
            _lastNudgeShownTime = nudgeTime ?? DateTime.now();
          });
        }
      }
    });

    // Listen for incoming game sessions (Auto-Navigation)
    ref.listen<AsyncValue<DrawingSession?>>(activeDrawingSessionProvider, (previous, next) {

      if (next.hasError) {
         print('Session Error: ${next.error}');
         // Only show if it's likely an index error (contains 'index') or just show generic
         // showing generic is safer for debugging
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Oyun Hatası: ${next.error}'), backgroundColor: Colors.red),
         );
         return;
      }

      final session = next.valueOrNull;
      // If we have a valid session and we are not already there
      if (session != null && (session.status == 'pending' || session.status == 'drawing')) {
         
         // Logic: If the session ID changed (or we didn't have one before), it's a new event 
         // that warrants attention (navigation).
         final previousSession = previous?.valueOrNull;
         if (previousSession?.id != session.id) {
            context.push('/draw-game');
         }
      }
    });

    // Listen for Stack Tower invites
    ref.listen(stackTowerInvitesProvider, (previous, next) {
        final invites = next.valueOrNull;
        final previousInvites = previous?.valueOrNull;
        if (invites != null && invites.isNotEmpty) {
          final invite = invites.first;
          // Only show notification if this is a NEW invite
          // (previous list was empty or had a different invite)
          final hadSameInvite = previousInvites?.any((p) => p.id == invite.id) ?? false;
          if (hadSameInvite) return;
          
          // Show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Partnerin seni Stack Tower oynamaya çağırıyor! 🎮'),
              duration: const Duration(seconds: 10),
              action: SnackBarAction(
                label: 'KATIL',
                textColor: AppColors.accent,
                onPressed: () {
                  // Dismiss invite
                  ref.read(dismissStackTowerInviteProvider(invite.id));
                  // Navigate to game
                  context.push('/stack-tower');
                },
              ),
            ),
          );
        }
    });

    // Listen for Waiting Partner in Activity Hub
    ref.listen(sharedDraftSessionProvider, (previous, next) {
      final userId = ref.read(authUserIdProvider);
      final draft = next.valueOrNull;

      if (userId == null || draft == null) return;

      final isPartnerReady = draft.readyUsers.any((id) => id != userId);
      final isMeReady = draft.readyUsers.contains(userId);

      // Trigger notification only when partner BECOMES ready
      final wasPartnerReady = previous?.valueOrNull?.readyUsers.any((id) => id != userId) ?? false;

      if (isPartnerReady && !isMeReady && !wasPartnerReady) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: const Text('Partnerin Activity Hub\'da seni bekliyor! 💌'),
             backgroundColor: AppColors.primary,
             action: SnackBarAction(
               label: 'KATIL',
               textColor: Colors.white,
               onPressed: () => context.push('/swipe-setup'),
             ),
             duration: const Duration(seconds: 5),
           ),
         );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/memory-vault'),
        backgroundColor: AppColors.primary.withOpacity(0.85),
        elevation: 4,
        tooltip: 'Anı Deposu',
        child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 24),
      ),
      body: PresenceManager(
        builder: (context, speed) {
          return Stack(
            children: [
              // Main content with Interactive Background
              GestureDetector(
                onTap: () {
                  // Send "I'm interacting" signal so partner feels the burst
                  final userId = ref.read(authUserIdProvider);
                  if (userId != null) {
                    ref.read(userRepositoryProvider).updateInteraction(userId);
                  }
                  // Optional: Local feedback or just let the partner seeing it be the reward
                },
                behavior: HitTestBehavior.translucent, // Ensure touches pass through if needed, or catch them here
                child: AnimatedBackground(
                  speed: speed, // Dynamic speed!
                  child: PageView(
                    controller: _pageController,
                    scrollDirection: Axis.vertical, // Vertical Scroll (TikTok style)
                    children: [
                      _buildHomePage(context),
                      _buildDailyQuestionPage(context),
                      _buildStreakPage(context),
                    ],
                  ),
                ),
              ),
              // Sync Celebration Overlay
              if (_showSyncCelebration && _currentSyncLevel != null)
                SyncCelebration(
                  syncLevel: _currentSyncLevel!,
                  onComplete: () {
                    setState(() {
                      _showSyncCelebration = false;
                    });
                  },
                ),
              // Nudge Overlay
              if (_showNudgeOverlay && _receivedNudgeType != null)
                NudgeOverlay(
                  nudgeType: _receivedNudgeType!,
                  onDismiss: () {
                    setState(() {
                      _showNudgeOverlay = false;
                    });
                  },
                ),
              // Mood Feedback - Heart Pulse
              if (_showMoodFeedback)
                Center(
                  child: HeartPulse(
                    size: 100,
                    onComplete: () {},
                  ),
                ),
              // Mood Feedback - Floating Hearts
              if (_showFloatingHearts)
                Positioned(
                  bottom: 200,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingHearts(count: 5),
                  ),
                ),
              // Partner Waiting Banner (Activity Hub)
              const _PartnerWaitingBanner(),
            ],
          );
        }
      ),
    );
  }

  // ==================== PAGE 1: MAIN DASHBOARD ====================
  // ==================== PAGE 1: MAIN DASHBOARD ====================
  Widget _buildHomePage(BuildContext context) {
    return SafeArea(
      child: Padding(
         padding: DesignTokens.padding5,
        child: Column(
          children: [
            // TOP SECTION (40%) - Balanced
            Expanded(
              flex: 4,
              child: Container(
                alignment: Alignment.bottomCenter,
                 padding: const EdgeInsets.only(bottom: DesignTokens.space2), // Keep tight padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildHeader(context),
                    const Spacer(),
                    // Relationship Hub
                    Padding(
                      padding: DesignTokens.paddingHorizontal4,
                      child: const RelationshipHub(),
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM SECTION (60% - Hero Zone)
            // Egg and Warmth Bar grouped vertically & tightly
            Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center the group vertically
                children: [
                   // The Massive Egg
                   // Removed Expanded to keep it close to the bar
                   Center(
                       child: _buildPetPreviewCard(ref),
                   ),
                   
                   // Warmth Bar (Directly below)
                   Transform.translate(
                     offset: const Offset(0, -20), 
                     child: const Padding(
                        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space7),
                       child: WarmthBar(),
                     ),
                   ),
                   
                   // Status Text (Egg Title)
                   // Now positioned below the bar as requested
                   Transform.translate(
                      offset: const Offset(0, -10),
                      child: const _EggStatusText(),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Current Mood Reference
    final moodAsync = ref.watch(currentMoodProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Row: Greeting + Logout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Day,',
                  style: DesignTokens.bodyMedium(color: AppColors.textSecondary),
                ),
                Text(
                  'HeartBit',
                  style: DesignTokens.heading3(color: AppColors.textPrimary),
                ),
              ],
            ),
            Row(
              children: [
                // Profile Button
                IconButton(
                  onPressed: () => context.push('/profile-edit'),
                  icon: const Icon(Icons.person, color: AppColors.textSecondary, size: 20),
                ),
                IconButton(
                  onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                  icon: const Icon(Icons.logout, color: AppColors.textSecondary, size: 20),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Premium Mood Pill - Minimal & Modern
        moodAsync.when(
          data: (current) => Row(
            children: [
              MoodPill(
                selectedMood: current,
                onTap: () => _showMoodSelector(current),
              ),
              if (current != null) ...[
                const SizedBox(width: 12),
                // Partner mood indicator
                _buildPartnerMoodIndicator(),
              ],
            ],
          ),
          loading: () => MoodPill(
            selectedMood: null,
            onTap: () {},
            isLoading: true,
          ),
          error: (_, __) => MoodPill(
            selectedMood: null,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  /// Show mood selector bottom sheet
  void _showMoodSelector(Mood? currentMood) {
    MoodBottomSheet.show(
      context,
      currentMood: currentMood,
      onMoodSelected: (mood) async {
        // Show feedback animations
        setState(() {
          _showMoodFeedback = true;
          _showFloatingHearts = true;
        });

        // Save mood
        await ref.read(moodControllerProvider.notifier).setMood(mood);

        // Hide feedback after animation
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _showMoodFeedback = false;
            });
          }
        });

        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            setState(() {
              _showFloatingHearts = false;
            });
          }
        });
      },
    );
  }

  /// Build partner mood indicator pill
  Widget _buildPartnerMoodIndicator() {
    final partnerMoodAsync = ref.watch(partnerMoodProvider);

    return partnerMoodAsync.when(
      data: (partnerMood) {
        if (partnerMood == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space3, vertical: DesignTokens.space2),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: DesignTokens.borderRadiusMd,
            border: Border.all(
              color: Color(partnerMood.colorValue).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Partner: ',
                style: DesignTokens.labelSmall(color: AppColors.textSecondary),
              ),
              Text(
                partnerMood.emoji,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPetPreviewCard(WidgetRef ref) {
    final petAsync = ref.watch(petStateProvider);

    return petAsync.when(
      data: (pet) {
        if (pet == null) {
          // If no pet exists yet, show the shared Egg for hatching
          return const EggWidget();
        }
        return PetDisplay(pet: pet);
      },
      loading: () => Container(
        height: 350,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: DesignTokens.borderRadiusLg,
        ),
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (_, __) => Container(
        height: 350,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: DesignTokens.borderRadiusLg,
        ),
        child: const Center(child: Text('Error loading pet', style: TextStyle(color: AppColors.error))),
      ),
    );
  }

  // ==================== PAGE 2: DAILY QUESTION ====================
  Widget _buildDailyQuestionPage(BuildContext context) {
    return Container(
      color: AppColors.background, // Match main background for consistency or use subtle gradient
        child: SafeArea(
        child: Padding(
          padding: DesignTokens.padding6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Daily Connection', style: DesignTokens.heading4(color: AppColors.secondary)),
              const SizedBox(height: DesignTokens.space5),
              // Game Hub Button - Draw & Guess
              if (ref.watch(coupleStateProvider).valueOrNull != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: DesignTokens.space3),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/draw-game');
                    },
                    icon: const Icon(Icons.brush, color: Colors.white),
                    label: const Text('Draw & Guess Oyna', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: DesignTokens.paddingVertical4,
                      shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadiusMd),
                      elevation: 4,
                    ),
                  ),
                ),
              // Stack Tower Game Button
              if (ref.watch(coupleStateProvider).valueOrNull != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: DesignTokens.space3),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/stack-tower');
                    },
                    icon: const Icon(Icons.layers, color: Colors.white),
                    label: const Text('Stack Tower', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      padding: DesignTokens.paddingVertical4,
                      shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadiusMd),
                      elevation: 4,
                    ),
                  ),
                ),
              // Activity Hub Button
              if (ref.watch(coupleStateProvider).valueOrNull != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: DesignTokens.space5),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/activity-hub');
                    },
                    icon: const Icon(Icons.casino, color: Colors.white),
                    label: const Text('Activity Hub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: DesignTokens.paddingVertical4,
                      shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadiusMd),
                      elevation: 4,
                    ),
                  ),
                ),
              _buildDailyQuestionCard(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyQuestionCard(BuildContext context, WidgetRef ref) {
    final questionAsync = ref.watch(todaysQuestionProvider);
    final controllerState = ref.watch(dailyQuestionControllerProvider); // Watch controller for errors
    final userId = ref.watch(authUserIdProvider);
    final coupleAsync = ref.watch(coupleStateProvider);
    final couple = coupleAsync.valueOrNull;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(color: AppColors.surface, borderColor: AppColors.primary.withOpacity(0.3)),
      child: Builder(
        builder: (context) {
          // 09:00 AM Rule
          final now = DateTime.now();
          if (now.hour < 9) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.nights_stay, size: 48, color: AppColors.secondary),
                const SizedBox(height: DesignTokens.space4),
                Text(
                  'Henüz sabah olmadı! 🌙',
                  style: DesignTokens.heading4(color: AppColors.textPrimary),
                ),
                const SizedBox(height: DesignTokens.space2),
                Text(
                  'Yeni soru saat 09:00\'da hazır olacak.\nŞimdilik dinlenme zamanı.',
                  textAlign: TextAlign.center,
                  style: DesignTokens.bodyMedium(color: AppColors.textSecondary),
                ),
              ],
            );
          }

          return controllerState.when(
            data: (_) => questionAsync.when(
              data: (dq) {
                if (dq == null) {
                  return Container(
                     width: double.infinity,
                     padding: DesignTokens.padding6,
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         const CircularProgressIndicator(color: AppColors.primary),
                         const SizedBox(height: DesignTokens.space4),
                         Text('Günün sorusu hazırlanıyor...', style: DesignTokens.bodyMedium(color: AppColors.textSecondary), textAlign: TextAlign.center),
                       ],
                     ),
                  );
                }

          if (userId == null || couple == null) return const SizedBox();

          final isUser1 = couple.user1Id == userId;
          final myAnswer = isUser1 ? dq.user1Answer : dq.user2Answer;
          final partnerAnswer = isUser1 ? dq.user2Answer : dq.user1Answer;
          final iHaveAnswered = myAnswer != null;
          final partnerHasAnswered = partnerAnswer != null;
          // final bothAnswered = iHaveAnswered && partnerHasAnswered; // Unused variable

          return Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header & Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, size: 28, color: AppColors.primary),
                      const SizedBox(width: DesignTokens.space2),
                      Text(
                        'Daily Question',
                        style: DesignTokens.labelLarge(
                          color: AppColors.primary,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              const SizedBox(height: DesignTokens.space4),

              // Question Text
              Text(
                dq.questionText,
                textAlign: TextAlign.center,
                style: DesignTokens.heading4(color: AppColors.textPrimary),
              ),
              const SizedBox(height: DesignTokens.space6),

              // STATE 1: Unanswered - Show Input (and Partner's Blurred if available)
              if (!iHaveAnswered) ...[
                if (partnerHasAnswered) ...[
                  // Partner answered but I haven't -> Show BLURRED
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: _buildAnswerBubble('Partnerin harika bir şeyler yazdı...\n(Ama görmek için önce sen cevaplamalısın!)', false),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space3, vertical: DesignTokens.space1),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: DesignTokens.borderRadiusMd,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock, color: Colors.white, size: 16),
                            const SizedBox(width: DesignTokens.space2),
                            Text('Partnerin Cevapladı', style: DesignTokens.labelSmall(color: Colors.white, weight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space5),
                  Text('Meraklanma, kilidi açmak için sen de cevapla! 👇', style: DesignTokens.labelMedium(color: AppColors.accent)),
                  const SizedBox(height: DesignTokens.space3),
                ],
                _buildAnswerButton(context, ref, dq.date),
              ]
              

               // STATE 2: Waiting for Partner - Lottie Animation
               else if (iHaveAnswered && !partnerHasAnswered)
                 Container(
                   width: double.infinity,
                   padding: DesignTokens.padding5,
                   decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: DesignTokens.borderRadiusMd,
                      border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
                    ),
                   child: Column(
                     children: [
                        Text(
                          'Senin Cevabın:',
                          style: DesignTokens.labelSmall(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: DesignTokens.space2),
                        Text(
                          myAnswer,
                          textAlign: TextAlign.center,
                          style: DesignTokens.bodyLarge(
                            color: AppColors.textPrimary,
                          ).copyWith(fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: DesignTokens.space5),
                       // Lottie Animation
                       SizedBox(
                         height: 120,
                          // Lottie link expired (403), using fallback icon
                          child: const Icon(
                            Icons.hourglass_empty,
                            size: 80, 
                            color: AppColors.accent,
                          ),
                       ),
                        const SizedBox(height: DesignTokens.space4),
                        Text(
                          'Partnerin bekleniyor...',
                          style: DesignTokens.heading5(color: AppColors.accent),
                        ),
                        const SizedBox(height: DesignTokens.space1),
                        Text(
                          'İkiniz de cevaplayınca cevaplar açılacak! 🤫',
                          style: DesignTokens.labelSmall(color: AppColors.textSecondary.withOpacity(0.7)),
                        ),
                     ],
                   ),
                 )

              // STATE 3: Both Answered - Reveal All
              else
                Builder(
                  builder: (context) {
                    // Calculate sync level
                    final syncLevel = AnswerSimilarity.getSyncLevel(
                      myAnswer ?? '',
                      partnerAnswer ?? '',
                    );
                    
                    // Trigger celebration once per day
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      if (syncLevel.hasBonusXp && 
                          !dq.syncXpClaimed && // Check if not already claimed
                          _lastCelebratedDate != dq.date &&
                          !_showSyncCelebration) {
                        
                        // Claim XP
                        ref.read(dailyQuestionControllerProvider.notifier)
                           .claimSyncBonus(syncLevel.bonusXp!);

                        // Show Animation
                        if (mounted) {
                          setState(() {
                            _showSyncCelebration = true;
                            _currentSyncLevel = syncLevel;
                            _lastCelebratedDate = dq.date;
                          });
                        }
                      }
                    });
                    
                    return Column(
                      children: [
                        _buildAnswerBubble(myAnswer!, true), // My Answer
                        const SizedBox(height: 12),
                        _buildAnswerBubble(partnerAnswer!, false), // Partner Answer
                        // Sync Indicator
                        SyncIndicator(syncLevel: syncLevel),
                        const SizedBox(height: 16),
                        // Reaction Bar - react to partner's answer
                        ReactionBar(
                          currentReaction: isUser1 ? dq.user1Reaction : dq.user2Reaction,
                          onReactionSelected: (reaction) {
                            ref.read(dailyQuestionControllerProvider.notifier)
                                .submitReaction(reaction);
                          },
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
          // Archive Button
          Positioned(
             right: 0, 
             top: 0,
             child: IconButton(
                icon: Icon(Icons.history, color: AppColors.textSecondary.withOpacity(0.7)),
                tooltip: 'Arşiv',
                onPressed: () {
                  context.push('/archive');
                },
             ),
          ),
        ],
      );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Text('Yüklenemedi', style: TextStyle(color: AppColors.error)),
      ),
      // Controller Error State (Creation Failed)
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              const Text('Soru Oluşturulamadı!', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(e.toString(), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(dailyQuestionControllerProvider.notifier).initTodaysQuestion(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.surface),
                child: const Text('Tekrar Dene', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
        },
      ),
  );
  }

  Widget _buildAnswerButton(BuildContext context, WidgetRef ref, String date) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showAnswerDialog(context, ref, date),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.4),
        ),
        child: const Text('Cevapla', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAnswerBubble(String text, bool isMe) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? AppColors.primary.withOpacity(0.3) : AppColors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isMe ? 'Senin Cevabın:' : 'Partnerinin Cevabı:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isMe ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(color: AppColors.textPrimary, height: 1.3),
          ),
        ],
      ),
    );
  }



  // ==================== PAGE 4: STREAK & PROGRESS ====================
  Widget _buildStreakPage(BuildContext context) {
    final streakAsync = ref.watch(streakProvider);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Your Journey', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 40),
             streakAsync.when(
               data: (streak) => Column(
                 children: [
                   Text('$streak', style: const TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: AppColors.accent, height: 1)),
                   const Text('Days Streak', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                 ],
               ),
               loading: () => const CircularProgressIndicator(color: AppColors.primary),
               error: (_,__) => const Text('Error', style: TextStyle(color: AppColors.error)),
             ),
             const SizedBox(height: 40),
             // Task Summary
             _buildSectionTitle('Today\'s Progress'),
             Expanded(child: _buildTasksList(ref)),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    );
  }





  Widget _buildTasksList(WidgetRef ref) {
    final tasksAsync = ref.watch(dailyTasksProvider);
    return tasksAsync.when(
      data: (tasks) => ListView(
        children: tasks.map((task) => ListTile(
          leading: Text(task.emoji),
          title: Text(task.title, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null, color: AppColors.textPrimary)),
          trailing: task.isCompleted ? const Icon(Icons.check, color: AppColors.accent) : null,
        )).toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (_,__) => const Text('Error', style: TextStyle(color: AppColors.error)),
    );
  }

  void _showAnswerDialog(BuildContext context, WidgetRef ref, String date) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Your Answer', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller, 
          maxLines: 3, 
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Type something...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.secondary)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(dailyQuestionControllerProvider.notifier).submitAnswer(controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration({required Color color, Color? borderColor}) {
    return BoxDecoration(
      color: color,
      borderRadius: DesignTokens.borderRadiusLg,
      border: Border.all(color: borderColor ?? AppColors.border, width: 0.5),
      boxShadow: DesignTokens.shadowLg,
    );
  }
}

class _EggStatusText extends ConsumerWidget {
  const _EggStatusText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
     final couple = ref.watch(coupleStateProvider).valueOrNull;
     if (couple == null) return const SizedBox();

     final warmth = couple.eggWarmth;
     final progress = (warmth / 1000).clamp(0.0, 1.0);
     final isHatching = warmth >= 1000;
     
     return AnimatedOpacity(
       duration: const Duration(milliseconds: 500),
       opacity: progress > 0.5 ? 1.0 : 0.7,
       child: Column(
         children: [
           Text(
             isHatching ? 'ÇATLIYOR!' : 'Baby Egg',
             style: const TextStyle(
               color: AppColors.textPrimary,
               fontSize: 24,
               fontWeight: FontWeight.bold,
               fontFamily: 'Outfit',
             ),
           ),
            const SizedBox(height: DesignTokens.space1),
            Text(
               'Lvl 1 • Egg',
               style: DesignTokens.bodySmall(color: AppColors.textSecondary),
            ),
         ],
       ),
     );
  }
}

/// Banner shown when partner is waiting in Activity Hub
class _PartnerWaitingBanner extends ConsumerWidget {
  const _PartnerWaitingBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authUserIdProvider);
    final draftAsync = ref.watch(sharedDraftSessionProvider);

    print('🏷️ Banner Widget Build:');
    print('   - userId: $userId');
    print('   - draftAsync.isLoading: ${draftAsync.isLoading}');
    print('   - draftAsync.hasValue: ${draftAsync.hasValue}');
    print('   - draftAsync.hasError: ${draftAsync.hasError}');
    
    if (draftAsync.hasError) {
      print('   - ERROR: ${draftAsync.error}');
    }

    return draftAsync.when(
      data: (draft) {
        if (draft == null || userId == null) {
          print('🏷️ Banner: No draft or userId (draft=$draft, userId=$userId)');
          return const SizedBox.shrink();
        }

        // Check if partner is in lobby OR ready
        final isPartnerInLobby = draft.lobbyUsers.any((id) => id != userId);
        final isPartnerReady = draft.readyUsers.any((id) => id != userId);
        final isMeInLobby = draft.lobbyUsers.contains(userId);
        final isMeReady = draft.readyUsers.contains(userId);
        
        // Partner is waiting if they're in lobby or ready (but I'm not)
        final partnerWaiting = isPartnerInLobby || isPartnerReady;
        final imAlreadyThere = isMeInLobby || isMeReady;
        
        print('🏷️ Banner Check:');
        print('   - Current userId: $userId');
        print('   - lobbyUsers: ${draft.lobbyUsers}');
        print('   - readyUsers: ${draft.readyUsers}');
        print('   - isPartnerInLobby: $isPartnerInLobby');
        print('   - isPartnerReady: $isPartnerReady');
        print('   - isMeInLobby: $isMeInLobby');
        print('   - isMeReady: $isMeReady');
        print('   - Should show banner: ${partnerWaiting && !imAlreadyThere}');

        // Show banner only if partner is waiting but I'm not there yet
        if (!partnerWaiting || imAlreadyThere) {
          print('🏷️ Banner: HIDDEN');
          return const SizedBox.shrink();
        }
        
        print('🏷️ Banner: SHOWING! Partner is waiting for me to join');

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
               margin: const EdgeInsets.symmetric(horizontal: DesignTokens.space4, vertical: DesignTokens.space2),
               decoration: BoxDecoration(
                 gradient: AppColors.primaryGradient,
                 borderRadius: DesignTokens.borderRadiusMd,
                 boxShadow: DesignTokens.shadowMd,
               ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                   onTap: () => context.push('/swipe-setup'),
                  borderRadius: DesignTokens.borderRadiusMd,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space4, vertical: DesignTokens.space3),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                             children: [
                               Text(
                                 'Partnerin seni bekliyor! 💕',
                                 style: DesignTokens.labelLarge(
                                   color: Colors.white,
                                   weight: FontWeight.bold,
                                 ),
                               ),
                               Text(
                                 'Activity Hub\'a katıl',
                                 style: DesignTokens.labelSmall(
                                   color: Colors.white70,
                                 ),
                               ),
                             ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () {
        print('🏷️ Banner: LOADING state - waiting for draft data');
        return const SizedBox.shrink();
      },
      error: (error, stack) {
        print('🏷️ Banner: ERROR state - $error');
        return const SizedBox.shrink();
      },
    );
  }
}
