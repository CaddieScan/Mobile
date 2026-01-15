import 'dart:convert';

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

  static Shop fromJson(Map<String, dynamic> json) {
    return Shop(
      location: json['libelle'] ?? 'Inconnu',
      km: 0.0,
      icon: Icons.storefront,
      isFavorite: false,
    );
  }
}
