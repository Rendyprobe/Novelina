import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/api_config.dart';

const AssetImage _fallbackCoverAsset =
    AssetImage('assets/images/Logo_Novelina.jpg');

ImageProvider<Object> resolveCoverImage(String path) {
  if (path.isEmpty) {
    return _fallbackCoverAsset;
  }

  if (path.startsWith('http')) {
    final uri = Uri.tryParse(path);
    if (uri != null && _requiresProxy(uri)) {
      final proxied = ApiConfig.resolve('/media-proxy')
          .replace(queryParameters: {'url': uri.toString()});
      return NetworkImage(proxied.toString());
    }
    return NetworkImage(path);
  }

  if (path.startsWith('data:image')) {
    try {
      final base64Data = path.split(',').last;
      final bytes = base64Decode(base64Data);
      return MemoryImage(bytes);
    } catch (_) {
      return _fallbackCoverAsset;
    }
  }

  return AssetImage(path);
}

bool _requiresProxy(Uri uri) {
  final host = uri.host.toLowerCase();
  return host.endsWith('ibb.co') || host.endsWith('imgbb.com');
}
