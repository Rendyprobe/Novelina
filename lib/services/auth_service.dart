import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'api_config.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const Map<String, String> _headers = {'Content-Type': 'application/json'};

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      ApiConfig.resolve('/signin'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data);
    }

    throw AuthException(data['message']?.toString() ?? 'Login gagal. Silakan coba lagi.');
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      ApiConfig.resolve('/signup'),
      headers: _headers,
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 201) {
      return UserModel.fromJson(data);
    }

    throw AuthException(data['message']?.toString() ?? 'Pendaftaran gagal. Silakan coba lagi.');
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
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
