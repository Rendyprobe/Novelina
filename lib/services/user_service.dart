import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class UserService {
  const UserService();

  static const _headers = {'Content-Type': 'application/json'};

  Future<String> updateAvatar({
    required int userId,
    required String avatarUrl,
  }) async {
    if (userId <= 0) {
      throw Exception('ID pengguna tidak valid.');
    }

    final uri = ApiConfig.resolve('/users/$userId/avatar');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'avatar_url': avatarUrl,
      }),
    );

    final data = _decode(response);
    if (response.statusCode == 200) {
      final updatedUrl = (data['avatar_url'] as String?) ??
          (data['avatarUrl'] as String?) ??
          avatarUrl;
      return updatedUrl;
    }

    final message = data['message']?.toString() ?? 'Gagal memperbarui foto profil.';
    throw Exception(message);
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'message': decoded.toString()};
    } catch (_) {
      return {'message': 'Server tidak merespons dengan format yang dikenali.'};
    }
  }
}
