import 'package:flutter/material.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/drawing/domain/entities/drawing_session.dart';

class DrawingCanvas extends StatelessWidget {
  final List<DrawingPoint> points;

  const DrawingCanvas({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DrawingPainter(points),
      size: Size.infinite,
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  _DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round // Smooth corners
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool isStarting = true;

    // Convert normalized (0-1) to pixel coords
    final w = size.width;
    final h = size.height;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      // Check for marker (negative coords or isEnd)
      if (p.isEnd || p.x < 0) {
        isStarting = true;
        continue;
      }

      final px = p.x * w;
      final py = p.y * h;

      if (isStarting) {
        path.moveTo(px, py);
        isStarting = false;
      } else {
        path.lineTo(px, py);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
