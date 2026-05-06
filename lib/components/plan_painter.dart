import 'package:flutter/material.dart';
import 'package:caddiescan/models/zone.dart';

class ZoneDisplay {
  final double x1, y1, x2, y2;
  final String label;

  ZoneDisplay(this.x1, this.y1, this.x2, this.y2, this.label);
}

class PlanPainter extends CustomPainter {
  final List<Zone> zones;
  final double scale;

  PlanPainter(this.zones, {this.scale = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke;

    for (var zone in zones) {
      final left = (zone.x1 < zone.x2 ? zone.x1 : zone.x2) * scale;
      final top = (zone.y1 < zone.y2 ? zone.y1 : zone.y2) * scale;
      final width = (zone.x2 - zone.x1).abs() * scale;
      final height = (zone.y2 - zone.y1).abs() * scale;

      final rect = Rect.fromLTWH(left, top, width, height);

      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, borderPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: zone.libelle,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(maxWidth: width);

      final offset = Offset(
        left + (width - textPainter.width) / 2,
        top + (height - textPainter.height) / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}