class Product {
  final int id;
  final int storeId;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final String unit;
  final String barcode;
  final String imageAssetPath;
  final String imageUrl;

  Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.barcode,
    required this.imageAssetPath,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('name')) {
      final rawPrice = json['price'] ?? 0;
      final rawQuantity = json['quantity'] ?? 1;

      return Product(
        id: (json['id'] as num?)?.toInt() ?? 0,
        storeId: (json['storeId'] as num?)?.toInt() ?? 0,
        name: json['name'] ?? '',
        category: json['category'] ?? '',
        price: (rawPrice is num)
            ? rawPrice.toDouble()
            : double.tryParse(rawPrice.toString()) ?? 0,
        quantity: (rawQuantity is num)
            ? rawQuantity.toInt()
            : int.tryParse(rawQuantity.toString()) ?? 1,
        unit: json['unit'] ?? '',
        barcode: json['barcode'] ?? '',
        imageAssetPath: json['imageAssetPath'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
      );
    }

    final rawPrice = json['prix'] ?? 0;
    final rawQuantity = json['quantite'] ?? 1;

    final barcode = (json['code_barre'] ?? 0);

    return Product(
      id: barcode,
      storeId: json['rayon_id'] ?? 0,
      name: json['libelle'] ?? '',
      category: '',
      price: (rawPrice is num)
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice.toString()) ?? 0,
      quantity: (rawQuantity is num)
          ? rawQuantity.toInt()
          : int.tryParse(rawQuantity.toString()) ?? 1,
      unit: '',
      barcode: barcode.toString(),
      imageAssetPath: json['image'] ?? '',
      imageUrl: json['image'] ?? '',
    );
  }
}