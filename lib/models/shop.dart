import 'dart:convert';

import 'package:flutter/material.dart';

class Shop {
  int id;
  String location;
  double km;
  double latitude;
  double longitude;
  IconData icon;
  bool isFavorite;

  Shop({
    required this.id,
    required this.location,
    required this.km,
    required this.latitude,
    required this.longitude,
    required this.icon,
    this.isFavorite = false,
  });

  static Shop fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? 0,
      location: json['libelle'] ?? 'Inconnu',
      km: json['km'] ?? 0.0,
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      icon: Icons.storefront,
      isFavorite: json['is_favorite'] ?? false,
    );
  }
}
