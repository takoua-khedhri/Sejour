class Audio {
  final String id;
  final String url;
  final String type;
  final String date;
  final bool isLiked;
  final String? comment;

  const Audio({
    required this.id,
    required this.url,
    required this.type,
    required this.date,
    required this.isLiked,
    this.comment,
  });

 Audio copyWith({
    String? id,
    String? url,
    String? type,
    String? date,
    bool? isLiked,
    String? comment,
  }) {
    return Audio(
      id: id ?? this.id,
      url: url ?? this.url,
      type: type ?? this.type,
      date: date ?? this.date,
      isLiked: isLiked ?? this.isLiked,
      comment: comment ?? this.comment,
    );
  }
}