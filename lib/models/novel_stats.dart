class NovelStats {
  final int readCount;
  final int commentCount;

  const NovelStats({
    required this.readCount,
    required this.commentCount,
  });

  factory NovelStats.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return NovelStats(
      readCount: parseInt(json['read_count']),
      commentCount: parseInt(json['comment_count']),
    );
  }

  NovelStats copyWith({
    int? readCount,
    int? commentCount,
  }) {
    return NovelStats(
      readCount: readCount ?? this.readCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}
