import 'dart:convert';
import 'dart:ffi';

class Product {
  final int barcode;
  final int rayonId;
  final String libelle;
  final double price;
  final String image;

  Product({
    required this.barcode,
    required this.rayonId,
    required this.libelle,
    required this.price,
    required this.image,
  });

  static Product fromJson(Map<String, dynamic> json) {
    return Product(
        barcode: json['code_barre'],
        rayonId: json['rayon_id'],
        libelle: json['libelle'],
        image: json['image'],
        price: json['prix'],

    );
  }

  }



