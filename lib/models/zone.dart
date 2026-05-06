import 'package:flutter/material.dart';
class Zone {
  double x1;
  double y1;
  double x2;
  double y2;
  String libelle;

  Zone({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.libelle,
  });

  static Zone fromJson(Map<String, dynamic> json) {
    return Zone(
      x1: (json["point1_x"] as num).toDouble(),
      y1: (json["point1_y"] as num).toDouble(),
      x2: (json["point2_x"] as num).toDouble(),
      y2: (json["point2_y"] as num).toDouble(),
      libelle: json["libelle"],
    );
  }
}