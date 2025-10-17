import 'package:flutter/foundation.dart';

abstract class LiteratureItem {
  final String _id;
  final String _title;
  final String _author;
  final String _synopsis;

  const LiteratureItem({
    required String id,
    required String title,
    required String author,
    required String synopsis,
  })  : _id = id,
        _title = title,
        _author = author,
        _synopsis = synopsis;

  String get id => _id;
  String get title => _title;
  String get author => _author;
  String get synopsis => _synopsis;

  @protected
  String get baseMarketingMessage => ' karya ';

  String marketingMessage();
}

class Novel extends LiteratureItem {
  final double _rating;
  final int _chapters;
  final String _genre;
  final String _content;
  final String _coverAsset;
  final String? _marketingOverride;
  double _userRating;

  Novel({
    required super.id,
    required super.title,
    required super.author,
    required super.synopsis,
    required double rating,
    required int chapters,
    required String genre,
    required String content,
    required String coverAsset,
    String? marketingMessageOverride,
    double userRating = 0.0,
  })  : _rating = rating,
        _chapters = chapters,
        _genre = genre,
        _content = content,
        _coverAsset = coverAsset,
        _marketingOverride = marketingMessageOverride,
        _userRating = userRating;

  double get rating => _rating;
  int get chapters => _chapters;
  String get genre => _genre;
  String get content => _content;
  String get coverAsset => _coverAsset;
  double get userRating => _userRating;
  set userRating(double value) {
    _userRating = value.clamp(0.0, 5.0).toDouble();
  }

  String get formattedRating => _rating.toStringAsFixed(1);

  void updateUserRating(double newRating) {
    userRating = newRating;
  }

  @override
  String marketingMessage() {
    final override = _marketingOverride?.trim();
    if (override != null && override.isNotEmpty) {
      return override;
    }
    return ' - ';
  }

  factory Novel.fromJson(Map<String, dynamic> json) {
    String asString(dynamic value, [String fallback = '']) =>
        value is String ? value : value?.toString() ?? fallback;
    double asDouble(dynamic value, [double fallback = 0]) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? fallback;
      return fallback;
    }

    int asInt(dynamic value, [int fallback = 0]) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    final featureTag = asString(json['feature_tag']).trim();
    final marketing = asString(json['marketing_message']).trim();

    final baseParams = (
      id: asString(json['id']),
      title: asString(json['title']),
      author: asString(json['author']),
      synopsis: asString(json['synopsis']),
      rating: asDouble(json['rating']),
      chapters: asInt(json['chapters']),
      genre: asString(json['genre']),
      content: asString(json['content']),
      cover: asString(json['cover_asset']).isEmpty
          ? 'assets/images/Logo_Novelina.jpg'
          : asString(json['cover_asset']),
      marketingOverride: marketing.isEmpty ? null : marketing,
    );

    if (featureTag.isNotEmpty) {
      return FeaturedNovel(
        featureTag: featureTag,
        id: baseParams.id,
        title: baseParams.title,
        author: baseParams.author,
        synopsis: baseParams.synopsis,
        rating: baseParams.rating,
        chapters: baseParams.chapters,
        genre: baseParams.genre,
        content: baseParams.content,
        coverAsset: baseParams.cover,
        marketingMessageOverride: baseParams.marketingOverride,
      );
    }

    return Novel(
      id: baseParams.id,
      title: baseParams.title,
      author: baseParams.author,
      synopsis: baseParams.synopsis,
      rating: baseParams.rating,
      chapters: baseParams.chapters,
      genre: baseParams.genre,
      content: baseParams.content,
      coverAsset: baseParams.cover,
      marketingMessageOverride: baseParams.marketingOverride,
    );
  }
}

class FeaturedNovel extends Novel {
  final String _featureTag;

  FeaturedNovel({
    required super.id,
    required super.title,
    required super.author,
    required super.synopsis,
    required super.rating,
    required super.chapters,
    required super.genre,
    required super.content,
    required super.coverAsset,
    super.marketingMessageOverride,
    String featureTag = 'Pilihan Editor',
  }) : _featureTag = featureTag;

  String get featureTag => _featureTag;

  @override
  String marketingMessage() {
    if (super.marketingMessage() != ' - ') {
      return super.marketingMessage();
    }
    return ' - Rating ';
  }
}

class NovelRepository {
  const NovelRepository();

  List<Novel> loadNovels() {
    return const [];
  }
}
