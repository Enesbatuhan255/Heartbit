import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/config/design_tokens/design_tokens.dart';
import 'dart:ui';

class ActivityHubScreen extends ConsumerWidget {
  const ActivityHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Activity Hub',
          style: DesignTokens.heading4(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: DesignTokens.padding5,
          child: Column(
            children: [
              const Spacer(),
              // Header
              Text(
                '🎯 What\'s the plan tonight?',
                style: DesignTokens.heading2(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.space3),
              Text(
                'Choose how you want to decide',
                style: DesignTokens.bodyLarge(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.space7),
               
              // Two Cards
              Row(
                children: [
                  // Left Card: Let's Choose Together
                  Expanded(
                    child: _ModeCard(
                      icon: Icons.handshake_outlined,
                      title: "Let's Choose\nTogether",
                      subtitle: 'Safe Bet',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B61FF), Color(0xFF9B7DFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        context.push('/swipe-setup');
                      },
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space4),
                  // Right Card: Spin the Wheel
                  Expanded(
                    child: _ModeCard(
                      icon: Icons.casino_outlined,
                      title: 'Spin the\nWheel',
                      subtitle: 'Feeling Lucky?',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4B7D), Color(0xFFFF7B9D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        context.push('/fortune-wheel');
                      },
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              
              // Bucket List Link
              TextButton.icon(
                onPressed: () => context.push('/bucket-list'),
                icon: const Icon(Icons.checklist, color: AppColors.accent),
                label: const Text(
                  'View Bucket List',
                  style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DesignTokens.durationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: DesignTokens.borderRadiusLg,
            boxShadow: DesignTokens.shadowLg,
          ),
          child: ClipRRect(
            borderRadius: DesignTokens.borderRadiusLg,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: DesignTokens.borderRadiusLg,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      size: 56,
                      color: Colors.white,
                    ),
                    const SizedBox(height: DesignTokens.space4),
                    Text(
                      widget.title,
                      style: DesignTokens.heading4(color: Colors.white).copyWith(height: 1.2),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignTokens.space2),
                    Text(
                      widget.subtitle,
                      style: DesignTokens.bodySmall(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
