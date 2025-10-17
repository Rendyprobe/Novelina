import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/novel_model.dart';
import 'api_config.dart';

class BookmarkService {
  const BookmarkService();

  Future<List<Novel>> fetchBookmarks(int userId) async {
    final uri = ApiConfig.resolve('/bookmarks?userId=$userId');
    final response = await http.get(uri);
    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      final list = (data['bookmarks'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(Novel.fromJson)
          .toList();
      return list;
    }

    throw Exception(data['message'] ?? 'Gagal memuat bookmark.');
  }

  Future<bool> isBookmarked({
    required int userId,
    required String novelId,
  }) async {
    final uri = ApiConfig.resolve(
      '/bookmarks?userId=$userId&novelId=${Uri.encodeComponent(novelId)}',
    );
    final response = await http.get(uri);
    final data = _decodeBody(response);
    if (response.statusCode == 200) {
      return data['bookmarked'] == true;
    }
    throw Exception(data['message'] ?? 'Gagal memeriksa bookmark.');
  }

  Future<void> addBookmark({
    required int userId,
    required String novelId,
  }) async {
    final response = await http.post(
      ApiConfig.resolve('/bookmarks'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'novelId': novelId}),
    );
    final data = _decodeBody(response);
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menyimpan bookmark.');
    }
  }

  Future<void> removeBookmark({
    required int userId,
    required String novelId,
  }) async {
    final response = await http.delete(
      ApiConfig.resolve('/bookmarks'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'novelId': novelId}),
    );
    final data = _decodeBody(response);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menghapus bookmark.');
    }
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
