import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/config/theme/app_colors.dart';

enum WheelSource { bucketList, categories, custom }

class FortuneWheelScreen extends ConsumerStatefulWidget {
  const FortuneWheelScreen({super.key});

  @override
  ConsumerState<FortuneWheelScreen> createState() => _FortuneWheelScreenState();
}

class _FortuneWheelScreenState extends ConsumerState<FortuneWheelScreen>
    with SingleTickerProviderStateMixin {
  WheelSource _selectedSource = WheelSource.bucketList;
  final List<String> _customItems = [];
  final TextEditingController _customController = TextEditingController();
  
  late AnimationController _spinController;
  double _rotation = 0;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    
    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
        _showResult();
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Fortune Wheel',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // Subtitle
            Text(
              'Discover your next date adventure',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            
            // Wheel
            Expanded(
              child: Center(
                child: _buildWheel(),
              ),
            ),
            
            // Source Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _buildSourceSelector(),
            ),
            const SizedBox(height: 16),
            
            // Custom Input (if selected)
            if (_selectedSource == WheelSource.custom)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _buildCustomInput(),
              ),
            
            const SizedBox(height: 24),
            
            // Spin Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSpinning ? null : _spin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.casino, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        _isSpinning ? 'Spinning...' : 'SPIN!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWheel() {
    final items = _getWheelItems();
    
    if (items.isEmpty) {
      return Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 4),
        ),
        child: Center(
          child: Text(
            _selectedSource == WheelSource.custom
                ? 'Add some options below!'
                : 'No items available',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Wheel
        AnimatedBuilder(
          animation: _spinController,
          builder: (context, child) {
            final curvedValue = Curves.easeOutCubic.transform(_spinController.value);
            return Transform.rotate(
              angle: _rotation + curvedValue * 10 * math.pi,
              child: child,
            );
          },
          child: CustomPaint(
            size: const Size(280, 280),
            painter: _WheelPainter(items: items),
          ),
        ),
        
        // Center Circle
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        
        // Pointer
        Positioned(
          top: 0,
          child: Container(
            width: 0,
            height: 0,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(width: 15, color: Colors.transparent),
                right: BorderSide(width: 15, color: Colors.transparent),
                bottom: BorderSide(width: 30, color: AppColors.accent),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<WheelSource>(
        value: _selectedSource,
        isExpanded: true,
        dropdownColor: AppColors.surface,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
        items: const [
          DropdownMenuItem(
            value: WheelSource.bucketList,
            child: Text('Bucket List', style: TextStyle(color: AppColors.textPrimary)),
          ),
          DropdownMenuItem(
            value: WheelSource.categories,
            child: Text('Categories', style: TextStyle(color: AppColors.textPrimary)),
          ),
          DropdownMenuItem(
            value: WheelSource.custom,
            child: Text('Custom Input', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedSource = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildCustomInput() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Add an option...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addCustomItem,
              icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 32),
            ),
          ],
        ),
        if (_customItems.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _customItems.map((item) {
              return Chip(
                label: Text(item, style: const TextStyle(color: AppColors.textPrimary)),
                backgroundColor: AppColors.surface,
                deleteIcon: const Icon(Icons.close, size: 16),
                deleteIconColor: AppColors.textSecondary,
                onDeleted: () {
                  setState(() {
                    _customItems.remove(item);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _addCustomItem() {
    final text = _customController.text.trim();
    if (text.isNotEmpty && _customItems.length < 8) {
      setState(() {
        _customItems.add(text);
        _customController.clear();
      });
    }
  }

  List<String> _getWheelItems() {
    switch (_selectedSource) {
      case WheelSource.bucketList:
        // This would be populated from bucket list
        return ['Movie Night', 'Dinner Date', 'Walk in Park', 'Game Night', 'Cook Together'];
      case WheelSource.categories:
        return ['Movies', 'Food', 'Outdoors', 'Gaming', 'Creative', 'Relaxation'];
      case WheelSource.custom:
        return _customItems;
    }
  }

  void _spin() {
    final items = _getWheelItems();
    if (items.isEmpty) return;
    
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isSpinning = true;
      _rotation = math.Random().nextDouble() * 2 * math.pi;
    });
    
    _spinController.reset();
    _spinController.forward();
    
    // Haptic feedback during spin
    _triggerSpinHaptics();
  }

  Future<void> _triggerSpinHaptics() async {
    for (int i = 0; i < 20; i++) {
      await Future.delayed(Duration(milliseconds: 100 + i * 30));
      if (!_isSpinning) break;
      HapticFeedback.lightImpact();
    }
    HapticFeedback.heavyImpact();
  }

  void _showResult() {
    final items = _getWheelItems();
    if (items.isEmpty) return;
    
    // Calculate which segment the pointer landed on
    final totalRotation = _rotation + 10 * math.pi;
    final normalizedRotation = totalRotation % (2 * math.pi);
    final segmentAngle = (2 * math.pi) / items.length;
    final index = (items.length - (normalizedRotation / segmentAngle).floor() - 1) % items.length;
    
    final selectedItem = items[index];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.celebration,
                size: 48,
                color: AppColors.accent,
              ),
              const SizedBox(height: 16),
              const Text(
                'The wheel has spoken!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                selectedItem,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to activity planning or add to plans
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Let's Do It! 🎉",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Spin Again',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> items;
  
  _WheelPainter({required this.items});

  static const List<Color> _colors = [
    Color(0xFF7B61FF),
    Color(0xFFFF4B7D),
    Color(0xFFFFD166),
    Color(0xFF06D6A0),
    Color(0xFF118AB2),
    Color(0xFFEF476F),
    Color(0xFF073B4C),
    Color(0xFFFF8C42),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = (2 * math.pi) / items.length;
    
    for (int i = 0; i < items.length; i++) {
      final startAngle = i * segmentAngle - math.pi / 2;
      
      // Draw segment
      final paint = Paint()
        ..color = _colors[i % _colors.length]
        ..style = PaintingStyle.fill;
      
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          segmentAngle,
          false,
        )
        ..close();
      
      canvas.drawPath(path, paint);
      
      // Draw text
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + segmentAngle / 2);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: items[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      
      textPainter.paint(
        canvas,
        Offset(radius * 0.5 - textPainter.width / 2, -textPainter.height / 2),
      );
      
      canvas.restore();
    }
    
    // Draw border
    final borderPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
