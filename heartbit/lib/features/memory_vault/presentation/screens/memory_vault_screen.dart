import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/memory_vault_provider.dart';
import '../../domain/entities/memory.dart';

// ─── Premium palette (aynı dashboard ile tutarlı) ────────────────────────
class _P {
  static const bg = Color(0xFFFDF6F0);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0x18000000); // %9 black
  static const gold = Color(0xFFC8A96E);
  static const gold2 = Color(0xFFE8C87E);
  static const text = Color(0xFF2D2B3D); // deep purple-gray
  static const muted = Color(0x592D2B3D); // %35 text
  static const error = Color(0xFFEF4444);
}

class MemoryVaultScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const MemoryVaultScreen({super.key, this.onBack});

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
        imageQuality: 70,
        maxWidth: 1024,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Galeri açılırken hata: $e'),
              backgroundColor: _P.error),
        );
      }
      return;
    }

    if (image == null || !mounted) return;

    final titleController = TextEditingController();
    final descController = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: _P.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _P.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Anı Detayları',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _P.text,
                ),
              ),
              const SizedBox(height: 16),
              _premiumTextField(
                controller: titleController,
                hint: 'Başlık (opsiyonel)',
              ),
              const SizedBox(height: 10),
              _premiumTextField(
                controller: descController,
                hint: 'Bu anı hakkında bir şeyler yaz...',
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: _P.gold,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x44C8A96E),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Kaydet',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5D4E37),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isUploading = true);
    try {
      await ref.read(memoryControllerProvider.notifier).addMemory(
            imagePath: image.path,
            date: DateTime.now(),
            description:
                descController.text.isEmpty ? ' ' : descController.text,
            title: titleController.text.isEmpty ? null : titleController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Anı kaydedildi ✨'),
            backgroundColor: _P.gold,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: _P.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Widget _premiumTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: _P.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _P.muted, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFFFF5EE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _P.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _P.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _P.gold.withOpacity(0.5)),
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }

  Map<String, List<Memory>> _groupMemories(List<Memory> memories) {
    final groups = <String, List<Memory>>{};
    for (final memory in memories) {
      final key = '${_monthName(memory.date.month)} ${memory.date.year}';
      groups.putIfAbsent(key, () => []).add(memory);
    }
    return groups;
  }

  String _monthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final memoriesAsync = ref.watch(memoriesProvider);

    return Scaffold(
      backgroundColor: _P.bg,
      body: memoriesAsync.when(
        data: (memories) {
          if (memories.isEmpty) return _buildEmptyState();

          final grouped = _groupMemories(memories);

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: _P.bg,
                elevation: 0,
                pinned: true,
                expandedHeight: 110,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: _P.text, size: 18),
                  onPressed: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                  title: Text(
                    'Anı Kutusu',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: _P.text,
                    ),
                  ),
                ),
              ),

              // Uploading indicator
              if (_isUploading)
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    color: _P.gold,
                    minHeight: 2,
                  ),
                ),

              // Memory groups
              for (final group in grouped.entries) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                    child: Row(
                      children: [
                        // Gold accent bar
                        Container(
                          width: 3,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _P.gold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          group.key,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _P.text,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _P.gold.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _P.gold.withOpacity(0.2)),
                          ),
                          child: Text(
                            '${group.value.length} Anı',
                            style: const TextStyle(
                              fontSize: 10,
                              color: _P.gold,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
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
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childCount: group.value.length,
                    itemBuilder: (context, index) {
                      final memory = group.value[index];
                      final random = Random(memory.id.hashCode);
                      final aspectRatio = random.nextBool() ? 0.75 : 0.9;
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

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: _P.gold),
        ),
        error: (e, _) => Center(
          child: Text('Hata: $e', style: const TextStyle(color: _P.error)),
        ),
      ),

      // FAB — premium gold style
      floatingActionButton: GestureDetector(
        onTap: _pickAndAddMemory,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: _P.gold,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55C8A96E),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo_outlined,
                  color: Color(0xFF5D4E37), size: 18),
              SizedBox(width: 8),
              Text(
                'Yeni Anı',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5D4E37),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      child: Column(
        children: [
          // Mini header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: _P.text, size: 18),
                  onPressed: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon container
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _P.gold.withOpacity(0.06),
                      border: Border.all(color: _P.gold.withOpacity(0.15)),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.auto_stories_outlined,
                        size: 42,
                        color: _P.gold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Henüz Anı Yok',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: _P.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'İlk fotoğrafınızı ekleyerek\nanılarınızı biriktirmeye başlayın.',
                    style: TextStyle(
                      fontSize: 13,
                      color: _P.muted,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _pickAndAddMemory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        color: _P.gold,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x44C8A96E),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              color: Color(0xFF5D4E37), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'İlk Anıyı Ekle',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5D4E37),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMemoryDetail(BuildContext context, dynamic memory) {
    final hasImage = (memory.imageUrl is String) &&
        (memory.imageUrl as String).trim().isNotEmpty;

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
                color: _P.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 12),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _P.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header visual
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Hero(
                              tag: 'memory_img_${memory.id}',
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: hasImage
                                      ? CachedNetworkImage(
                                          imageUrl: memory.imageUrl,
                                          width: double.infinity,
                                          height: 420,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            height: 420,
                                            color: _P.surface,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                  color: _P.gold),
                                            ),
                                          ),
                                        )
                                      : _TextOnlyPoster(
                                          title: memory.title as String?,
                                          description:
                                              memory.description as String? ??
                                                  '',
                                          height: 420,
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
                                // Date & delete row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _P.gold.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: _P.gold.withOpacity(0.2)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 12,
                                            color: _P.gold,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${memory.date.day} ${_monthName(memory.date.month)} ${memory.date.year}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: _P.gold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: _P.error,
                                          size: 24),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteMemory(context, memory.id);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Title
                                if (memory.title != null &&
                                    memory.title!.isNotEmpty) ...[
                                  Text(
                                    memory.title!,
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600,
                                      color: _P.text,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Description
                                Text(
                                  memory.description,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: _P.muted,
                                    height: 1.7,
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
        backgroundColor: _P.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Anıyı Sil',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _P.text,
          ),
        ),
        content: const Text(
          'Bu anıyı silmek istediğinize emin misiniz?',
          style: TextStyle(color: _P.muted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç', style: TextStyle(color: _P.muted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _P.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sil',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(memoryControllerProvider.notifier).deleteMemory(memoryId);
    }
  }
}

// ─── Memory Card ─────────────────────────────────────────────────────────────
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
    final hasImage = (memory.imageUrl is String) &&
        (memory.imageUrl as String).trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Hero(
        tag: 'memory_img_${memory.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  CachedNetworkImage(
                    imageUrl: memory.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: const Color(0xFFFFF5EE)),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFFFF5EE),
                      child: const Icon(Icons.broken_image, color: _P.muted),
                    ),
                  )
                else
                  _TextOnlyPoster(
                    title: memory.title as String?,
                    description: memory.description as String? ?? '',
                  ),

                // Bottom gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),

                // Content overlay
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (memory.title != null && memory.title!.isNotEmpty)
                        Text(
                          memory.title!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 2),
                      // Gold date badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _P.gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _P.gold.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${memory.date.day}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: _P.gold2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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

class _TextOnlyPoster extends StatelessWidget {
  final String? title;
  final String description;
  final double? height;

  const _TextOnlyPoster({
    this.title,
    required this.description,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _P.gold.withOpacity(0.14),
            const Color(0xFFFFF5EE),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _P.gold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.menu_book_rounded, size: 18, color: _P.gold),
            ),
            const SizedBox(height: 10),
            Text(
              (title != null && title!.trim().isNotEmpty)
                  ? title!.trim()
                  : 'Hikaye',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _P.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description.trim().isEmpty ? 'Metin anisi' : description.trim(),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _P.muted,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
