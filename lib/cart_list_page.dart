import 'package:flutter/material.dart';

import 'components/product_card.dart';
import 'models/product.dart';

class CartListPage extends StatefulWidget {
  const CartListPage({super.key});

  @override
  State<CartListPage> createState() => CartListPageState();
}

class CartListPageState extends State<CartListPage> {
  // produits en dur du panier
  final List<Product> cartItems = [
    Product(name: 'Kinder Bueno', price: 4.25, quantity: 2),
    Product(name: "Jus d'orange 1L", price: 2.50, quantity: 1),
    Product(name: 'Tablette de chocolat', price: 1.80, quantity: 3),
  ];

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
