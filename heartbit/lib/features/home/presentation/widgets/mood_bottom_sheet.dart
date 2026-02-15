import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heartbit/features/home/domain/entities/mood.dart';
import 'package:heartbit/config/theme/app_colors.dart';

/// Premium Mood Selection Bottom Sheet
///
/// A modern, emotionally engaging bottom sheet for mood selection.
/// Features a 2-row grid layout with smooth animations and
/// immediate feedback on selection.
class MoodBottomSheet extends StatefulWidget {
  final Mood? currentMood;
  final Function(Mood) onMoodSelected;

  const MoodBottomSheet({
    super.key,
    this.currentMood,
    required this.onMoodSelected,
  });

  static Future<void> show(BuildContext context, {
    Mood? currentMood,
    required Function(Mood) onMoodSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => MoodBottomSheet(
        currentMood: currentMood,
        onMoodSelected: onMoodSelected,
      ),
    );
  }

  @override
  State<MoodBottomSheet> createState() => _MoodBottomSheetState();
}

class _MoodBottomSheetState extends State<MoodBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _sheetController;
  late Animation<Offset> _slideAnimation;
  Mood? _selectedMood;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.currentMood;

    _sheetController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _sheetController,
      curve: Curves.easeOutCubic,
    ));

    _sheetController.forward();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _selectMood(Mood mood) {
    if (_isClosing) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _selectedMood = mood;
    });

    // Small delay for visual feedback before closing
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && !_isClosing) {
        _closeSheet(() => widget.onMoodSelected(mood));
      }
    });
  }

  void _closeSheet(VoidCallback? onComplete) {
    if (_isClosing) return;
    _isClosing = true;

    _sheetController.reverse().then((_) {
      Navigator.pop(context);
      onComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _closeSheet(null),
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {}, // Prevent tap from closing when tapping content
          child: AnimatedBuilder(
            animation: _sheetController,
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF18181B),
                        AppColors.background,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Title
                          Text(
                            'How are you feeling today?',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share your mood with your partner',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Mood Grid - 2 rows, 5 columns
                          _buildMoodGrid(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMoodGrid() {
    return Column(
      children: [
        // First row - 5 moods
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: Mood.values.take(5).map((mood) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _MoodCard(
                  mood: mood,
                  isSelected: _selectedMood == mood,
                  onTap: () => _selectMood(mood),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Second row - remaining 5 moods
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: Mood.values.skip(5).map((mood) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _MoodCard(
                  mood: mood,
                  isSelected: _selectedMood == mood,
                  onTap: () => _selectMood(mood),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Individual mood card with animations
class _MoodCard extends StatefulWidget {
  final Mood mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodCard({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<_MoodCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final moodColor = Color(widget.mood.colorValue);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isSelected ? 1.05 : _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isSelected
                      ? [
                          moodColor.withOpacity(0.3),
                          moodColor.withOpacity(0.1),
                        ]
                      : [
                          AppColors.surface,
                          const Color(0xFF1F1F23),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isSelected
                      ? moodColor.withOpacity(0.8)
                      : Colors.white.withOpacity(0.05),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: moodColor.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.mood.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.mood.label,
                    style: TextStyle(
                      color: widget.isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
