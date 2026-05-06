class ProductByShop {
  final int barcode;
  final int rayonId;
  final String libelle;
  final double price;
  final String image;
  final int quantity;

  ProductByShop({
    required this.barcode,
    required this.rayonId,
    required this.libelle,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  static ProductByShop fromJson(Map<String, dynamic> json) {
    final rawPrice = json['prix'] ?? 0;
    final rawQuantity = json['quantite'] ?? 1;

    return ProductByShop(
      barcode: (json['code_barre'] as num?)?.toInt() ?? 0,
      rayonId: (json['rayon_id'] as num?)?.toInt() ?? 0,
      libelle: json['libelle'] ?? '',
      image: json['image'] ?? '',
      price: (rawPrice is num)
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice.toString()) ?? 0,
      quantity: (rawQuantity is num)
          ? rawQuantity.toInt()
          : int.tryParse(rawQuantity.toString()) ?? 1,
    );
  }
}