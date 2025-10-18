import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../models/novel_chapter.dart';
import '../../models/novel_model.dart';
import '../../services/novel_catalog_service.dart';

class NovelReaderScreen extends StatefulWidget {
  const NovelReaderScreen({super.key, required this.novel});

  final Novel novel;

  @override
  State<NovelReaderScreen> createState() => _NovelReaderScreenState();
}

class _NovelReaderScreenState extends State<NovelReaderScreen> {
  static const EdgeInsets _pageMargin = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 18,
  );
  static const EdgeInsets _pagePadding = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 22,
  );
  static const double _maxPageTurnRadians = 0.9;

  final NovelCatalogService _catalogService = const NovelCatalogService();
  final PageController _pageController = PageController();

  List<NovelChapter> _chapters = const [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentChapterIndex = 0;
  bool _showSwipeHint = true;
  double _fontSize = 18;

  static const double _minFontSize = 14;
  static const double _maxFontSize = 26;
  static const double _fontStep = 2;

  TextStyle get _bodyTextStyle => GoogleFonts.literata(
    fontSize: _fontSize,
    height: 1.6,
    color: Colors.black87,
  );

  @override
  void initState() {
    super.initState();
    _fetchChapters();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _showSwipeHint = false);
      }
    });
  }

  Future<void> _fetchChapters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final chapters = await _catalogService.fetchChapters(widget.novel.id);
      if (!mounted) return;

      setState(() {
        _chapters = chapters.isEmpty ? [_buildFallbackChapter()] : chapters;
        _currentChapterIndex = 0;
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _chapters = [_buildFallbackChapter()];
        _currentChapterIndex = 0;
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  NovelChapter _buildFallbackChapter() {
    final fallbackContent = widget.novel.content.isNotEmpty
        ? widget.novel.content
        : 'Cerita akan segera tersedia. Mohon tunggu update selanjutnya.';
    return NovelChapter(chapterNo: 1, title: 'Bab 1', content: fallbackContent);
  }

  void _goToChapter(int targetIndex) {
    if (!_pageController.hasClients ||
        targetIndex == _currentChapterIndex ||
        targetIndex < 0 ||
        targetIndex >= _chapters.length) {
      return;
    }

    setState(() => _currentChapterIndex = targetIndex);

    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildFontControlButton({
    required String tooltip,
    required String asset,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final image = Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Image.asset(
        asset,
        width: 22,
        height: 22,
        filterQuality: FilterQuality.high,
        color: Colors.white,
        colorBlendMode: BlendMode.srcIn,
      ),
    );

    final iconWidget = Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: image,
    );

    return IconButton(
      tooltip: tooltip,
      onPressed: enabled ? onTap : null,
      icon: iconWidget,
      splashRadius: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 38, height: 38),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chaptersCount = _chapters.length;
    final textStyle = _bodyTextStyle;
    final canDecreaseFont = _fontSize > _minFontSize;
    final canIncreaseFont = _fontSize < _maxFontSize;
    final overlayTopOffset = _pageMargin.top + 12;
    final overlayRightOffset = _pageMargin.right + 12;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.novel.title),
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading && chaptersCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    iconSize: 24,
                    icon: Icon(
                      Icons.chevron_left,
                      color: _currentChapterIndex > 0
                          ? Colors.white
                          : Colors.white38,
                    ),
                    onPressed: _currentChapterIndex > 0
                        ? () => _goToChapter(_currentChapterIndex - 1)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${_currentChapterIndex + 1} / $chaptersCount',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    iconSize: 24,
                    icon: Icon(
                      Icons.chevron_right,
                      color: _currentChapterIndex < chaptersCount - 1
                          ? Colors.white
                          : Colors.white38,
                    ),
                    onPressed: _currentChapterIndex < chaptersCount - 1
                        ? () => _goToChapter(_currentChapterIndex + 1)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              )
            : chaptersCount == 0
            ? _buildEmptyState()
            : Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFFFF0), Color(0xFFF7F0D8)],
                      ),
                    ),
                  ),
                  PageView.builder(
                    controller: _pageController,
                    itemCount: chaptersCount,
                    physics: const PageScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentChapterIndex = index);
                      HapticFeedback.lightImpact();
                    },
                    itemBuilder: (context, index) {
                      return _AnimatedChapterPage(
                        pageController: _pageController,
                        index: index,
                        currentIndex: _currentChapterIndex,
                        margin: _pageMargin,
                        padding: _pagePadding,
                        chapter: _chapters[index],
                        textStyle: textStyle,
                      );
                    },
                  ),
                  if (chaptersCount > 0)
                    Positioned(
                      top: overlayTopOffset,
                      right: overlayRightOffset,
                      child: Material(
                        type: MaterialType.transparency,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildFontControlButton(
                              tooltip: 'Perbesar teks',
                              asset: 'assets/icons/zoom_in.png',
                              enabled: canIncreaseFont,
                              onTap: () => setState(() {
                                _fontSize = (_fontSize + _fontStep).clamp(
                                  _minFontSize,
                                  _maxFontSize,
                                );
                              }),
                            ),
                            const SizedBox(width: 12),
                            _buildFontControlButton(
                              tooltip: 'Perkecil teks',
                              asset: 'assets/icons/zoom_out.png',
                              enabled: canDecreaseFont,
                              onTap: () => setState(() {
                                _fontSize = (_fontSize - _fontStep).clamp(
                                  _minFontSize,
                                  _maxFontSize,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_showSwipeHint) _buildSwipeHint(),
                  if (_errorMessage != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Gagal memuat bab dari server. Menampilkan konten lokal.',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildSwipeHint() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedOpacity(
          opacity: _showSwipeHint ? 1 : 0,
          duration: const Duration(milliseconds: 400),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Geser ke kanan atau kiri untuk berganti bab',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 16),
            Text(
              'Bab novel belum tersedia.',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan kembali lagi nanti untuk membaca cerita lengkapnya.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedChapterPage extends StatelessWidget {
  const _AnimatedChapterPage({
    required this.pageController,
    required this.index,
    required this.currentIndex,
    required this.margin,
    required this.padding,
    required this.chapter,
    required this.textStyle,
  });

  final PageController pageController;
  final int index;
  final int currentIndex;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final NovelChapter chapter;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        double value = 0;
        if (pageController.position.haveDimensions) {
          value = pageController.page! - index;
        } else {
          value = (currentIndex - index).toDouble();
        }
        value = value.clamp(-1.0, 1.0);

        final rotation = value * _NovelReaderScreenState._maxPageTurnRadians;
        final translation = value * MediaQuery.of(context).size.width * -0.18;
        final tilt = value.abs() * 0.02;

        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(rotation)
          ..rotateZ(value * 0.02);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(translation, 0),
            child: Transform.scale(scale: 1 - tilt, child: child),
          ),
        );
      },
      child: _ChapterPage(
        margin: margin,
        padding: padding,
        chapter: chapter,
        textStyle: textStyle,
      ),
    );
  }
}

class _ChapterPage extends StatelessWidget {
  const _ChapterPage({
    required this.margin,
    required this.padding,
    required this.chapter,
    required this.textStyle,
  });

  final EdgeInsets margin;
  final EdgeInsets padding;
  final NovelChapter chapter;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Scrollbar(
          thickness: 4,
          radius: const Radius.circular(12),
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  chapter.content.trim().isEmpty
                      ? 'Bab ini belum memiliki konten.'
                      : chapter.content,
                  style: textStyle,
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}






