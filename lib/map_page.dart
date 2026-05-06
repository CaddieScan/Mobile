import 'dart:convert';
import 'package:caddiescan/components/prices_shop_map.dart';
import 'package:flutter/material.dart';
import 'package:caddiescan/models/zone.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'components/container_map.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  Future<List<Zone>> fetchZones() async {
    String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final response = await http.get(Uri.parse('$baseUrl/stores/1/map'));
    print("Body: ${response.body}"); // <--- C'est ici que tu verras la vérité
    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      // On vérifie si la réponse est bien une Map et si la clé existe
      if (decoded is Map<String, dynamic> && decoded['zones'] != null) {
        final List<dynamic> zoneList = decoded['zones'];
        return zoneList.map((data) => Zone.fromJson(data)).toList();
      } else if (decoded is List) {
        // Si le back renvoie directement une liste []
        return decoded.map((data) => Zone.fromJson(data)).toList();
      }else {
        throw Exception("Erreur Serveur : ${response.statusCode}");
      }
    }

    // Si on arrive ici, c'est qu'il y a un problème
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
