import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:caddiescan/models/zone.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'components/prices_shop_map.dart'; // Assure-toi que ShopMap est ici

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  Future<List<Zone>> fetchZones() async {
    final prefs = await SharedPreferences.getInstance();
    final shopIdStr = prefs.getString("current_shop_id_scan") ?? "1";
    String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

    final response = await http.get(Uri.parse('$baseUrl/api/stores/$shopIdStr/map'));

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      // Gestion du nouveau format : l'objet contient une clé 'zones'
      if (decoded is Map<String, dynamic> && decoded['zones'] != null) {
        final List<dynamic> zoneList = decoded['zones'];
        return zoneList.map((data) => Zone.fromJson(data)).toList();
      }
      // Cas de repli si le back renvoie directement une liste
      else if (decoded is List) {
        return decoded.map((data) => Zone.fromJson(data)).toList();
      }
    }

    throw Exception("Erreur ${response.statusCode}: Impossible de charger le plan");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plan magasin")),
      body: FutureBuilder<List<Zone>>(
        future: fetchZones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("Erreur: ${snapshot.error}", textAlign: TextAlign.center),
              ),
            );
          }

          final zones = snapshot.data ?? [];

          if (zones.isEmpty) {
            return const Center(child: Text("Aucun rayon défini pour ce magasin."));
          }

          return InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(1000),
            minScale: 0.1,
            maxScale: 4.0,
            child: Center(
              child: ShopMap(zones: zones),
            ),
          );
        },
      ),
    );
  }
}