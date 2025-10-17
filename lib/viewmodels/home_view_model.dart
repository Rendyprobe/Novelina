import 'dart:collection';

import '../models/novel_model.dart';
import '../services/novel_catalog_service.dart';

class HomeViewModel {
  HomeViewModel({NovelRepository? repository, NovelCatalogService? catalogService})
      : _repository = repository ?? const NovelRepository(),
        _catalogService = catalogService ?? const NovelCatalogService() {
    _allNovels = _repository.loadNovels();
    _visibleNovels = List<Novel>.from(_allNovels);
  }

  final NovelRepository _repository;
  final NovelCatalogService _catalogService;
  late List<Novel> _allNovels;
  late List<Novel> _visibleNovels;
  String _searchQuery = '';
  bool isLoading = false;
  String? lastError;

  UnmodifiableListView<Novel> get visibleNovels =>
      UnmodifiableListView(_visibleNovels);

  UnmodifiableListView<Novel> get allNovels =>
      UnmodifiableListView(_allNovels);

  UnmodifiableListView<FeaturedNovel> get featuredNovels =>
      UnmodifiableListView(
        _allNovels.whereType<FeaturedNovel>().toList(),
      );

  UnmodifiableListView<String> get genres {
    final uniqueGenres = _allNovels.map((novel) => novel.genre).toSet().toList()
      ..sort();
    return UnmodifiableListView(uniqueGenres);
  }

  String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.isNotEmpty;

  Future<void> loadCatalog() async {
    isLoading = true;
    try {
      final remote = await _catalogService.fetchNovels();
      if (remote.isNotEmpty) {
        _allNovels = remote;
        updateSearch(_searchQuery);
      }
      lastError = null;
    } catch (error) {
      lastError = error.toString();
    } finally {
      isLoading = false;
    }
  }

  void updateSearch(String query) {
    _searchQuery = query.trim();
    if (_searchQuery.isEmpty) {
      _visibleNovels = List<Novel>.from(_allNovels);
      return;
    }

    final lowerQuery = _searchQuery.toLowerCase();
    _visibleNovels = _allNovels.where((novel) {
      return novel.title.toLowerCase().contains(lowerQuery) ||
          novel.author.toLowerCase().contains(lowerQuery) ||
          novel.genre.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void clearSearch() {
    updateSearch('');
  }

  Novel? findById(String id) {
    try {
      return _allNovels.firstWhere((novel) => novel.id == id);
    } catch (_) {
      return null;
    }
  }
}
