import 'dart:async';
import 'package:caddiescan/components/plan_painter.dart';
import 'package:flutter/material.dart';
import 'package:caddiescan/models/zone.dart';


class ShopMap extends StatelessWidget {
  const ShopMap({super.key, required this.zones});
  final List<Zone> zones;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4,
      child: CustomPaint(
        size: const Size(300, 600),
        painter: PlanPainter(zones, scale: 20),
      ),
    );
  }
}
