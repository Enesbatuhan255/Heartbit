import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/config/design_tokens/design_tokens.dart';
import 'package:heartbit/core/widgets/empty_states.dart';
import '../providers/memory_vault_provider.dart';
import '../../domain/entities/memory.dart';

class MemoryVaultScreen extends ConsumerStatefulWidget {
  const MemoryVaultScreen({super.key});

  @override
  ConsumerState<MemoryVaultScreen> createState() => _MemoryVaultScreenState();
}

class _MemoryVaultScreenState extends ConsumerState<MemoryVaultScreen> {
  bool _isUploading = false;

  Future<void> _pickAndAddMemory() async {
    final picker = ImagePicker();
    XFile? image;
    
    try {
      image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compress image quality to 70%
        maxWidth: 1024,   // Resize image if wider than 1024px
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Galeri açılırken hata oluştu: $e'), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    if (image == null) {
      debugPrint('Image picker cancelled');
      return;
    }
    debugPrint('Image picked: ${image.path}');
    if (!mounted) return;

    // Show bottom sheet for title & description
    final titleController = TextEditingController();
    final descController = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLg)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: DesignTokens.space5, right: DesignTokens.space5, top: DesignTokens.space5,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + DesignTokens.space5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.space5),
              Text(
                'Anı Detayları',
                style: DesignTokens.heading4(color: AppColors.textPrimary),
              ),
              const SizedBox(height: DesignTokens.space4),
              TextField(
                controller: titleController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Başlık (opsiyonel)',
                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: DesignTokens.borderRadiusMd,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.space3),
              TextField(
                controller: descController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Bu anı hakkında bir şeyler yaz...',
                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: DesignTokens.borderRadiusMd,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.space5),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: DesignTokens.paddingVertical4,
                    shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadiusMd),
                    elevation: 0,
                  ),
                  child: Text('Kaydet 💕', style: DesignTokens.labelLarge(color: Colors.white, weight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );

    debugPrint('Bottom sheet result: $confirmed');
    if (confirmed != true || !mounted) return;

    // Show loading
    setState(() => _isUploading = true);

    try {
      // Save the memory
      await ref.read(memoryControllerProvider.notifier).addMemory(
        imagePath: image.path,
        date: DateTime.now(),
        description: descController.text.isEmpty ? ' ' : descController.text,
        title: titleController.text.isEmpty ? null : titleController.text,
      );
      debugPrint('Memory saved successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anı başarıyla kaydedildi! ✨'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving memory: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // Helper to group memories
  Map<String, List<Memory>> _groupMemories(List<Memory> memories) {
    final groups = <String, List<Memory>>{};
    for (final memory in memories) {
      final key = '${_monthName(memory.date.month)} ${memory.date.year}';
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(memory);
    }
    return groups;
  }

  String _monthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final memoriesAsync = ref.watch(memoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: memoriesAsync.when(
        data: (memories) {
          if (memories.isEmpty) {
            return EmptyMemoriesState(
              onAddMemory: _pickAndAddMemory,
            );
          }

          final grouped = _groupMemories(memories);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                pinned: true,
                expandedHeight: 120,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                  title: Text(
                    'Anı Kutusu',
                    style: DesignTokens.heading3(color: AppColors.textPrimary),
                  ),
                ),
              ),

              for (var group in grouped.entries) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4, height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: DesignTokens.borderRadiusXs,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space3),
                        Text(
                          group.key,
                          style: DesignTokens.heading4(color: AppColors.textPrimary),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space3, vertical: DesignTokens.space1),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: DesignTokens.borderRadiusSm,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '${group.value.length} Anı',
                            style: DesignTokens.labelSmall(
                              color: AppColors.textSecondary,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: DesignTokens.space3,
                    crossAxisSpacing: DesignTokens.space3,
                    childCount: group.value.length,
                    itemBuilder: (context, index) {
                      final memory = group.value[index];
                      // Random aspect ratio based on ID hash for consistent look
                      final random = Random(memory.id.hashCode);
                      // Use mostly 0.75 (portrait) but some 1.0 (square)
                      final aspectRatio = random.nextBool() ? 0.75 : 0.85; 

                      return _MemoryCard(
                        memory: memory,
                        aspectRatio: aspectRatio,
                        onTap: () => _showMemoryDetail(context, memory),
                        onLongPress: () => _deleteMemory(context, memory.id),
                      );
                    },
                  ),
                ),
              ],
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text('Hata: $e', style: const TextStyle(color: AppColors.error)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndAddMemory,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text('Yeni Anı', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.collections_bookmark_outlined,
                  size: 80,
                  color: AppColors.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Anı Kutusu Boş',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Henüz hiç anı biriktirmediniz.\nİlk fotoğrafınızı ekleyerek başlayın!',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndAddMemory,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text('İlk Anıyı Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showMemoryDetail(BuildContext context, dynamic memory) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Hero(
                              tag: 'memory_img_${memory.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  child: CachedNetworkImage(
                                    imageUrl: memory.imageUrl,
                                    width: double.infinity,
                                    height: 450,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: 450,
                                      color: AppColors.background,
                                      child: const Center(child: CircularProgressIndicator()),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${memory.date.day} ${_monthName(memory.date.month)} ${memory.date.year}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 28),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteMemory(context, memory.id);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                if (memory.title != null && memory.title!.isNotEmpty) ...[
                                  Text(
                                    memory.title!,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                Text(
                                  memory.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteMemory(BuildContext context, String memoryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Anıyı Sil',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bu anıyı silmek istediğinize emin misiniz? Geri dönüşü yoktur.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('SİL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(memoryControllerProvider.notifier).deleteMemory(memoryId);
    }
  }
}

class _MemoryCard extends StatelessWidget {
  final dynamic memory;
  final double aspectRatio;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _MemoryCard({
    required this.memory,
    required this.aspectRatio,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Hero(
        tag: 'memory_img_${memory.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: memory.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surface,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surface,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                  
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.0, 0.5, 0.75, 1.0],
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (memory.title != null && memory.title!.isNotEmpty)
                          Text(
                            memory.title!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 10, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              '${memory.date.day}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Inkwell for ripple
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      onLongPress: onLongPress,
                      splashColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
