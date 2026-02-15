import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../../domain/entities/activity.dart';
import '../providers/swipe_provider.dart';

class EnhancedSwipeScreen extends ConsumerStatefulWidget {
  const EnhancedSwipeScreen({super.key});

  @override
  ConsumerState<EnhancedSwipeScreen> createState() => _EnhancedSwipeScreenState();
}

class _EnhancedSwipeScreenState extends ConsumerState<EnhancedSwipeScreen>
    with TickerProviderStateMixin {
  final CardSwiperController _swiperController = CardSwiperController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    print('🎮 EnhancedSwipeScreen: initState called');

    // Start session when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🎮 EnhancedSwipeScreen: Starting session...');
      _startSession();
    });
  }

  void _startSession() {
    final deckAsync = ref.read(swipeDeckControllerProvider);
    if (deckAsync.hasValue && deckAsync.value!.isNotEmpty) {
      ref.read(swipeSessionControllerProvider.notifier).startSession(deckAsync.value!);
    }
  }

  @override
  void dispose() {
    _swiperController.dispose();
    // Clear providers when screen is disposed to prevent state sharing between users
    ref.invalidate(swipeDeckControllerProvider);
    ref.invalidate(swipeSessionControllerProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deckAsync = ref.watch(swipeDeckControllerProvider);
    final matchedActivity = ref.watch(matchEventNotifierProvider);
    final matches = ref.watch(activityMatchesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () {
            ref.read(selectedCategoriesProvider.notifier).clear();
            ref.read(sessionCustomActivitiesProvider.notifier).clear();
            Navigator.pop(context);
          },
        ),
        title: deckAsync.when(
          data: (deck) => Text(
            '${_currentIndex + 1}/${deck.length}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        centerTitle: true,
        actions: [
          matches.when(
            data: (matchList) => Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: AppColors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${matchList.length}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Stack(
        children: [
          deckAsync.when(
            data: (deck) {
              if (deck.isEmpty) return _buildEmptyState();
              if (_currentIndex >= deck.length) return _buildCompletedState();

              return Column(
                children: [
                  Expanded(
                    child: CardSwiper(
                      controller: _swiperController,
                      cardsCount: deck.length,
                      isLoop: false,
                      onSwipe: (previousIndex, currentIndex, direction) {
                        // Safety check: ensure previousIndex is valid
                        if (previousIndex < 0 || previousIndex >= deck.length) {
                          print('⚠️ Invalid previousIndex: $previousIndex, deck length: ${deck.length}');
                          return false;
                        }
                        
                        final liked = direction == CardSwiperDirection.right;
                        _handleSwipe(deck[previousIndex], liked);

                        if (currentIndex != null) {
                          setState(() => _currentIndex = currentIndex);
                        } else {
                          setState(() => _currentIndex = deck.length);
                        }
                        return true;
                      },
                      onEnd: () {
                        print('🎮 CardSwiper: All cards swiped');
                        if (mounted) {
                          setState(() => _currentIndex = deck.length);
                        }
                      },
                      numberOfCardsDisplayed: 3,
                      backCardOffset: const Offset(0, 35),
                      padding: const EdgeInsets.all(24),
                      cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                        return _ActivityCard(activity: deck[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionButton(
                          icon: Icons.close,
                          color: Colors.red,
                          onTap: () => _swiperController.swipe(CardSwiperDirection.left),
                        ),
                        const SizedBox(width: 48),
                        _ActionButton(
                          icon: Icons.favorite,
                          color: AppColors.primary,
                          onTap: () => _swiperController.swipe(CardSwiperDirection.right),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
          ),

          if (matchedActivity != null)
            _MatchCelebration(
              activity: matchedActivity,
              onDismiss: () {
                ref.read(matchEventNotifierProvider.notifier).clear();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _handleSwipe(Activity activity, bool liked) async {
    try {
      HapticFeedback.lightImpact();
      print('🎮 Swiping: ${activity.title} - ${liked ? "RIGHT" : "LEFT"}');
      await ref.read(swipeSessionControllerProvider.notifier).swipe(activity, liked);
      print('✅ Swipe completed successfully');
    } catch (e, stackTrace) {
      print('❌ Error during swipe: $e');
      print(stackTrace);
      // Show error to user but don't crash
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Swipe error: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: AppColors.textSecondary),
          SizedBox(height: 24),
          Text(
            'No activities found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try selecting different vibes',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedState() {
    final matchesAsync = ref.watch(activityMatchesProvider);

    return matchesAsync.when(
      data: (matchList) {
        print('🎯 CompletedState: Found ${matchList.length} matches');

        if (matchList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Waiting for your partner...',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        final items = matchList.map((m) => m.activityTitle).toList();

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'You both loved these! 💕',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${matchList.length} match${matchList.length > 1 ? 'es' : ''} found!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              )),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  ref.read(selectedCategoriesProvider.notifier).clear();
                  ref.read(sessionCustomActivitiesProvider.notifier).clear();
                  Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/activity-hub');
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Back to Hub', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (_, __) => const Center(child: Text('Could not load matches', style: TextStyle(color: AppColors.error))),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: activity.imageUrl.isEmpty ? LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (activity.imageUrl.isNotEmpty)
              Image.network(
                activity.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (activity.description.isNotEmpty)
                      Text(
                        activity.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.favorite, size: 80, color: Colors.white24),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 36),
      ),
    );
  }
}

class _MatchCelebration extends StatefulWidget {
  final Activity activity;
  final VoidCallback onDismiss;

  const _MatchCelebration({
    required this.activity,
    required this.onDismiss,
  });

  @override
  State<_MatchCelebration> createState() => _MatchCelebrationState();
}

class _MatchCelebrationState extends State<_MatchCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💕', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                const Text(
                  "It's a Match!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    widget.activity.title,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Tap anywhere to continue',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
