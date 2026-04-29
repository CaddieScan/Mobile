import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client client;
  final String baseUrl;

  // on l'utilise pour le moment uniquement pour les tests mais à terme on l'appliquera pour toute l'application
  ApiService({http.Client? client, this.baseUrl = 'http://127.0.0.1:8000'})
      : client = client ?? http.Client();

  Future<Map<String, dynamic>> scanProduct(String barcode) async {
    final response = await client.get(
      Uri.parse('$baseUrl/product/get_product_by_barcode?barcode=$barcode'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur API lors du scan');
    }
  }

  Future<Map<String, dynamic>> addToCart(String barcode, int quantity) async {
    final response = await client.post(
      Uri.parse('$baseUrl/cart/product/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"cart_id": 1, "produit_id": barcode, "quantity": quantity}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur API lors de l\'ajout au panier');
    }
  }

  Future<List<dynamic>> getProximityShops(int userId, double latitude, double longitude) async {
    final response = await client.post(
      Uri.parse('$baseUrl/shop/proximity?user_id=$userId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "latitude": latitude,
        "longitude": longitude,
        "radius_km": 50
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur API lors de la récupération des magasins');
    }
  }
}
