import 'package:flutter/material.dart';
class Zone {
  final String id;
  final String name;
  final double x;
  final double y;
  final double w;
  final double h;

  Zone({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'],
      name: json['name'],
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      w: (json['w'] as num).toDouble(),
      h: (json['h'] as num).toDouble(),
    );
  }
}