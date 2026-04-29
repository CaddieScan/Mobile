class Product {
  final int barcode;
  final int rayonId;
  final String libelle;
  final double price;
  final String image;
  final int quantity;

  Product({
    required this.barcode,
    required this.rayonId,
    required this.libelle,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  static Product fromJson(Map<String, dynamic> json) {
    final dynamic rawPrice = json['prix'] ?? json['price'] ?? 0;
    final dynamic rawQuantity = json['quantite'] ?? json['quantity'] ?? 1;

    return Product(
      barcode: json['code_barre'],
      rayonId: json['rayon_id'] ?? 0,
      libelle: json['libelle'] ?? '',
      image: json['image'] ?? '',
      price: (rawPrice is num)
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice.toString()) ?? 0,
      quantity: (rawQuantity is int)
          ? rawQuantity
          : int.tryParse(rawQuantity.toString()) ?? 1,
    );
  }

}



