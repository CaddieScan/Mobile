import 'package:flutter/material.dart';

class AddFidelityCardDialog extends StatefulWidget {
  const AddFidelityCardDialog({super.key});

  @override
  State<AddFidelityCardDialog> createState() => AddFidelityCardDialogState();
}

class AddFidelityCardDialogState extends State<AddFidelityCardDialog> {
  final TextEditingController cardIdController = TextEditingController();
  String? selectedShop;

  // liste des magasins disponibles (à remplacer par un fetch API si besoin)
  final List<String> shops = ['Magasin Paris', 'Magasin Lyon', 'Magasin Marseille'];

  @override
  void dispose() {
    cardIdController.dispose();
    super.dispose();
  }

  void onAdd() {
    print('Carte ajoutée');
    Navigator.of(context).pop();
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
            decoration: const InputDecoration(labelText: 'ID de la carte'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedShop,
            hint: const Text('Sélectionner un magasin'),
            items: shops.map((shop) => DropdownMenuItem(value: shop, child: Text(shop))).toList(),
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
          onPressed: onAdd,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}