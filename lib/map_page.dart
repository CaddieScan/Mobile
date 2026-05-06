import 'dart:convert';
import 'package:caddiescan/components/prices_shop_map.dart';
import 'package:flutter/material.dart';
import 'package:caddiescan/models/zone.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'components/container_map.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  Future<List<Zone>> fetchZones() async {
    final prefs = await SharedPreferences.getInstance();
    final shopIdStr = prefs.getString("current_shop_id_scan");
    String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    print("URL: $baseUrl");
    final response = await http.get(Uri.parse('$baseUrl/api/stores/$shopIdStr/map/mobile'));
    print("Body: ${response.body}");
    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic> && decoded['zones'] != null) {
        final List<dynamic> zoneList = decoded['zones'];
        return zoneList.map((data) => Zone.fromJson(data)).toList();
      } else if (decoded is List) {
        return decoded.map((data) => Zone.fromJson(data)).toList();
      }else {
        throw Exception("Erreur Serveur : ${response.statusCode}");
      }
    }

    throw Exception("Format de données invalide ou erreur serveur");
  }

  @override
  Widget build(BuildContext context) {
    final zones = fetchZones();

    return Scaffold(
      appBar: AppBar(title: const Text("Plan magasin")),
        body: FutureBuilder<List<Zone>>(
          future: fetchZones(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Erreur: ${snapshot.error}"));
            }

            final zones = snapshot.data!;

            return Center(
              child: ShopMap(zones: zones),
            );
          },
        ),
    );
  }
}
