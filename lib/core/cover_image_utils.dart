import 'dart:convert';

import 'package:flutter/material.dart';

const AssetImage _fallbackCoverAsset =
    AssetImage('assets/images/Logo_Novelina.jpg');

ImageProvider<Object> resolveCoverImage(String path) {
  if (path.isEmpty) {
    return _fallbackCoverAsset;
  }

  if (path.startsWith('http')) {
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
