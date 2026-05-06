import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/section_header.dart';
import 'components/shop_choice_card.dart';
import 'models/shop.dart';

class ShopChoicePage extends StatefulWidget {
  const ShopChoicePage({super.key});

  @override
  State<ShopChoicePage> createState() => ShopChoicePageState();
}

class ShopChoicePageState extends State<ShopChoicePage> {
  late SharedPreferences prefs;
  late List<Shop> shops = [];
  Map<int, dynamic> rawShopData = {};

  void saveFavorites() {
    List<dynamic> favsToSave = [];
    for (var s in shops.where((shop) => shop.isFavorite)) {
      if (rawShopData.containsKey(s.id)) {
        favsToSave.add(rawShopData[s.id]);
      }
    }
    prefs.setString('favorite_shops_data', jsonEncode(favsToSave));
  }

  Future<http.Response> fetchShops(double lat, double lon) {
    String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
    return http.post(
      Uri.parse('$baseUrl/shop/proximity?user_id=1'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": 1,
        "latitude": lat,
        "longitude": lon,
        "radius_km": 500
      }),
    );
  }

  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void initShopList() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showError('Services de localisation désactivés');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showError('Permissions de localisation refusées');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showError('Permissions de localisation refusées définitivement');
      return;
    }

    setState(() {
      String? savedFavs = prefs.getString('favorite_shops_data');
      if (savedFavs != null && savedFavs.isNotEmpty) {
        List<dynamic> favList = jsonDecode(savedFavs);
        shops = [];
        for (var item in favList) {
          try {
            Shop s = Shop.fromJson(item);
            s.isFavorite = true;
            rawShopData[s.id] = item;
            shops.add(s);
          } catch (e) {
            showError('Erreur chargement favori: $e');
          }
        }
        shops.sort((a, b) => a.km.compareTo(b.km));
      }
    });

    Position position = await Geolocator.getCurrentPosition();

    fetchShops(position.latitude, position.longitude).then((response) {
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          List<Shop> newShops = [];
          for (var item in data) {
            Shop s = Shop.fromJson(item);
            rawShopData[s.id] = item;
            if (shops.any((fav) => fav.id == s.id && fav.isFavorite)) {
              s.isFavorite = true;
            }
            newShops.add(s);
          }

          for (var fav in shops.where((s) => s.isFavorite)) {
            if (!newShops.any((s) => s.id == fav.id)) {
              newShops.add(fav);
            }
          }

          shops = newShops;
          shops.sort((a, b) => a.km.compareTo(b.km));
          saveFavorites();
        });
      } else {
        showError('Erreur magasins (HTTP ${response.statusCode})');
      }
    }).catchError((e) {
      showError('Erreur réseau: $e');
    });
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      setState(() => prefs = p);
      initShopList();
    });
  }

  void toggleFavorite(int index) async {
    final shop = shops[index];

    setState(() {
      shop.isFavorite = !shop.isFavorite;
      saveFavorites();
    });

    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/shop/favorite'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": 1, "shop_id": shop.id}),
      );
      if (response.statusCode != 200) {
        showError('Erreur toggle favoris (${response.statusCode})');
      }
    } catch (e) {
      showError('Erreur connexion API: $e');
    }
  }

  void navigateToScan(int shopId) {
    prefs.setString('current_shop_id_scan', shopId.toString());
    Navigator.pushNamed(context, '/scan');
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
            if (Navigator.canPop(context)) Navigator.pop(context);
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
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (shops.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Text(
                    'Pas de magasins dans les alentours et aucun favori sauvegardé.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Column(
                children: [
                  const SectionHeader(title: 'Favoris'),
                  for (int i = 0; i < shops.length; i++)
                    if (shops[i].isFavorite)
                      ShopChoiceCard(
                        location: shops[i].location,
                        latitude: shops[i].latitude,
                        longitude: shops[i].longitude,
                        km: shops[i].km,
                        icon: shops[i].icon,
                        isFavorite: shops[i].isFavorite,
                        onFavoritePressed: () => toggleFavorite(i),
                        onPressed: () => navigateToScan(shops[i].id),
                      ),

                  if (!shops.any((shop) => shop.isFavorite))
                    const Center(child: Text('Aucun favori')),

                  const SizedBox(height: 24),

                  if (shops.any((shop) => !shop.isFavorite)) ...[
                    const SectionHeader(title: 'A proximité'),
                    for (int i = 0; i < shops.length; i++)
                      if (!shops[i].isFavorite)
                        ShopChoiceCard(
                          location: shops[i].location,
                          km: shops[i].km,
                          latitude: shops[i].latitude,
                          longitude: shops[i].longitude,
                          icon: shops[i].icon,
                          isFavorite: shops[i].isFavorite,
                          onFavoritePressed: () => toggleFavorite(i),
                          onPressed: () => navigateToScan(shops[i].id),
                        ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text('Pas d\'autres magasins dans les alentours'),
                      ),
                    )
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}