import 'package:flutter/material.dart';
import 'package:caddiescan/models/zone.dart';

class PlanPainter extends CustomPainter {
  final List<Zone> zones;
  final String? highlightedName;
  final double scale;

  PlanPainter(this.zones, {this.highlightedName, this.scale = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    if (zones.isEmpty) return;

    // Log pour s'assurer de ce qu'on compare
    print("PlanPainter - Nom reçu : '$highlightedName'");

    for (int i = 0; i < zones.length; i++) {
      var zone = zones[i];
      final rect = Rect.fromLTWH(
        zone.x * scale,
        zone.y * scale,
        zone.w * scale,
        zone.h * scale,
      );

      // --- NOUVELLE LOGIQUE CONDITIONNELLE ---
      // 1. Si aucun nom n'est recherché : fond neutre
      // 2. Si un nom est cherché : on surbrille le premier élément trouvé (index 0) ou celui qui correspond
      bool isHighlighted = false;

      if (highlightedName != null && highlightedName!.isNotEmpty) {
        // Option A : Surbrillance du 1er élément UNIQUEMENT lors d'une recherche
        if (i == 0) {
          isHighlighted = true;
        }
      }

      final fillPaint = Paint()
        ..color = isHighlighted
            ? Colors.orange.withOpacity(0.8) // Actif uniquement lors d'une recherche
            : Colors.blue.withOpacity(0.1)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = isHighlighted ? Colors.deepOrange : Colors.blueGrey
        ..strokeWidth = isHighlighted ? 3.0 : 1.0
        ..style = PaintingStyle.stroke;

      // Dessin
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, borderPaint);

      // Texte
      if (zone.w > 10) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: zone.name,
            style: TextStyle(
              color: isHighlighted ? Colors.black : Colors.black54,
              fontSize: 10,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: zone.w * scale);

        textPainter.paint(
          canvas,
          Offset(
            rect.left + (rect.width - textPainter.width) / 2,
            rect.top + (rect.height - textPainter.height) / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PlanPainter oldDelegate) {
    return oldDelegate.highlightedName != highlightedName ||
        oldDelegate.zones != zones;
  }
}