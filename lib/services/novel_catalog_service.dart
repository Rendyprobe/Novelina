import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/novel_chapter.dart';
import '../models/novel_model.dart';
import 'api_config.dart';

class NovelCatalogService {
  const NovelCatalogService();

  Future<List<Novel>> fetchNovels() async {
    final response = await http.get(ApiConfig.resolve('/novels'));
    final data = _decode(response);
    if (response.statusCode == 200) {
      final list = (data['novels'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(Novel.fromJson)
          .toList();
      return list;
    }
    throw Exception(data['message'] ?? 'Gagal memuat daftar novel.');
  }

  Future<List<NovelChapter>> fetchChapters(String novelId) async {
    final response = await http.get(
      ApiConfig.resolve('/novels/${Uri.encodeComponent(novelId)}/chapters'),
    );
    final data = _decode(response);
    if (response.statusCode == 200) {
      final list = (data['chapters'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(NovelChapter.fromJson)
          .toList();
      return list;
    }
    throw Exception(data['message'] ?? 'Gagal memuat bab novel.');
  }

  Future<void> createNovel({
    required int userId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await http.post(
      ApiConfig.resolve('/novels'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        ...payload,
      }),
    );
    final data = _decode(response);
    if (response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Gagal menyimpan novel.');
    }
  }

  Future<void> deleteNovel({
    required int userId,
    required String novelId,
  }) async {
    final response = await http.delete(
      ApiConfig.resolve('/novels/${Uri.encodeComponent(novelId)}'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    final data = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menghapus novel.');
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'message': decoded.toString()};
    } catch (_) {
      return {'message': 'Respons server tidak valid.'};
    }
  }
}
