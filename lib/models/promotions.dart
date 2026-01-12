import 'package:flutter/material.dart';

class Shop {
  String location;
  double km;
  IconData icon;
  bool isFavorite;

  Shop({
    required this.location,
    required this.km,
    required this.icon,
    this.isFavorite = false,
  });
}
