class NovelChapter {
  final int chapterNo;
  final String title;
  final String content;

  const NovelChapter({
    required this.chapterNo,
    required this.title,
    required this.content,
  });

  factory NovelChapter.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return NovelChapter(
      chapterNo: parseInt(json['chapter_no']),
      title: (json['title'] as String?) ?? 'Bab ${parseInt(json['chapter_no'])}',
      content: (json['content'] as String?) ?? '',
    );
  }
}
