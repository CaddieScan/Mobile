import 'package:caddiescan/components/prices_shop_map.dart';
import 'package:flutter/material.dart';

import 'components/container_map.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // l'input de recherche
        title: Text("Carte - Nom du magasin"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShopMap(),
            PricesContainerMap(),
          ],
        ),
      ),
    );
  }
}
