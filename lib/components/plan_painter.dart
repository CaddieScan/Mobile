import 'package:flutter/material.dart';
import 'package:caddiescan/models/zone.dart';

class PlanPainter extends CustomPainter {
  final List<Zone> zones;
  final double scale;

  PlanPainter(this.zones, {this.scale = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    for (var zone in zones) {
      // Avec le nouveau format, left/top sont déjà x et y
      final rect = Rect.fromLTWH(
          zone.x * scale,
          zone.y * scale,
          zone.w * scale,
          zone.h * scale
      );

      // Dessin du rectangle (Rayon)
      final fillPaint = Paint()
        ..color = Colors.grey.withOpacity(0.4) // Couleur plus neutre type "plan"
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = Colors.blueGrey
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, borderPaint);

      // Dessin du texte (Nom du rayon)
      if (zone.w * scale > 20) { // On ne dessine le texte que si la zone est assez grande
        final textPainter = TextPainter(
          text: TextSpan(
            text: zone.name,
            style: TextStyle(
                color: Colors.blueGrey[800],
                fontSize: 10,
                fontWeight: FontWeight.bold
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(maxWidth: zone.w * scale);

        // Centrage du texte
        final offset = Offset(
          rect.left + (rect.width - textPainter.width) / 2,
          rect.top + (rect.height - textPainter.height) / 2,
        );

        textPainter.paint(canvas, offset);
      }
    }
  }

  @override
  bool shouldRepaint(PlanPainter oldDelegate) =>
      oldDelegate.zones != zones || oldDelegate.scale != scale;
}