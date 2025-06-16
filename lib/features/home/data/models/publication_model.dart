import '../../domain/entities/publication.dart';

class PublicationModel {
  final String id;
  final String url;
  final String type;
  final String date;
  final bool isLiked;
  final int likes; // Champ ajouté
  final String? comment;
  final String? thumbnailUrl;

  PublicationModel({
    required this.id,
    required this.url,
    required this.type,
    required this.date,
    required this.isLiked,
    required this.likes, // Ajouté comme paramètre requis
    this.comment,
    this.thumbnailUrl,
  });

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    final url = _ensureFullUrl(json['pathnonstream']);
    return PublicationModel(
      id: json['id'],
      url: url,
      type: json['type'],
      date: json['dateCreate']?.toString() ?? '', // Gestion de null
      isLiked: (json['likes'] ?? 0) > 0,
      likes: json['likes'] ?? 0, // Initialisation du champ likes
      comment: json['comment'],
      thumbnailUrl: _ensureFullUrl(json['pathstream']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pathnonstream': url,
      'type': type,
      'dateCreate': date,
      'likes': likes, // Utilise le champ likes plutôt que la conversion
      'comment': comment,
      'pathstream': thumbnailUrl,
    };
  }

  PublicationModel copyWith({
    String? id,
    String? url,
    String? type,
    String? date,
    bool? isLiked,
    int? likes, // Ajouté
    String? comment,
    String? thumbnailUrl,
  }) {
    return PublicationModel(
      id: id ?? this.id,
      url: url ?? this.url,
      type: type ?? this.type,
      date: date ?? this.date,
      isLiked: isLiked ?? this.isLiked,
      likes: likes ?? this.likes, // Ajouté
      comment: comment ?? this.comment,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  static String _ensureFullUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'https://media.5sur5sejour.com${url.startsWith('/') ? url : '/$url'}';
  }

  Publication toEntity() {
    return Publication(
      id: id,
      url: url,
      type: type,
      date: date,
      isLiked: isLiked,
      comment: comment,
      thumbnailUrl: thumbnailUrl,
    );
  }
}