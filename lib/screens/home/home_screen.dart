import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../core/app_colors.dart';
import '../../core/cover_image_utils.dart';
import '../../core/storage_helper.dart';
import '../../models/novel_model.dart';
import '../../viewmodels/home_view_model.dart';
import '../../services/bookmark_service.dart';
import '../../services/novel_catalog_service.dart';
import '../admin/admin_upload_screen.dart';
import '../profile/profile_screen.dart';
import 'novel_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.openAdminUploadOnInit = false});

  final bool openAdminUploadOnInit;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _novelsPerPage = 10;

  late final HomeViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final BookmarkService _bookmarkService = const BookmarkService();
  final NovelCatalogService _catalogService = const NovelCatalogService();

  String _userName = '';
  String _userRole = 'user';
  int _selectedIndex = 0;
  bool _isBookmarkLoading = false;
  bool _bookmarkRequiresLogin = false;
  String? _bookmarkError;
  List<Novel> _bookmarkedNovels = [];
  bool _didScheduleInitialAdminUpload = false;
  String? _deletingNovelId;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final name = await StorageHelper.getUserName();
    final role = await StorageHelper.getUserRole();
    if (!mounted) return;
    setState(() {
      _userName = name;
      _userRole = role;
    });
    if (widget.openAdminUploadOnInit &&
        !_didScheduleInitialAdminUpload &&
        role == 'admin') {
      _didScheduleInitialAdminUpload = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _openAdminPanel();
        }
      });
    }
    await _refreshCatalog();
  }

  Future<void> _refreshCatalog() async {
    setState(() {
      _viewModel.isLoading = true;
    });
    await _viewModel.loadCatalog();
    if (!mounted) return;
    setState(() {
      _currentPage = 0;
    });
  }

  Future<void> _loadBookmarks() async {
    final userId = await StorageHelper.getUserId();
    if (!mounted) return;

    if (userId <= 0) {
      setState(() {
        _bookmarkRequiresLogin = true;
        _isBookmarkLoading = false;
        _bookmarkError = null;
        _bookmarkedNovels = [];
      });
      return;
    }

    setState(() {
      _bookmarkRequiresLogin = false;
      _isBookmarkLoading = true;
      _bookmarkError = null;
    });

    try {
      final bookmarks = await _bookmarkService.fetchBookmarks(userId);
      if (!mounted) return;
      setState(() {
        _bookmarkedNovels = bookmarks;
        _bookmarkError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _bookmarkError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBookmarkLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _viewModel.updateSearch(value);
      _currentPage = 0;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  void _applyGenreFilter(String genre) {
    _viewModel.applyGenreFilter(genre);
    setState(() {
      _currentPage = 0;
    });
  }

  void _clearGenreFilter() {
    if (_viewModel.activeGenre == null) return;
    _viewModel.applyGenreFilter(null);
    setState(() {
      _currentPage = 0;
    });
  }

  void _setPage(int page) {
    if (page == _currentPage) return;
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _openAdminPanel() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AdminUploadScreen()),
    );
    if (result == true) {
      await _refreshCatalog();
    }
  }

  String get _greetingText {
    if (_userName.trim().isEmpty) {
      return 'Halo, Novelina';
    }
    final segments = _userName.trim().split(RegExp(r'\s+'));
    final firstName = segments.isEmpty ? _userName.trim() : segments.first;
    return 'Halo, $firstName';
  }

  void _onBottomNavTap(int index) {
    if (index == 2) {
      if (_selectedIndex != 2) {
        setState(() => _selectedIndex = 2);
      }
      return;
    }

    if (_selectedIndex == index) {
      if (index == 1) {
        _loadBookmarks();
      }
      return;
    }

    setState(() => _selectedIndex = index);
    if (index == 1) {
      _loadBookmarks();
    }
  }

  void _openNovelDetail(Novel novel) {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => NovelDetailScreen(novel: novel)),
    ).then((updated) {
      if (updated == true && mounted) {
        _loadBookmarks();
      }
    });
  }

  Future<void> _handleDelete(Novel novel) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Novel'),
          content: Text(
            'Hapus "${novel.title}" dari katalog? Semua bab, statistik, dan bookmark akan hilang.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final userId = await StorageHelper.getUserId();
    if (!mounted) return;

    if (userId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi admin tidak ditemukan. Silakan masuk kembali.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _deletingNovelId = novel.id);

    try {
      await _catalogService.deleteNovel(userId: userId, novelId: novel.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Novel berhasil dihapus.'),
          backgroundColor: Colors.redAccent,
        ),
      );

      setState(() {
        _bookmarkedNovels.removeWhere((item) => item.id == novel.id);
      });

      await _refreshCatalog();
      if (mounted && _selectedIndex == 1) {
        await _loadBookmarks();
      }
    } catch (error) {
      if (!mounted) return;
      final rawMessage = error.toString();
      final message = rawMessage.startsWith('Exception: ')
          ? rawMessage.substring(11)
          : rawMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus novel: $message'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _deletingNovelId = null);
      } else {
        _deletingNovelId = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget homeChild;
    if (_viewModel.isLoading) {
      homeChild = _buildLoadingState();
    } else if (_viewModel.isSearching) {
      homeChild = _buildSearchResult();
    } else {
      homeChild = _buildHomeBody();
    }

    final homeContent = AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: homeChild,
    );

    final isProfileTab = _selectedIndex == 2;

    Widget bodyContent;
    PreferredSizeWidget? appBar;
    if (isProfileTab) {
      bodyContent = const ProfileView();
      appBar = null;
    } else if (_selectedIndex == 1) {
      bodyContent = RefreshIndicator(
        onRefresh: _loadBookmarks,
        child: _buildBookmarkBody(),
      );
      appBar = _buildAppBar();
    } else {
      bodyContent = RefreshIndicator(
        onRefresh: _refreshCatalog,
        child: homeContent,
      );
      appBar = _buildAppBar();
    }

    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: appBar,
      bottomNavigationBar: _buildBottomNavigation(),
      body: bodyContent,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(140),
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greetingText,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Apa yang ingin kamu baca hari ini?',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_userRole == 'admin')
                      IconButton(
                        icon: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                        ),
                        tooltip: 'Panel Admin',
                        onPressed: _openAdminPanel,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Cari judul, penulis, atau genre...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primaryBlue,
                      ),
                      suffixIcon: _viewModel.isSearching
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.primaryBlue,
                              ),
                              onPressed: _clearSearch,
                              tooltip: 'Bersihkan pencarian',
                            )
                          : null,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeBody() {
    final featured = _viewModel.featuredNovels;
    final popular = _viewModel.visibleNovels.toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final genres = _viewModel.genres;
    final isAdmin = _userRole.toLowerCase() == 'admin';
    final hasDeletionInProgress = _deletingNovelId != null;

    final totalPages = (popular.length / _novelsPerPage).ceil();
    int currentPage;
    if (totalPages == 0) {
      currentPage = 0;
    } else {
      currentPage = _currentPage.clamp(0, totalPages - 1);
    }

    if (currentPage != _currentPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentPage = currentPage);
        }
      });
    }

    final startIndex = currentPage * _novelsPerPage;
    final pageItems = popular
        .skip(startIndex)
        .take(_novelsPerPage)
        .toList(growable: false);

    return ListView(
      key: const ValueKey('home-content'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        if (featured.isNotEmpty) ...[
          const _SectionTitle('Pilihan Editor'),
          const SizedBox(height: 12),
          _buildFeaturedCarousel(featured),
          const SizedBox(height: 28),
        ],
        if (genres.isNotEmpty) ...[
          const _SectionTitle('Genre Populer'),
          const SizedBox(height: 12),
          _buildGenreWrap(genres),
          const SizedBox(height: 28),
        ],
        const _SectionTitle('Daftar Novel'),
        const SizedBox(height: 12),
        if (popular.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                'Daftar novel belum tersedia.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          )
        else ...[
          for (final novel in pageItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _NovelListTile(
                novel: novel,
                onTap: () => _openNovelDetail(novel),
                featureTag: novel is FeaturedNovel ? novel.featureTag : null,
                showAdminControls: isAdmin,
                isDeleting: novel.id == _deletingNovelId,
                onDelete:
                    isAdmin &&
                        (!hasDeletionInProgress || novel.id == _deletingNovelId)
                    ? () => _handleDelete(novel)
                    : null,
              ),
            ),
          if (totalPages > 1) ...[
            const SizedBox(height: 8),
            _buildPaginationControls(totalPages, currentPage),
          ],
        ],
      ],
    );
  }

  Widget _buildSearchResult() {
    final results = _viewModel.visibleNovels;
    final isAdmin = _userRole.toLowerCase() == 'admin';
    final hasDeletionInProgress = _deletingNovelId != null;

    if (results.isEmpty) {
      return ListView(
        key: const ValueKey('search-empty'),
        padding: const EdgeInsets.all(32),
        children: const [
          SizedBox(height: 80),
          Icon(Icons.search_off, size: 64, color: Colors.black45),
          SizedBox(height: 16),
          Text(
            'Tidak ada hasil pencarian.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      );
    }

    final totalPages = (results.length / _novelsPerPage).ceil();
    int currentPage;
    if (totalPages == 0) {
      currentPage = 0;
    } else {
      currentPage = _currentPage.clamp(0, totalPages - 1);
    }

    if (currentPage != _currentPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentPage = currentPage);
        }
      });
    }

    final startIndex = currentPage * _novelsPerPage;
    final pageItems = results
        .skip(startIndex)
        .take(_novelsPerPage)
        .toList(growable: false);

    return ListView(
      key: const ValueKey('search-results'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        for (final novel in pageItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _NovelListTile(
              novel: novel,
              onTap: () => _openNovelDetail(novel),
              featureTag: novel is FeaturedNovel ? novel.featureTag : null,
              showAdminControls: isAdmin,
              isDeleting: novel.id == _deletingNovelId,
              onDelete:
                  isAdmin &&
                      (!hasDeletionInProgress || novel.id == _deletingNovelId)
                  ? () => _handleDelete(novel)
                  : null,
            ),
          ),
        if (totalPages > 1) ...[
          const SizedBox(height: 8),
          _buildPaginationControls(totalPages, currentPage),
        ],
      ],
    );
  }

  Widget _buildFeaturedCarousel(List<FeaturedNovel> featured) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.82),
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final novel = featured[index];
          return GestureDetector(
            onTap: () => _openNovelDetail(novel),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: resolveCoverImage(novel.coverAsset),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        novel.featureTag,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      novel.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'oleh ${novel.author}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      key: const ValueKey('loading-state'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 140),
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.staggeredDotsWave(
              color: AppColors.primaryBlue,
              size: 60,
            ),
            const SizedBox(height: 24),
            const Text(
              'Memuat katalog novel...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mohon tunggu sebentar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookmarkBody() {
    if (_isBookmarkLoading && _bookmarkedNovels.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 120),
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        ],
      );
    }

    if (_bookmarkRequiresLogin) {
      return _BookmarkPlaceholder(
        icon: Icons.lock_outline,
        title: 'Masuk untuk menyimpan',
        message: 'Masuk terlebih dahulu agar bookmark tersimpan di akunmu.',
        actionLabel: 'Masuk',
        onAction: () => _onBottomNavTap(2),
      );
    }

    if (_bookmarkError != null) {
      return _BookmarkPlaceholder(
        icon: Icons.error_outline,
        title: 'Tidak dapat memuat bookmark',
        message: _bookmarkError ?? 'Terjadi kesalahan.',
        actionLabel: 'Coba Lagi',
        onAction: () => _loadBookmarks(),
      );
    }

    if (_bookmarkedNovels.isEmpty) {
      return const _BookmarkPlaceholder(
        icon: Icons.bookmark_border,
        title: 'Belum ada bookmark',
        message:
            'Ketuk ikon bookmark di halaman detail untuk menyimpan novel favoritmu.',
      );
    }

    final isAdmin = _userRole.toLowerCase() == 'admin';
    final hasDeletionInProgress = _deletingNovelId != null;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _bookmarkedNovels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final novel = _bookmarkedNovels[index];
        return _NovelListTile(
          novel: novel,
          onTap: () => _openNovelDetail(novel),
          featureTag: novel is FeaturedNovel ? novel.featureTag : null,
          showAdminControls: isAdmin,
          isDeleting: novel.id == _deletingNovelId,
          onDelete:
              isAdmin &&
                  (!hasDeletionInProgress || novel.id == _deletingNovelId)
              ? () => _handleDelete(novel)
              : null,
        );
      },
    );
  }

  Widget _buildGenreWrap(List<String> genres) {
    final activeGenreLower = (_viewModel.activeGenre ?? '').toLowerCase();

    return Wrap(
      spacing: 6,
      runSpacing: 8,
      children: genres.map((genre) {
        final isSelected =
            activeGenreLower.isNotEmpty &&
            genre.toLowerCase() == activeGenreLower;

        final borderColor = isSelected
            ? AppColors.primaryBlue
            : AppColors.primaryBlue.withValues(alpha: 0.6);
        final backgroundColor = isSelected
            ? AppColors.primaryBlue
            : Colors.white;
        final textColor = isSelected ? Colors.white : AppColors.primaryBlue;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (isSelected) {
                _clearGenreFilter();
              } else {
                _applyGenreFilter(genre);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                genre,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaginationControls(int totalPages, int currentPage) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final pageButtons = List<Widget>.generate(totalPages, (index) {
      final isActive = index == currentPage;
      return OutlinedButton(
        onPressed: () => _setPage(index),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(40, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          backgroundColor: Colors.white,
          foregroundColor: isActive ? AppColors.primaryBlue : Colors.black87,
          side: BorderSide(
            color: isActive ? AppColors.secondaryBlue : Colors.grey.shade400,
            width: isActive ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text('${index + 1}'),
      );
    });

    pageButtons.add(
      FilledButton(
        onPressed: currentPage < totalPages - 1
            ? () => _setPage(currentPage + 1)
            : null,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Selanjutnya →'),
      ),
    );

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: pageButtons,
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onBottomNavTap,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: Colors.grey.shade500,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border),
          label: 'Bookmark',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryBlue,
      ),
    );
  }
}

class _NovelListTile extends StatelessWidget {
  const _NovelListTile({
    required this.novel,
    required this.onTap,
    this.featureTag,
    this.showAdminControls = false,
    this.isDeleting = false,
    this.onDelete,
  });

  final Novel novel;
  final VoidCallback onTap;
  final String? featureTag;
  final bool showAdminControls;
  final bool isDeleting;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final deleteIconColor = onDelete == null
        ? Colors.redAccent.withValues(alpha: 0.35)
        : Colors.redAccent;

    return Material(
      color: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.zero,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRect(child: _CoverImage(path: novel.coverAsset)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            novel.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (featureTag != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              featureTag!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                        if (showAdminControls) ...[
                          const SizedBox(width: 6),
                          if (isDeleting)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.redAccent,
                              ),
                            )
                          else
                            IconButton(
                              onPressed: onDelete,
                              tooltip: 'Hapus novel',
                              padding: EdgeInsets.zero,
                              splashRadius: 18,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: Icon(
                                Icons.delete_outline,
                                color: deleteIconColor,
                                size: 20,
                              ),
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      novel.author,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      novel.marketingMessage(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        novel.formattedRating,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${novel.chapters} Bab',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 60,
      height: 80,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.book_outlined, color: AppColors.primaryBlue),
    );

    final provider = resolveCoverImage(path);

    if (provider is NetworkImage) {
      return Image.network(
        provider.url,
        width: 60,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder;
        },
      );
    }

    if (provider is AssetImage) {
      return Image.asset(
        provider.assetName,
        package: provider.package,
        width: 60,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    return Image(
      image: provider,
      width: 60,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

class _BookmarkPlaceholder extends StatelessWidget {
  const _BookmarkPlaceholder({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 140),
      children: [
        Column(
          children: [
            Icon(icon, size: 64, color: AppColors.primaryBlue),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey.shade700,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
