import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import '../providers/memory_vault_provider.dart';

class _P {
  static const bg       = Color(0xFFFDF6F0);
  static const surface  = Color(0xFFFFFFFF);
  static const border   = Color(0x18000000);  // %9 black
  static const gold     = Color(0xFFC8A96E);
  static const text     = Color(0xFF2D2B3D);  // deep purple-gray
  static const muted    = Color(0x592D2B3D);  // %35 text
  static const error    = Color(0xFFEF4444);
  static const success  = Color(0xFF4ADE80);
}

class AddMemoryScreen extends ConsumerStatefulWidget {
  const AddMemoryScreen({super.key});

  @override
  ConsumerState<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends ConsumerState<AddMemoryScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source, maxWidth: 1920, maxHeight: 1920, imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      _showError('Fotoğraf seçilirken hata: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _P.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: _P.border, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Text('Fotoğraf Ekle',
                style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.w600, color: _P.text)),
              const SizedBox(height: 16),
              _sourceOption(Icons.camera_alt_outlined, 'Kamera', () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
              _sourceOption(Icons.photo_library_outlined, 'Galeri', () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5EE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _P.border),
        ),
        child: Row(children: [
          Icon(icon, color: _P.gold, size: 20),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(color: _P.text, fontSize: 15)),
        ]),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _P.gold, onPrimary: Color(0xFF5D4E37),
            surface: _P.surface, onSurface: _P.text,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveMemory() async {
    if (_selectedImage == null) { _showError('Lütfen bir fotoğraf seçin'); return; }
    if (_descriptionController.text.trim().isEmpty) { _showError('Lütfen bir açıklama yazın'); return; }
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final result = await ref.read(memoryControllerProvider.notifier).addMemory(
        imagePath: _selectedImage!.path,
        date: _selectedDate,
        description: _descriptionController.text.trim(),
        title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (result != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anı kaydedildi ✨'), backgroundColor: _P.success),
        );
      } else {
        _showError('Anı kaydedilirken hata oluştu');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Hata: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: _P.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _P.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _P.text, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Yeni Anı',
          style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.w600, color: _P.text)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: (_isLoading || _selectedImage == null) ? null : _saveMemory,
            child: _isLoading
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _P.gold))
              : const Text('Kaydet',
                  style: TextStyle(color: _P.gold, fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo picker
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: double.infinity, height: 240,
                decoration: BoxDecoration(
                  color: _P.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _P.border),
                ),
                child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_selectedImage!, fit: BoxFit.cover),
                          Positioned(
                            bottom: 10, right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.edit_outlined, color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text('Değiştir', style: TextStyle(color: Colors.white, fontSize: 11)),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _P.gold.withOpacity(0.08),
                          border: Border.all(color: _P.gold.withOpacity(0.2)),
                        ),
                        child: const Icon(Icons.add_photo_alternate_outlined, size: 26, color: _P.gold),
                      ),
                      const SizedBox(height: 12),
                      const Text('Fotoğraf Ekle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _P.text)),
                      const SizedBox(height: 4),
                      const Text('Galeriden veya kameradan seçin', style: TextStyle(fontSize: 12, color: _P.muted)),
                    ]),
              ),
            ),
            const SizedBox(height: 24),

            // Date
            _label('Tarih'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _P.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _P.border),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, color: _P.gold, size: 18),
                  const SizedBox(width: 12),
                  Text(DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate),
                    style: const TextStyle(fontSize: 15, color: _P.text)),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: _P.muted, size: 18),
                ]),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            _label('Başlık (İsteğe Bağlı)'),
            const SizedBox(height: 8),
            _field(controller: _titleController, hint: 'Örn: İlk Buluşmamız'),
            const SizedBox(height: 24),

            // Description
            _label('Açıklama'),
            const SizedBox(height: 8),
            _field(controller: _descriptionController,
              hint: 'Bu özel anınız hakkında neler hissediyorsunuz?',
              maxLines: 5, maxLength: 500),
            const SizedBox(height: 32),

            // Save button
            GestureDetector(
              onTap: (_isLoading || _selectedImage == null) ? null : _saveMemory,
              child: Opacity(
                opacity: (_isLoading || _selectedImage == null) ? 0.5 : 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _P.gold,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x44C8A96E), blurRadius: 14, offset: Offset(0, 4))],
                  ),
                  child: Center(
                    child: _isLoading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5D4E37)))
                      : const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.favorite_outline, color: Color(0xFF5D4E37), size: 18),
                          SizedBox(width: 8),
                          Text('Anıyı Kaydet', style: TextStyle(color: Color(0xFF5D4E37), fontWeight: FontWeight.w700, fontSize: 16)),
                        ]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text.toUpperCase(),
    style: const TextStyle(fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: _P.muted),
  );

  Widget _field({required TextEditingController controller, required String hint, int maxLines = 1, int? maxLength}) {
    return TextField(
      controller: controller, maxLines: maxLines, maxLength: maxLength,
      style: const TextStyle(color: _P.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _P.muted, fontSize: 14),
        filled: true, fillColor: _P.surface,
        counterStyle: const TextStyle(color: _P.muted, fontSize: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _P.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _P.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _P.gold.withOpacity(0.4))),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }
}