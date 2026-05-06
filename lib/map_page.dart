import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:caddiescan/models/zone.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caddiescan/components/plan_painter.dart'; // Utilise celui-là !

import 'components/prices_shop_map.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  Future<List<Zone>> fetchZones() async {
    final prefs = await SharedPreferences.getInstance();
    final shopIdStr = prefs.getString("current_shop_id_scan") ?? "1";
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

    // Affiche l'URL complète pour la tester dans ton navigateur ou Postman
    final url = '$baseUrl/api/stores/$shopIdStr/map';
    print("Tentative d'appel API sur : $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("Status Code: ${response.statusCode}");
      print("Réponse brute: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        // Ici, on vérifie si ton JSON a une clé 'zones' (comme sur ton image précédente)
        if (decoded is Map<String, dynamic> && decoded['zones'] != null) {
          return (decoded['zones'] as List).map((d) => Zone.fromJson(d)).toList();
        } else if (decoded is List) {
          return decoded.map((d) => Zone.fromJson(d)).toList();
        }
      }
      throw Exception("Serveur a répondu : ${response.statusCode}");
    } catch (e) {
      print("Erreur attrapée : $e");
      rethrow; // Renvoie l'erreur au FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Récupérer l'argument passé lors de la navigation
    final String? highlightedZoneName = ModalRoute.of(context)?.settings.arguments as String?;
    print("DEBUG: Zone à surligner reçue = '$highlightedZoneName'");
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
                padding: const EdgeInsets.all(16.0),
                child: Text("Erreur technique : ${snapshot.error}"),
              ),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Erreur de chargement du plan."));
          }

          final zones = snapshot.data!;

          return InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(1000),
            minScale: 0.1,
            maxScale: 4.0,
            child: Center(
              child: CustomPaint(
                size: const Size(2000, 2000),
                painter: PlanPainter(zones, highlightedName: highlightedZoneName),
              ),
            ),
          );
        },
      ),
    );
  }
}
