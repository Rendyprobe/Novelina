class NovelComment {
  final int id;
  final String userName;
  final String content;
  final DateTime createdAt;
  final String avatarUrl;
  final int userId;

  NovelComment({
    required this.id,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.avatarUrl = '',
    this.userId = 0,
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
      avatarUrl: (json['avatar_url'] as String?) ??
          (json['avatarUrl'] as String?) ??
          '',
      userId: ((json['user_id'] ?? json['userId']) is num)
          ? (json['user_id'] ?? json['userId'] as num).toInt()
          : int.tryParse('${json['user_id'] ?? json['userId']}') ?? 0,
    );
  }

  String get formattedTimestamp {
    final localTime = createdAt.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final day = localTime.day.toString().padLeft(2, '0');
    final month = months[localTime.month - 1];
    final year = localTime.year.toString();
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }
}
