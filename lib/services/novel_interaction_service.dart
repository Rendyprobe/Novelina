import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/comment_model.dart';
import '../models/novel_stats.dart';
import 'api_config.dart';

class NovelInteractionService {
  const NovelInteractionService();

  Future<NovelStats> fetchStats(String novelId) async {
    final uri = ApiConfig.resolve('/novels/${Uri.encodeComponent(novelId)}/stats');
    final response = await http.get(uri);
    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return NovelStats.fromJson(data);
    }

    throw Exception(data['message'] ?? 'Gagal memuat statistik novel.');
  }

  Future<NovelStats> incrementRead(String novelId) async {
    final uri = ApiConfig.resolve('/novels/${Uri.encodeComponent(novelId)}/read');
    final response = await http.post(uri);
    final data = _decodeBody(response);
    if (response.statusCode == 200) {
      return NovelStats.fromJson(data);
    }
    throw Exception(data['message'] ?? 'Gagal memperbarui jumlah pembaca.');
  }

  Future<List<NovelComment>> fetchComments(String novelId) async {
    final uri = ApiConfig.resolve('/novels/${Uri.encodeComponent(novelId)}/comments');
    final response = await http.get(uri);
    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      final list = (data['comments'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      return list.map(NovelComment.fromJson).toList();
    }

    throw Exception(data['message'] ?? 'Gagal memuat komentar.');
  }

  Future<NovelComment> submitComment({
    required String novelId,
    required int userId,
    required String userName,
    required String content,
    String avatarUrl = '',
  }) async {
    final uri = ApiConfig.resolve('/novels/${Uri.encodeComponent(novelId)}/comments');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'userName': userName,
        'content': content,
        if (avatarUrl.trim().isNotEmpty) 'avatarUrl': avatarUrl.trim(),
      }),
    );
    final data = _decodeBody(response);

    if (response.statusCode == 201) {
      return NovelComment.fromJson(data['comment'] as Map<String, dynamic>);
    }

    throw Exception(data['message'] ?? 'Gagal mengirim komentar.');
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : {'message': decoded.toString()};
    } catch (_) {
      return {'message': 'Respons server tidak valid.'};
    }
  }
}
