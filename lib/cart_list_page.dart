import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'components/product_card.dart';
import 'models/product.dart';
import 'services/cart_service.dart';

class CartListPage extends StatefulWidget {
  const CartListPage({super.key});

  @override
  State<CartListPage> createState() => CartListPageState();
}

class CartListPageState extends State<CartListPage> {
  final List<Product> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCartProducts();
  }

  // on charge tous les produits du panier en cours
  Future<void> loadCartProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final cartId = await CartService.getCartId();

      if (cartId == null) {
        setState(() {
          cartItems.clear();
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Aucun panier en cours'), backgroundColor: Colors.red),
        );
        return;
      }

      final String baseUrl =
          dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
      final response = await http.get(
        Uri.parse('$baseUrl/cart/$cartId/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          cartItems
            ..clear()
            ..addAll(
              data
                  .whereType<Map<String, dynamic>>()
                  .map((item) => Product.fromJson(item)),
            );
          isLoading = false;
        });
        return;
      }

      if (response.statusCode == 404) {
        await CartService.clearCartId();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Panier non trouvé'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur (HTTP ${response.statusCode})'), backgroundColor: Colors.red),
        );
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // calculer le prix total
  double get totalPrice {
    return cartItems.fold(
      0,
      (total, current) => total + (current.price * current.quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Votre panier'),
        actions: [
          IconButton(
            onPressed: loadCartProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
       body: isLoading
           ? const Center(child: CircularProgressIndicator())
           : SingleChildScrollView(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           children: [
             if (!isLoading && cartItems.isEmpty)
               const Padding(
                 padding: EdgeInsets.only(bottom: 12),
                 child: Text('Votre panier est vide.'),
               ),

            // liste des produits
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final product = cartItems[index];

                return ProductCard(product: product);
              },
            ),

            // total et économies
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${totalPrice.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Economies:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '0€',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
