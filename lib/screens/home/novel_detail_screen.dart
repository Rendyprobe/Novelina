import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/app_colors.dart';
import '../../core/cover_image_utils.dart';
import '../../core/storage_helper.dart';
import '../../models/novel_model.dart';
import '../../services/bookmark_service.dart';
import '../../services/rating_service.dart';
import '../../services/novel_catalog_service.dart';
import 'novel_reader_screen.dart';

class NovelDetailScreen extends StatefulWidget {
  const NovelDetailScreen({
    super.key,
    required this.novel,
  });

  final Novel novel;

  @override
  State<NovelDetailScreen> createState() => _NovelDetailScreenState();
}

class _NovelDetailScreenState extends State<NovelDetailScreen> {
  double _userRating = 0.0;
  bool _isLoading = true;
  bool _isBookmarked = false;
  bool _bookmarkReady = false;
  bool _bookmarkBusy = false;
  bool _bookmarkChanged = false;
  final BookmarkService _bookmarkService = const BookmarkService();
  final NovelCatalogService _catalogService = const NovelCatalogService();
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRating();
    _loadBookmarkStatus();
  }

  Future<void> _loadUserRating() async {
    final rating = await RatingService.getRating(widget.novel.id);
    if (!mounted) return;
    setState(() {
      _userRating = rating;
      widget.novel.userRating = rating;
      _isLoading = false;
    });
  }

  Future<void> _loadBookmarkStatus() async {
    final userId = await StorageHelper.getUserId();
    final role = await StorageHelper.getUserRole();
    if (!mounted) return;

    setState(() {
      _userRole = role;
    });

    if (userId <= 0) {
      setState(() => _bookmarkReady = true);
      return;
    }

    try {
      final bookmarked = await _bookmarkService.isBookmarked(
        userId: userId,
        novelId: widget.novel.id,
      );
      if (!mounted) return;
      setState(() {
        _isBookmarked = bookmarked;
        _bookmarkReady = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _bookmarkReady = true);
    }
  }

  Future<void> _saveRating(double rating) async {
    await RatingService.saveRating(widget.novel.id, rating);
    if (!mounted) return;
    setState(() {
      _userRating = rating;
      widget.novel.userRating = rating;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rating ${rating.toStringAsFixed(1)} berhasil disimpan!'),
        backgroundColor: AppColors.secondaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleBookmark() async {
    if (_bookmarkBusy) return;

    final userId = await StorageHelper.getUserId();
    if (!mounted) return;

    if (userId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masuk untuk menyimpan bookmark.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _bookmarkBusy = true);

    try {
      if (_isBookmarked) {
        await _bookmarkService.removeBookmark(userId: userId, novelId: widget.novel.id);
      } else {
        await _bookmarkService.addBookmark(userId: userId, novelId: widget.novel.id);
      }

      if (!mounted) return;
      setState(() {
        _isBookmarked = !_isBookmarked;
        _bookmarkBusy = false;
        _bookmarkChanged = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBookmarked ? 'Novel ditambahkan ke bookmark.' : 'Novel dihapus dari bookmark.',
          ),
          backgroundColor: AppColors.secondaryBlue,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _bookmarkBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat memperbarui bookmark: ${error.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFeatured = widget.novel is FeaturedNovel;
    final featureTag = isFeatured ? (widget.novel as FeaturedNovel).featureTag : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _bookmarkChanged);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _bookmarkChanged),
          ),
          title: Text(widget.novel.title),
          backgroundColor: AppColors.primaryBlue,
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _buildCoverArtwork(),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.novel.title,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      _buildActionButtons(),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Karya ${widget.novel.author}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    alignment: WrapAlignment.start,
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      _InfoChip(
                                        icon: Icons.star_rounded,
                                        label: widget.novel.formattedRating,
                                        background: Colors.amber.withValues(alpha: 0.2),
                                        foreground: Colors.orange.shade800,
                                      ),
                                      _InfoChip(
                                        icon: Icons.menu_book_outlined,
                                        label: '${widget.novel.chapters} Bab',
                                      ),
                                      _InfoChip(
                                        icon: Icons.category_outlined,
                                        label: widget.novel.genre,
                                      ),
                                      if (featureTag != null)
                                        _InfoChip(
                                          icon: Icons.workspace_premium,
                                          label: featureTag,
                                          background: AppColors.primaryBlue.withValues(alpha: 0.15),
                                          foreground: AppColors.primaryBlue,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.novel.synopsis,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.7,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Berikan Rating Anda',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_isLoading)
                          const CircularProgressIndicator(color: AppColors.primaryBlue)
                        else
                          Column(
                            children: [
                              RatingBar.builder(
                                initialRating: _userRating,
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 45,
                                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: _saveRating,
                                glow: true,
                                glowColor: Colors.amber.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _userRating > 0
                                    ? 'Rating Anda: ${_userRating.toStringAsFixed(1)} / 5'
                                    : 'Ketuk bintang untuk memberi rating',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Singkat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.novel.marketingMessage(),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NovelReaderScreen(novel: widget.novel),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Baca Sekarang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final isAdmin = (_userRole ?? '').toLowerCase() == 'admin';
    final buttons = <Widget>[
      _buildBookmarkIcon(),
    ];

    if (isAdmin) {
      buttons.addAll([
        const SizedBox(width: 12),
        _buildDeleteButton(),
      ]);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: buttons,
    );
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Novel'),
          content: Text(
            'Yakin ingin menghapus "${widget.novel.title}"? Semua bab, komentar, dan statistik akan hilang.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
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

    setState(() => _bookmarkBusy = true);

    try {
      await _catalogService.deleteNovel(userId: userId, novelId: widget.novel.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Novel berhasil dihapus.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus novel: '),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _bookmarkBusy = false);
      }
    }
  }
  Widget _buildBookmarkIcon({Color color = AppColors.primaryBlue}) {
    if (!_bookmarkReady || _bookmarkBusy) {
      return const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
      );
    }

    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        iconSize: 26,
        onPressed: _toggleBookmark,
        tooltip: _isBookmarked ? 'Hapus dari bookmark' : 'Simpan ke bookmark',
        icon: Icon(
          _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.white),
      tooltip: 'Hapus novel ini',
      onPressed: _bookmarkBusy ? null : _confirmDelete,
    );
  }

  Widget _buildCoverArtwork() {
    final provider = resolveCoverImage(widget.novel.coverAsset);
    final border = BorderRadius.circular(20);
    final placeholder = Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: border,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.book_outlined, color: AppColors.primaryBlue),
    );

    if (provider is NetworkImage) {
      return Image.network(
        provider.url,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
      );
    }

    if (provider is AssetImage) {
      return Image.asset(
        provider.assetName,
        package: provider.package,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    return Image(
      image: provider,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final String label;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background ?? AppColors.primaryBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: foreground ?? AppColors.primaryBlue,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: foreground ?? AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}












