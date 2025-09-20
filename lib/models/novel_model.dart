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
  String get baseMarketingMessage => '$title karya $author';

  String marketingMessage();
}

class Novel extends LiteratureItem {
  final double _rating;
  final int _chapters;
  final String _genre;

  Novel({
    required super.id,
    required super.title,
    required super.author,
    required super.synopsis,
    required double rating,
    required int chapters,
    required String genre,
  })  : _rating = rating,
        _chapters = chapters,
        _genre = genre;

  double get rating => _rating;
  int get chapters => _chapters;
  String get genre => _genre;

  String get formattedRating => _rating.toStringAsFixed(1);

  @override
  String marketingMessage() {
    return '${baseMarketingMessage.toUpperCase()} ? $_genre';
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
    String featureTag = 'Pilihan Editor',
  }) : _featureTag = featureTag;

  String get featureTag => _featureTag;

  @override
  String marketingMessage() {
    return '$featureTag ? Rating ${rating.toStringAsFixed(1)}';
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
        synopsis:
            'Kisah perjuangan sepuluh anak di Belitung dalam mengejar mimpi dan pendidikan.',
        rating: 4.8,
        chapters: 18,
        genre: 'Drama Inspiratif',
        featureTag: 'Bestseller Sepanjang Masa',
      ),
      Novel(
        id: 'novel-2',
        title: 'Ayat-Ayat Cinta',
        author: 'Habiburrahman El Shirazy',
        synopsis:
            'Drama romansa yang berlatar di Mesir dengan dilema cinta dan spiritualitas.',
        rating: 4.7,
        chapters: 24,
        genre: 'Romansa Religi',
      ),
      Novel(
        id: 'novel-3',
        title: 'Perahu Kertas',
        author: 'Dee Lestari',
        synopsis:
            'Perjalanan Kugy dan Keenan dengan impian kreatif dan pencarian jati diri.',
        rating: 4.6,
        chapters: 30,
        genre: 'Fiksi Kontemporer',
      ),
      FeaturedNovel(
        id: 'novel-4',
        title: 'Negeri 5 Menara',
        author: 'Ahmad Fuadi',
        synopsis: 'Kisah persahabatan santri di pondok pesantren dengan mimpi ke mancanegara.',
        rating: 4.9,
        chapters: 26,
        genre: 'Coming of Age',
      ),
      Novel(
        id: 'novel-5',
        title: 'Sang Pemimpi',
        author: 'Andrea Hirata',
        synopsis:
            'Petualangan Ikal dan Arai mengejar pendidikan tinggi dan mimpi besar.',
        rating: 4.5,
        chapters: 20,
        genre: 'Drama Inspiratif',
      ),
      Novel(
        id: 'novel-6',
        title: 'Tetralogi Buru',
        author: 'Pramoedya Ananta Toer',
        synopsis:
            'Serangkaian novel sejarah tentang perjuangan Minke melawan kolonialisme.',
        rating: 4.8,
        chapters: 40,
        genre: 'Sejarah',
      ),
    ];
  }
}

