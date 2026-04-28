import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'components/section_header.dart';
import 'components/shop_choice_card.dart';
import 'models/shop.dart';

class ShopChoicePage extends StatefulWidget {
  const ShopChoicePage({super.key});

  @override
  State<ShopChoicePage> createState() => ShopChoicePageState();
}

class ShopChoicePageState extends State<ShopChoicePage> {
  late List<Shop> shops = [];

  // requête pour trouver tous les magasins en bdd avec position
  // il renvoie une liste de Shops
  Future<http.Response> fetchScan(double lat, double lon) {
    return http.post(
      Uri.parse('http://10.57.33.97:8000/shop/proximity'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "latitude": lat,
        "longitude": lon,
        "radius_km": 50
      }),
    );
  }

  void initShopList() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Les services de localisation sont désactivés.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Les permissions de localisation sont refusées.');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print('Les permissions de localisation sont refusées de façon permanente.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    fetchScan(position.latitude, position.longitude).then((response) {
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          shops = [];
          for (int i = 0; i < data.length; i++) {
            shops.add(Shop.fromJson(data[i]));
          }
          shops.sort((a, b) => a.km.compareTo(b.km));
          print(shops[0].km);
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

  void toggleFavorite(int index) async {
    print(index);
    final shop = shops[index];
    print(shop.id);
    
    // si on met en favoris le magasin, on appelle l'API
    if (!shop.isFavorite) {
      try {
        final response = await http.post(
          Uri.parse('http://10.57.33.97:8000/shop/favorite'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "shop_id": shop.id
          }),
        );
        if (response.statusCode != 200) {
          print("Erreur lors de l'ajout aux favoris: ${response.statusCode}");
        }
      } catch (e) {
        print("Erreur de connexion API favoris: $e");
      }
    }

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
                      latitude: shops[i].latitude,
                      longitude: shops[i].longitude,
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
                    latitude: shops[i].latitude,
                    longitude: shops[i].longitude,
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
