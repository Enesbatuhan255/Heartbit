import 'package:flutter/material.dart';
import 'package:heartbit/config/design_tokens/design_tokens.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:lottie/lottie.dart';

/// Base empty state widget with illustration, title, and action
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? lottieAsset;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customAction;
  final double illustrationSize;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.lottieAsset,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.customAction,
    this.illustrationSize = 200,
  }) : assert(
          lottieAsset != null || icon != null,
          'Either lottieAsset or icon must be provided',
        );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            if (lottieAsset != null)
              Lottie.asset(
                lottieAsset!,
                width: illustrationSize,
                height: illustrationSize,
                fit: BoxFit.contain,
              )
            else
              Container(
                width: illustrationSize,
                height: illustrationSize,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: illustrationSize * 0.4,
                  color: AppColors.primary.withOpacity(0.6),
                ),
              ),
            const SizedBox(height: DesignTokens.space5),
            // Title
            Text(
              title,
              style: DesignTokens.heading4(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: DesignTokens.space3),
              Text(
                subtitle!,
                style: DesignTokens.bodyMedium(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: DesignTokens.space6),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
            if (customAction != null) ...[
              const SizedBox(height: DesignTokens.space6),
              customAction!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for when there are no memories
class EmptyMemoriesState extends StatelessWidget {
  final VoidCallback? onAddMemory;

  const EmptyMemoriesState({super.key, this.onAddMemory});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Henüz Anı Yok',
      subtitle: 'İlk anınızı ekleyerek bu bölümü doldurmaya başlayın. Partnerinizle yaşadığınız güzel anıları burada saklayın.',
      icon: Icons.photo_library_outlined,
      actionLabel: 'Anı Ekle',
      onAction: onAddMemory,
    );
  }
}

/// Empty state for bucket list
class EmptyBucketListState extends StatelessWidget {
  final VoidCallback? onAddItem;

  const EmptyBucketListState({super.key, this.onAddItem});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Bucket List Boş',
      subtitle: 'Partnerinizle yapmak istediğiniz aktiviteleri ekleyin. Birlikte deneyimlemek istediğiniz şeyleri listeleyin.',
      icon: Icons.checklist_outlined,
      actionLabel: 'Aktivite Ekle',
      onAction: onAddItem,
    );
  }
}

/// Empty state for daily questions
class EmptyDailyQuestionState extends StatelessWidget {
  final VoidCallback? onRefresh;

  const EmptyDailyQuestionState({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Günlük Soru Hazırlanıyor',
      subtitle: 'Yeni sorular yükleniyor. Birazdan burada günlük sorularınızı görebileceksiniz.',
      icon: Icons.help_outline,
      customAction: onRefresh != null
          ? TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Yenile'),
            )
          : null,
    );
  }
}

/// Empty state for activity hub
class EmptyActivityHubState extends StatelessWidget {
  final VoidCallback? onExplore;

  const EmptyActivityHubState({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Keşfedilecek Aktivite Yok',
      subtitle: 'Şu anda görüntülenecek aktivite bulunmuyor. Yeni aktiviteler eklenene kadar bekleyin veya kendi aktivitenizi oluşturun.',
      icon: Icons.explore_outlined,
      actionLabel: 'Aktivite Oluştur',
      onAction: onExplore,
    );
  }
}

/// Empty state for achievements
class EmptyAchievementsState extends StatelessWidget {
  final VoidCallback? onViewActivities;

  const EmptyAchievementsState({super.key, this.onViewActivities});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Henüz Rozet Yok',
      subtitle: 'Aktiviteleri tamamladıkça rozetler kazanacaksınız. İlk rozetinizi kazanmak için aktivitelere katılın!',
      icon: Icons.emoji_events_outlined,
      actionLabel: 'Aktivitelere Git',
      onAction: onViewActivities,
    );
  }
}

/// Empty state for tasks
class EmptyTasksState extends StatelessWidget {
  final VoidCallback? onAddTask;

  const EmptyTasksState({super.key, this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Görev Listesi Boş',
      subtitle: 'Partnerinizle yapılacak görevleri ekleyin. Birbirinize sürprizler yapın veya ortak hedefler belirleyin.',
      icon: Icons.task_alt_outlined,
      actionLabel: 'Görev Ekle',
      onAction: onAddTask,
    );
  }
}

/// Empty state for no partner paired
class NoPartnerState extends StatelessWidget {
  final VoidCallback? onInvite;

  const NoPartnerState({super.key, this.onInvite});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Partnerinizi Ekleyin',
      subtitle: 'HeartBit\'in tüm özelliklerini kullanmak için partnerinizi davet edin. Birlikte anılar biriktirin!',
      icon: Icons.favorite_border,
      actionLabel: 'Davet Gönder',
      onAction: onInvite,
    );
  }
}

/// Empty state for search results
class EmptySearchState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClear;

  const EmptySearchState({
    super.key,
    required this.searchQuery,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Sonuç Bulunamadı',
      subtitle: '"$searchQuery" için sonuç bulunamadı. Farklı bir arama terimi deneyin.',
      icon: Icons.search_off_outlined,
      customAction: onClear != null
          ? TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              label: const Text('Aramayı Temizle'),
            )
          : null,
    );
  }
}

/// Empty state for error states
class ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Bir Hata Oluştu',
      subtitle: message ?? 'Bir şeyler yanlış gitti. Lütfen tekrar deneyin.',
      icon: Icons.error_outline,
      customAction: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            )
          : null,
    );
  }
}

/// Empty state for offline/network issues
class OfflineState extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Bağlantı Yok',
      subtitle: 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.',
      icon: Icons.wifi_off_outlined,
      customAction: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            )
          : null,
    );
  }
}

/// Mini empty state for compact spaces (lists, grids)
class MiniEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const MiniEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: DesignTokens.borderRadiusLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.primary.withOpacity(0.6),
          ),
          const SizedBox(height: DesignTokens.space3),
          Text(
            title,
            style: DesignTokens.heading5(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: DesignTokens.space2),
            Text(
              subtitle!,
              style: DesignTokens.bodySmall(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: DesignTokens.space4),
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 18),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated empty state with pulse effect
class AnimatedEmptyState extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AnimatedEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: widget.title,
      subtitle: widget.subtitle,
      icon: widget.icon,
      actionLabel: widget.actionLabel,
      onAction: widget.onAction,
      customAction: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.onAction != null && widget.actionLabel != null
            ? ElevatedButton.icon(
                onPressed: widget.onAction,
                icon: const Icon(Icons.add),
                label: Text(widget.actionLabel!),
              )
            : null,
      ),
    );
  }
}
