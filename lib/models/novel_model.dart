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
    return [
      FeaturedNovel(
        id: 'novel-1',
        title: 'Laskar Pelangi',
        author: 'Andrea Hirata',
        synopsis: 'Kisah perjuangan sepuluh anak di Belitung dalam mengejar mimpi dan pendidikan.',
        rating: 4.8,
        chapters: 18,
        genre: 'Drama Inspiratif',
        featureTag: 'Bestseller Sepanjang Masa',
        content: _buildPrototypeContent(
          'Laskar Pelangi',
          'perjuangan anak-anak Belitung mencari ilmu dengan penuh persahabatan',
        ),
        coverAsset: 'assets/images/Laskar_pelangi_sampul.jpg',
      ),
      Novel(
        id: 'novel-2',
        title: 'Ayat-Ayat Cinta',
        author: 'Habiburrahman El Shirazy',
        synopsis: 'Drama romansa yang berlatar di Mesir dengan dilema cinta dan spiritualitas.',
        rating: 4.7,
        chapters: 24,
        genre: 'Romansa Religi',
        content: _buildPrototypeContent(
          'Ayat-Ayat Cinta',
          'perjalanan Fahri menyeimbangkan cinta dan iman di Kairo',
        ),
        coverAsset: 'assets/images/Ayatayatcinta.jpg',
      ),
      Novel(
        id: 'novel-3',
        title: 'Perahu Kertas',
        author: 'Dee Lestari',
        synopsis: 'Perjalanan Kugy dan Keenan dengan impian kreatif dan pencarian jati diri.',
        rating: 4.6,
        chapters: 30,
        genre: 'Fiksi Kontemporer',
        content: _buildPrototypeContent(
          'Perahu Kertas',
          'kisah Kugy dan Keenan yang menganyam mimpi melalui seni dan persahabatan',
        ),
        coverAsset: 'assets/images/Perahu_Kertas.jpg',
      ),
      FeaturedNovel(
        id: 'novel-4',
        title: 'Negeri 5 Menara',
        author: 'Ahmad Fuadi',
        synopsis: 'Kisah persahabatan santri di pondok pesantren dengan mimpi ke mancanegara.',
        rating: 4.9,
        chapters: 26,
        genre: 'Coming of Age',
        featureTag: 'Inspirasi Santri',
        content: _buildPrototypeContent(
          'Negeri 5 Menara',
          'tekad para santri menatap dunia dengan mantra man jadda wajada',
        ),
        coverAsset: 'assets/images/Negeri5Menara.jpg',
      ),
      Novel(
        id: 'novel-5',
        title: 'Sang Pemimpi',
        author: 'Andrea Hirata',
        synopsis: 'Petualangan Ikal dan Arai mengejar pendidikan tinggi dan mimpi besar.',
        rating: 4.5,
        chapters: 20,
        genre: 'Drama Inspiratif',
        content: _buildPrototypeContent(
          'Sang Pemimpi',
          'langkah Ikal dan Arai menembus batas untuk meraih mimpi terbesar',
        ),
        coverAsset: 'assets/images/Sang_Pemimpi.jpg',
      ),
      Novel(
        id: 'novel-6',
        title: 'Tetralogi Buru',
        author: 'Pramoedya Ananta Toer',
        synopsis: 'Serangkaian novel sejarah tentang perjuangan Minke melawan kolonialisme.',
        rating: 4.8,
        chapters: 40,
        genre: 'Sejarah',
        content: _buildPrototypeContent(
          'Tetralogi Buru',
          'perlawanan Minke terhadap kolonialisme dan kebangkitan kesadaran bangsa',
        ),
        coverAsset: 'assets/images/Tetralogi_buru.jpg',
      ),
    ];
  }

  String _buildPrototypeContent(String title, String focus) {
    final buffer = StringBuffer();
    for (var i = 1; i <= 8; i++) {
      buffer.writeln(
        ' menuturkan  melalui kalimat ke- yang memperdalam pengalaman membaca.',
      );
    }
    return buffer.toString().trim();
  }
}
