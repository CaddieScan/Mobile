import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'services/cart_service.dart';

class ValidationPage extends StatefulWidget {
  const ValidationPage({super.key});

  @override
  State<ValidationPage> createState() => ValidationPageState();
}

class ValidationPageState extends State<ValidationPage> {
  String? fidelityCardCode;

  @override
  void initState() {
    super.initState();
    fetchFidelityCard();
  }

  // on récupère la carte de fidélité de l'utilisateur pour le magasin courant
  Future<void> fetchFidelityCard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shopIdStr = prefs.getString('current_shop_id_scan');
      if (shopIdStr == null) return;

      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
      final response = await http.get(Uri.parse('$baseUrl/carte_fidelite/user/1/magasin/$shopIdStr'));
      if (response.statusCode != 200) return;

      final data = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      setState(() => fidelityCardCode = data['code_barre']?.toString());
    } catch (e) {
      debugPrint('Erreur récupération carte fidélité: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validation')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Panier valide',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Rendez-vous sur une caisse Scan rapide,\net scannez ce code depuis la caisse',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                height: 90,
                width: double.infinity,
                color: Colors.black12,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 16),
              if (fidelityCardCode != null)
                Text(
                  'Carte de fidélité : $fidelityCardCode',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/scan');
                },
                child: const Text('Retour au scan d\'articles'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await CartService.clearCartId();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}