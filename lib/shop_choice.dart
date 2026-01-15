import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'components/section_header.dart';
import 'components/shop_choice_card.dart';
import 'models/shop.dart';

class ShopChoicePage extends StatefulWidget {
  const ShopChoicePage({super.key});

  @override
  State<ShopChoicePage> createState() => ShopChoicePageState();
}

class ShopChoicePageState extends State<ShopChoicePage> {
  late List<Shop> shops = [
    Shop(location: 'Auchan', km: 3.6, icon: Icons.storefront, isFavorite: true),
    Shop(location: 'Intermarché', km: 4.2, icon: Icons.storefront),
    Shop(location: 'Aldi', km: 6.8, icon: Icons.storefront),
  ];

  // requête pour trouver tous les magasins en bdd (en attendant)
  // il renvoie une liste de Shops
  Future<http.Response> fetchScan() {
    return http.get(
      Uri.parse(
        'http://10.0.2.2:8000/shop/all',
      ),
    );
  }

  void initShopList() {
    fetchScan().then((response) {
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          shops = [];
          for (int i = 0; i < data.length; i++) {
            shops.add(Shop.fromJson(data[i]));
          }
          shops.sort((a, b) => a.km.compareTo(b.km));
        });
      } else {
        print("Magasins non trouvés, status: ${response.statusCode}");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initShopList();
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
                if (!shops.any((shop) => shop.isFavorite))
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
