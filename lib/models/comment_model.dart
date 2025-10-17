import 'package:intl/intl.dart';

class NovelComment {
  final int id;
  final String userName;
  final String content;
  final DateTime createdAt;

  NovelComment({
    required this.id,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory NovelComment.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return NovelComment(
      id: parseInt(json['id']),
      userName: (json['user_name'] as String?)?.trim().isNotEmpty == true
          ? json['user_name'] as String
          : 'Anonim',
      content: (json['content'] as String?) ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  String get formattedTimestamp {
    final formatter = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
    return formatter.format(createdAt.toLocal());
  }
}
