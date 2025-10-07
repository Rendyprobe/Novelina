import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../models/novel_model.dart';
import '../../services/story_service.dart';

class NovelReaderScreen extends StatefulWidget {
  const NovelReaderScreen({super.key, required this.novel});

  final Novel novel;

  @override
  State<NovelReaderScreen> createState() => _NovelReaderScreenState();
}

class _NovelReaderScreenState extends State<NovelReaderScreen> {
  static const EdgeInsets _pageMargin = EdgeInsets.all(20);
  static const EdgeInsets _pagePadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 32,
  );

  late final PageController _pageController;

  String _storyContent = '';
  List<String> _pages = [];
  int _currentPageIndex = 0;
  Size? _lastCalculatedSize;
  bool _isPaginating = false;

  TextStyle get _pageTextStyle =>
      GoogleFonts.literata(fontSize: 18, height: 1.6, color: Colors.black87);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadStoryContent();
  }

  Future<void> _loadStoryContent() async {
    try {
      final content = await StoryService.loadStoryById(widget.novel.id);
      if (!mounted) return;
      setState(() {
        _storyContent = content;
        _pages = [];
        _lastCalculatedSize = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _storyContent = widget.novel.content;
        _pages = [];
        _lastCalculatedSize = null;
      });
    }
  }

  void _ensurePagination(Size availableSize, TextStyle textStyle) {
    if (_storyContent.isEmpty) return;
    if (availableSize.width <= 0 || availableSize.height <= 0) return;
    if (_isPaginating) return;
    if (_lastCalculatedSize == availableSize && _pages.isNotEmpty) return;

    _isPaginating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _isPaginating = false;
        return;
      }

      final newPages = _paginateContent(
        _storyContent,
        availableSize,
        textStyle,
      );

      setState(() {
        _pages = newPages;
        _currentPageIndex = _pages.isEmpty
            ? 0
            : _currentPageIndex.clamp(0, _pages.length - 1);
        _lastCalculatedSize = availableSize;
        _isPaginating = false;
      });

      if (_pageController.hasClients && _pages.isNotEmpty) {
        _pageController.jumpToPage(_currentPageIndex);
      }
    });
  }

  List<String> _paginateContent(String content, Size size, TextStyle style) {
    String remaining = content.replaceAll('\r\n', '\n').trimLeft();
    if (remaining.isEmpty) {
      return <String>[];
    }

    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
      maxLines: null,
    );

    final pages = <String>[];
    final whitespacePattern = RegExp(r'\s');

    while (remaining.isNotEmpty) {
      painter.text = TextSpan(text: remaining, style: style);
      painter.layout(maxWidth: size.width);

      if (painter.height <= size.height || remaining.length <= 1) {
        pages.add(remaining.trim());
        break;
      }

      final position = painter.getPositionForOffset(
        Offset(size.width, size.height),
      );

      var end = position.offset;

      if (end <= 0) {
        end = remaining.length;
      }
      if (end >= remaining.length) {
        pages.add(remaining.trim());
        break;
      }

      var safeEnd = end;
      while (safeEnd > 0 &&
          safeEnd <= remaining.length &&
          !whitespacePattern.hasMatch(remaining[safeEnd - 1])) {
        safeEnd--;
      }

      if (safeEnd <= 0 || safeEnd == end) {
        safeEnd = end;
      }

      final pageText = remaining.substring(0, safeEnd).trimRight();
      if (pageText.isEmpty) {
        pages.add(remaining.trim());
        break;
      }

      pages.add(pageText);
      remaining = remaining.substring(safeEnd).trimLeft();
    }

    return pages;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = _pageTextStyle;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.novel.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_pages.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentPageIndex + 1} / ${_pages.length}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _storyContent.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth =
                      constraints.maxWidth -
                      _pageMargin.horizontal -
                      _pagePadding.horizontal;
                  final availableHeight =
                      constraints.maxHeight -
                      _pageMargin.vertical -
                      _pagePadding.vertical;

                  if (availableWidth > 0 && availableHeight > 0) {
                    _ensurePagination(
                      Size(availableWidth, availableHeight),
                      textStyle,
                    );
                  }

                  if (_pages.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFFFF0), Color(0xFFF5F5DC)],
                          ),
                        ),
                      ),
                      PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPageIndex = index;
                          });
                          HapticFeedback.lightImpact();
                        },
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Center(
                            child: Container(
                              margin: _pageMargin,
                              padding: _pagePadding,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: Text(
                                  _pages[index],
                                  style: textStyle,
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Geser ke kanan atau kiri untuk berpindah halaman',
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
                  );
                },
              ),
      ),
    );
  }
}
