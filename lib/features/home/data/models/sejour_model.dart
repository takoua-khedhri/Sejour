import '../../domain/entities/sejour.dart';

class SejourModel {
  final String id;
  final String code;
  final String nom;
  final String dateDebut;
  final String dateFin;
  final String etat;
  final Map<String, String> jourdescription;
  final Map<String, dynamic> localisation;
  final int nbEnfant;
  final int partenaire;
  final int accompagnateur;
  final String theme;

  SejourModel({
    required this.id,
    required this.code,
    required this.nom,
    required this.dateDebut,
    required this.dateFin,
    required this.etat,
    required this.jourdescription,
    required this.localisation,
    required this.nbEnfant,
    required this.partenaire,
    required this.accompagnateur,
    required this.theme,
  });

  factory SejourModel.fromJson(Map<String, dynamic> json) {
    String formatDate(String dateTime) {
      if (dateTime.contains('T')) {
        return dateTime.split('T')[0];
      }
      return dateTime;
    }

    return SejourModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '', // Changé de codeSejour.id à code
      nom: json['nom'] as String? ?? json['theme'] as String? ?? 'Nom inconnu', // Priorité à 'nom' puis 'theme'
      dateDebut: formatDate(json['dateDebut'] as String? ?? ''),
      dateFin: formatDate(json['dateFin'] as String? ?? ''),
      etat: json['etat'] as String? ?? 'active',
      jourdescription: Map<String, String>.from(json['jourdescription'] as Map<String, dynamic>? ?? {}),
      localisation: Map<String, dynamic>.from(json['localisation'] as Map<String, dynamic>? ?? {}),
      nbEnfant: json['nbEnfant'] as int? ?? 0,
      partenaire: json['partenaire'] as int? ?? 0,
      accompagnateur: json['accompagnateur'] as int? ?? 0,
      theme: json['theme'] as String? ?? '',
    );
  }

  

  Sejour toEntity() {
    return Sejour(
      id: id,
      code: code,
      nom: nom,
      dateDebut: dateDebut,
      dateFin: dateFin,
      etat: etat,
      jourdescription: jourdescription,
      localisation: localisation,
      nbEnfant: nbEnfant,
      partenaire: partenaire,
      accompagnateur: accompagnateur,
      theme: theme,
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
      'partenaire': partenaire,
      'accompagnateur': accompagnateur,
      'theme': theme,
    };
  }
}