import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/product_by_shop.dart';

class ProductSearchList extends StatelessWidget {
  final List<Product> results;
  final void Function(Product product) onProductTap;

  const ProductSearchList({
    super.key,
    required this.results,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        color: Colors.white,
        child: ListView.separated(
          itemCount: results.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final product = results[index];
            return ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(product.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onProductTap(product),
            );
          },
        ),
      ),
    );
  }
}