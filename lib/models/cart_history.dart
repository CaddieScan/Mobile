class CartHistory {
  final int id;
  final int utilisateurId;
  final int magasinId;
  final double totalTtc;
  final DateTime dateHeureCreation;
  final String magasinLibelle;
  final String magasinLogo;

  CartHistory({
    required this.id,
    required this.utilisateurId,
    required this.magasinId,
    required this.totalTtc,
    required this.dateHeureCreation,
    required this.magasinLibelle,
    required this.magasinLogo,
  });

  factory CartHistory.fromJson(Map<String, dynamic> json) {
    return CartHistory(
      id: json['id'] as int,
      utilisateurId: json['utilisateur_id'] as int,
      magasinId: json['magasin_id'] as int,
      totalTtc: (json['total_ttc'] is int)
          ? (json['total_ttc'] as int).toDouble()
          : (json['total_ttc'] as double),
      dateHeureCreation: DateTime.parse(json['date_heure_creation'] as String),
      magasinLibelle: json['magasin_libelle'] as String? ?? '',
      magasinLogo: json['magasin_logo'] as String? ?? '',
    );
  }
}

