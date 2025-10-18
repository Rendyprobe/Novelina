import 'dart:convert';

import 'package:http/http.dart' as http;

/// Handles cover image uploads to ImgBB and returns the hosted image URL.
class ImageUploadService {
  const ImageUploadService();

  static const String _endpoint = 'https://api.imgbb.com/1/upload';
  static const String _embeddedApiKey = '8f7d02e7dbd5e1f24c46bf0588cdfe38';
  static const String _apiKey =
      String.fromEnvironment('IMGBB_API_KEY', defaultValue: _embeddedApiKey);

  Future<String> uploadFromDataUrl(String source) async {
    if (source.trim().isEmpty) {
      throw Exception('Gambar cover belum dipilih.');
    }
    if (_apiKey.isEmpty) {
      throw Exception('IMGBB API key belum dikonfigurasi.');
    }

    final extracted = _extractBase64Payload(source);
    if (extracted.isEmpty) {
      throw Exception('Format gambar tidak valid.');
    }

    final uri = Uri.parse('$_endpoint?key=$_apiKey');
    final request = http.MultipartRequest('POST', uri)
      ..fields['image'] = extracted;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 200) {
      final message = _extractErrorMessage(response.body);
      throw Exception(message);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Respons ImgBB tidak dikenali.');
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Data ImgBB tidak lengkap.');
    }

    final image = data['image'];
    String? directUrl;
    if (image is Map<String, dynamic>) {
      directUrl = image['url'] as String?;
    }
    directUrl ??= data['display_url'] as String?;
    directUrl ??= data['url'] as String?;
    final trimmedUrl = directUrl?.trim() ?? '';
    if (trimmedUrl.isEmpty) {
      throw Exception('URL gambar dari ImgBB tidak ditemukan.');
    }

    return trimmedUrl;
  }

  String _extractBase64Payload(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('data:image')) {
      final parts = trimmed.split(',');
      if (parts.length >= 2) {
        return parts.last.trim();
      }
    }
    return trimmed;
  }

  String _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'];
          if (message is String && message.trim().isNotEmpty) {
            return 'Upload ImgBB gagal: $message';
          }
        }
      }
    } catch (_) {
      // ignore and fall through to default message
    }
    return 'Upload ImgBB gagal dengan status tidak diketahui.';
  }
}
