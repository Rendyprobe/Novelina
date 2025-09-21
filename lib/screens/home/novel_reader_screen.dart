import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../models/novel_model.dart';
import '../../services/story_service.dart';

class NovelReaderScreen extends StatefulWidget {
  final Novel novel;

  const NovelReaderScreen({
    super.key,
    required this.novel,
  });

  @override
  State<NovelReaderScreen> createState() => _NovelReaderScreenState();
}

class _NovelReaderScreenState extends State<NovelReaderScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  
  List<String> pages = [];
  int currentPageIndex = 0;
  bool isFlipping = false;
  String storyContent = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
    
    _loadStoryContent();
  }

  void _loadStoryContent() async {
    try {
      String content = await StoryService.loadStoryById(widget.novel.id);
      setState(() {
        storyContent = content;
        pages = _splitContentIntoPages(content);
      });
    } catch (e) {
      setState(() {
        storyContent = widget.novel.content;
        pages = _splitContentIntoPages(widget.novel.content);
      });
    }
  }

  List<String> _splitContentIntoPages(String content) {
    List<String> paragraphs = content.split('\n\n');
    List<String> pagesList = [];
    String currentPage = '';
    
    for (String paragraph in paragraphs) {
      if (paragraph.trim().isEmpty) continue;
      
      // Estimasi karakter per halaman (sekitar 1000 karakter)
      if (currentPage.length + paragraph.length > 1000 && currentPage.isNotEmpty) {
        pagesList.add(currentPage.trim());
        currentPage = '$paragraph\n\n';
      } else {
        currentPage = '$currentPage$paragraph\n\n';
      }
    }
    
    if (currentPage.trim().isNotEmpty) {
      pagesList.add(currentPage.trim());
    }
    
    return pagesList;
  }

  void _nextPage() {
    if (currentPageIndex < pages.length - 1 && !isFlipping) {
      setState(() {
        isFlipping = true;
      });
      
      _flipController.forward().then((_) {
        setState(() {
          currentPageIndex++;
          isFlipping = false;
        });
        _flipController.reset();
      });
      
      HapticFeedback.lightImpact();
    }
  }

  void _previousPage() {
    if (currentPageIndex > 0 && !isFlipping) {
      setState(() {
        isFlipping = true;
      });
      
      _flipController.forward().then((_) {
        setState(() {
          currentPageIndex--;
          isFlipping = false;
        });
        _flipController.reset();
      });
      
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Warna kertas lama
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.novel.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${currentPageIndex + 1} / ${pages.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: pages.isEmpty 
        ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryBlue,
            ),
          )
        : GestureDetector(
            onTapUp: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (details.localPosition.dx > screenWidth / 2) {
                _nextPage();
              } else {
                _previousPage();
              }
            },
            child: SizedBox.expand(
              child: Stack(
                children: [
                  // Background dengan efek kertas
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFFFF0), // Ivory
                          Color(0xFFF5F5DC), // Beige
                        ],
                      ),
                    ),
                  ),
                  
                  // Halaman utama
                  AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      return Transform(
                        alignment: Alignment.centerRight,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(-_flipAnimation.value * 0.5),
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pages[currentPageIndex],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.6,
                                    color: Colors.black87,
                                    fontFamily: 'serif',
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Indikator navigasi
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: currentPageIndex > 0 
                              ? AppColors.primaryBlue.withValues(alpha: 0.8)
                              : Colors.grey.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: IconButton(
                            onPressed: currentPageIndex > 0 ? _previousPage : null,
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Ketuk kiri/kanan untuk berpindah halaman',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: currentPageIndex < pages.length - 1 
                              ? AppColors.primaryBlue.withValues(alpha: 0.8)
                              : Colors.grey.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: IconButton(
                            onPressed: currentPageIndex < pages.length - 1 
                              ? _nextPage 
                              : null,
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}