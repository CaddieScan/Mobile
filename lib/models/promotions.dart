class Promotion {
  final int id;
  final int magasinId;
  final String libelle;
  final DateTime dateHeureDebut;
  final DateTime dateHeureFin;
  final String modePromotion;
  final bool caniotteImmediate;
  final int? quantiteAcheter;
  final int? quantiteOffert;
  final double? reductionFixe;
  final int? pourcentageReduction;

  Promotion({
    required this.id,
    required this.magasinId,
    required this.libelle,
    required this.dateHeureDebut,
    required this.dateHeureFin,
    required this.modePromotion,
    required this.caniotteImmediate,
    this.quantiteAcheter,
    this.quantiteOffert,
    this.reductionFixe,
    this.pourcentageReduction,
  });
}

