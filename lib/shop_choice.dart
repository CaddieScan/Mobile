import 'package:flutter/material.dart';
import 'components/section_header.dart';
import 'components/shop_choice_card.dart';
import 'models/shop.dart';

class ShopChoicePage extends StatefulWidget {
  const ShopChoicePage({super.key});

  @override
  State<ShopChoicePage> createState() => ShopChoicePageState();
}

class ShopChoicePageState extends State<ShopChoicePage> {
  final List<Shop> shops = [
    Shop(location: 'Auchan', km: 3.6, icon: Icons.storefront, isFavorite: true),
    Shop(location: 'Intermarché', km: 4.2, icon: Icons.storefront),
    Shop(location: 'Aldi', km: 6.8, icon: Icons.storefront),
  ];

  @override
  void initState() {
    super.initState();
    shops.sort((a, b) => a.km.compareTo(b.km));
  }

  void toggleFavorite(int index) {
    setState(() {
      shops[index].isFavorite = !shops[index].isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF007AFF)),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Choix du magasin',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF007AFF), size: 36),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                // affichage de la liste des magasins en favoris
                const SectionHeader(title: 'Favoris'),
                for (int i = 0; i < shops.length; i++)
                  if (shops[i].isFavorite == true)
                    ShopChoiceCard(
                      location: shops[i].location,
                      km: shops[i].km,
                      icon: shops[i].icon,
                      isFavorite: shops[i].isFavorite,
                      onFavoritePressed: () => toggleFavorite(i),
                      onPressed: () {
                        Navigator.pushNamed(context, '/scan');
                      },
                    ),
                // si aucun favori, afficher qu'il n'y en a pas
                if (shops.where((shop) => shop.isFavorite).isEmpty)
                  const Center(child: Text('Aucun favori')),

                const SizedBox(height: 24),

                const SectionHeader(title: 'A proximité'),
                // affichage de la liste des magasins à proximité
                for (int i = 0; i < shops.length; i++)
                  ShopChoiceCard(
                    location: shops[i].location,
                    km: shops[i].km,
                    icon: shops[i].icon,
                    isFavorite: shops[i].isFavorite,
                    onFavoritePressed: () => toggleFavorite(i),
                    onPressed: () {
                      Navigator.pushNamed(context, '/scan');
                    },
                  ),
                // si aucun magasin, afficher qu'il n'y en a pas
                if (shops.isEmpty)
                  const Center(child: Text('Aucun magasin')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
