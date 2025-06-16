class Sejour {
  final String id;
  final String? code;
  final String? nom;
  final String? dateDebut;
  final String? dateFin;
  final String? etat;
  final int? partenaire;
  final int? accompagnateur;
  final String? theme;
  final Map<String, String> jourdescription;
  final Map<String, dynamic> localisation;
  final int? nbEnfant;

  Sejour({
    required this.id,
    this.code,
    this.nom,
    this.dateDebut,
    this.dateFin,
    this.etat,
    this.jourdescription = const {},
    this.localisation = const {},
    this.nbEnfant,
    this.accompagnateur,
    this.partenaire,
    this.theme,
  });

  Sejour copyWith({
    String? id,
    String? code,
    String? nom,
    String? dateDebut,
    String? dateFin,
    String? etat,
    Map<String, String>? jourdescription,
    Map<String, dynamic>? localisation,
    int? nbEnfant,
    int? partenaire,
    int? accompagnateur,
    String? theme,
  }) {
    return Sejour(
      id: id ?? this.id,
      code: code ?? this.code,
      nom: nom ?? this.nom,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      etat: etat ?? this.etat,
      jourdescription: jourdescription ?? Map<String, String>.from(this.jourdescription),
      localisation: localisation ?? Map<String, dynamic>.from(this.localisation),
      nbEnfant: nbEnfant ?? this.nbEnfant,
      accompagnateur: accompagnateur ?? this.accompagnateur,
      partenaire: partenaire ?? this.partenaire,
      theme: theme ?? this.theme,
    );
  }

  factory Sejour.fromJson(Map<String, dynamic> json) {
    return Sejour(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString(),
      nom: json['nom']?.toString(),
      dateDebut: json['dateDebut']?.toString(),
      dateFin: json['dateFin']?.toString(),
      etat: json['etat']?.toString(),
      jourdescription: Map<String, String>.from(json['jourdescription'] ?? {}),
      localisation: Map<String, dynamic>.from(json['localisation'] ?? {}),
      nbEnfant: json['nbEnfant'] is int ? json['nbEnfant'] as int : null,
      accompagnateur: json['accompagnateur'] is int ? json['accompagnateur'] as int : null,
      partenaire: json['partenaire'] is int ? json['partenaire'] as int : null,
      theme: json['theme']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'nom': nom,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'etat': etat,
      'jourdescription': jourdescription,
      'localisation': localisation,
      'nbEnfant': nbEnfant,
      'accompagnateur': accompagnateur,
      'partenaire': partenaire,
      'theme': theme,
    };
  }

  Map<String, dynamic> toDebugMap() {
    return {
      'id': id,
      'nom': nom,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'etat': etat,
      'theme': theme,
      'ville': localisation['ville'],
      'nbEnfant': nbEnfant,
      'code': code,
    };
  }
}