import 'package:flutter/material.dart';
import 'package:heartbit/config/design_tokens/design_tokens.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

/// Base skeleton widget with shimmer effect
class Skeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;
  final Color? baseColor;
  final Color? highlightColor;

  const Skeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? DesignTokens.skeletonBaseColor,
      highlightColor: highlightColor ?? DesignTokens.skeletonHighlightColor,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton card widget for card-style loading states
class SkeletonCard extends StatelessWidget {
  final double? height;
  final EdgeInsets? margin;
  final bool showImage;
  final int contentLines;

  const SkeletonCard({
    super.key,
    this.height,
    this.margin,
    this.showImage = true,
    this.contentLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DesignTokens.skeletonBaseColor,
      highlightColor: DesignTokens.skeletonHighlightColor,
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: DesignTokens.space4),
        padding: const EdgeInsets.all(DesignTokens.space4),
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: DesignTokens.borderRadiusLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showImage)
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: DesignTokens.borderRadiusMd,
                ),
              ),
            if (showImage) const SizedBox(height: DesignTokens.space4),
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: DesignTokens.borderRadiusXs,
              ),
            ),
            const SizedBox(height: DesignTokens.space3),
            ...List.generate(contentLines, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.space2),
                child: Container(
                  width: index == contentLines - 1 ? 150 : double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: DesignTokens.borderRadiusXs,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Skeleton circle widget for profile pictures and avatars
class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsets? margin;

  const SkeletonCircle({
    super.key,
    this.size = 48,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DesignTokens.skeletonBaseColor,
      highlightColor: DesignTokens.skeletonHighlightColor,
      child: Container(
        width: size,
        height: size,
        margin: margin,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Skeleton text widget for lines of text
class SkeletonText extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;
  final double? width;
  final EdgeInsets? margin;

  const SkeletonText({
    super.key,
    this.lines = 2,
    this.lineHeight = 14,
    this.spacing = 8,
    this.width,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DesignTokens.skeletonBaseColor,
      highlightColor: DesignTokens.skeletonHighlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lines, (index) {
          final isLast = index == lines - 1;
          return Container(
            width: isLast ? (width ?? 150) : double.infinity,
            height: lineHeight,
            margin: EdgeInsets.only(
              bottom: isLast ? 0 : spacing,
              left: margin?.left ?? 0,
              right: margin?.right ?? 0,
              top: index == 0 ? (margin?.top ?? 0) : 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: DesignTokens.borderRadiusXs,
            ),
          );
        }),
      ),
    );
  }
}

/// Skeleton list widget for list loading states
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final bool showImage;
  final int contentLines;
  final EdgeInsets? padding;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.showImage = true,
    this.contentLines = 2,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DesignTokens.skeletonBaseColor,
      highlightColor: DesignTokens.skeletonHighlightColor,
      child: ListView.builder(
        padding: padding ?? const EdgeInsets.all(DesignTokens.space4),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: DesignTokens.space4),
            padding: const EdgeInsets.all(DesignTokens.space4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: DesignTokens.borderRadiusLg,
            ),
            child: Row(
              children: [
                if (showImage)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: DesignTokens.borderRadiusMd,
                    ),
                  ),
                if (showImage) const SizedBox(width: DesignTokens.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: DesignTokens.borderRadiusXs,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.space3),
                      ...List.generate(contentLines, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: DesignTokens.space2),
                          child: Container(
                            width: index == contentLines - 1 ? 100 : double.infinity,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: DesignTokens.borderRadiusXs,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton grid widget for grid loading states
class SkeletonGrid extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final double childAspectRatio;
  final EdgeInsets? padding;

  const SkeletonGrid({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.childAspectRatio = 1.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DesignTokens.skeletonBaseColor,
      highlightColor: DesignTokens.skeletonHighlightColor,
      child: GridView.builder(
        padding: padding ?? const EdgeInsets.all(DesignTokens.space4),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: DesignTokens.space4,
          mainAxisSpacing: DesignTokens.space4,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: DesignTokens.borderRadiusLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(DesignTokens.radiusLg),
                        topRight: const Radius.circular(DesignTokens.radiusLg),
                        bottomLeft: Radius.circular(index % 2 == 0 ? DesignTokens.radiusLg : 0),
                        bottomRight: Radius.circular(index % 2 == 0 ? 0 : DesignTokens.radiusLg),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.space3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: DesignTokens.borderRadiusXs,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.space2),
                      Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: DesignTokens.borderRadiusXs,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton shimmer wrapper for custom content
class SkeletonShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? DesignTokens.skeletonBaseColor,
      highlightColor: highlightColor ?? DesignTokens.skeletonHighlightColor,
      child: child,
    );
  }
}

/// Dashboard-specific skeleton loading
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            children: [
              const SkeletonCircle(size: 48),
              const SizedBox(width: DesignTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonText(lines: 1, lineHeight: 20, width: 150),
                    const SizedBox(height: DesignTokens.space2),
                    SkeletonText(lines: 1, lineHeight: 14, width: 100),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space5),
          // Pet/Egg skeleton
          SkeletonCard(height: 200, showImage: false, contentLines: 1),
          const SizedBox(height: DesignTokens.space5),
          // Daily question skeleton
          SkeletonCard(height: 150, showImage: false, contentLines: 3),
          const SizedBox(height: DesignTokens.space5),
          // Connection status skeleton
          Row(
            children: [
              Expanded(
                child: Skeleton(
                  width: double.infinity,
                  height: 100,
                  borderRadius: DesignTokens.radiusLg,
                ),
              ),
              const SizedBox(width: DesignTokens.space4),
              Expanded(
                child: Skeleton(
                  width: double.infinity,
                  height: 100,
                  borderRadius: DesignTokens.radiusLg,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
