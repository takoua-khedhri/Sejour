import '../../domain/entities/audio.dart';

class AudioModel {
  final String id;
  final String url;
  final String type;
  final String date;
  final bool isLiked;
  final String? comment;

  AudioModel({
    required this.id,
    required this.url,
    required this.type,
    required this.date,
    required this.isLiked,
    this.comment,
  });

  // Convertit le JSON en AudioModel
  factory AudioModel.fromJson(Map<String, dynamic> json) {
    // Utilisez pathnonstream comme URL principale pour la lecture
    final audioUrl = json['pathnonstream']?.toString() ?? '';

    return AudioModel(
      id: json['id']?.toString() ?? '',
      url: audioUrl, // <-- ICI: pathnonstream est utilisé pour la lecture
      type: json['type']?.toString() ?? 'audio',
      date: json['dateCreate']?.toString() ?? '',
      isLiked: (json['likes'] ?? 0) > 0,
      comment: json['comment']?.toString(),
    );
  }

  // Convertit le modèle en entité (Audio)
  Audio toEntity() {
    return Audio(
      id: id,
      url: url,
      type: type,
      date: date,
      isLiked: isLiked,
      comment: comment,
    );
  }

  // Convertit l'entité en modèle (utile pour les tests ou cache)
  factory AudioModel.fromEntity(Audio audio) {
    return AudioModel(
      id: audio.id,
      url: audio.url,
      type: audio.type,
      date: audio.date,
      isLiked: audio.isLiked,
      comment: audio.comment,
    );
  }

  // Pour la sérialisation (optionnel)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pathnonstream': url,
      'type': type,
      'dateCreate': date,
      'likes': isLiked ? 1 : 0,
      'comment': comment,
    };
  }

  // Pour les comparaisons et tests
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioModel &&
        other.id == id &&
        other.url == url &&
        other.type == type &&
        other.date == date &&
        other.isLiked == isLiked &&
        other.comment == comment;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        url.hashCode ^
        type.hashCode ^
        date.hashCode ^
        isLiked.hashCode ^
        comment.hashCode;
  }
}
