import '../../domain/entities/day_description.dart';

class DayDescriptionModel {
  final String date;
  final String description;

  DayDescriptionModel({required this.date, required this.description});

  factory DayDescriptionModel.fromJson(Map<String, dynamic> json) {
    return DayDescriptionModel(
      date: json['date'],
      description: json['description'] ?? 'Pas de description disponible',
    );
  }

  factory DayDescriptionModel.empty() {
    return DayDescriptionModel(
      date: '',
      description: 'Aucune description trouvée',
    );
  }

  // Conversion du modèle en entité
  DayDescription toEntity() {
    return DayDescription(
      date: date,
      description: description,
    );
  }
}