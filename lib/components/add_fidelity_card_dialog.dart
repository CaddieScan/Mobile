import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AddFidelityCardDialog extends StatefulWidget {
  const AddFidelityCardDialog({super.key});

  @override
  State<AddFidelityCardDialog> createState() => AddFidelityCardDialogState();
}

class AddFidelityCardDialogState extends State<AddFidelityCardDialog> {
  final TextEditingController cardIdController = TextEditingController();
  Map<String, dynamic>? selectedShop;
  List<Map<String, dynamic>> shops = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchShops();
  }

  @override
  void dispose() {
    cardIdController.dispose();
    super.dispose();
  }

  // on récupère la liste des magasins
  Future<void> fetchShops() async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
      final response = await http.get(Uri.parse('$baseUrl/shop/all'));
      if (response.statusCode == 200) {
        setState(() {
          shops = (jsonDecode(response.body) as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Erreur réseau magasins: $e');
    }
  }

  // on envoie la carte de fidélité à l'API
  Future<void> onAdd() async {
    try {
      setState(() => isLoading = true);
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
      final response = await http.post(
        Uri.parse('$baseUrl/carte_fidelite/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'utilisateur_id': 1,
          'magasin_id': selectedShop!['id'],
          'code_barre': int.parse(cardIdController.text.trim()),
        }),
      );
      if (response.statusCode == 200) {
        print('Carte ajoutée');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Erreur ajout carte: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une carte de fidélité'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: cardIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ID de la carte'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: selectedShop,
            hint: const Text('Sélectionner un magasin'),
            items: shops.map((shop) => DropdownMenuItem(
              value: shop,
              child: Text(shop['libelle']?.toString() ?? ''),
            )).toList(),
            onChanged: (value) => setState(() => selectedShop = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : onAdd,
          child: isLoading
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Ajouter'),
        ),
      ],
    );
  }
}