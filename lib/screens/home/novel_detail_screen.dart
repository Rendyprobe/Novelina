import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/app_colors.dart';
import '../../models/novel_model.dart';
import '../../services/rating_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  Future<void> _loadUserRating() async {
    final rating = await RatingService.getRating(widget.novel.id);
    setState(() {
      _userRating = rating;
      widget.novel.userRating = rating;
      _isLoading = false;
    });
  }

  Future<void> _saveRating(double rating) async {
    await RatingService.saveRating(widget.novel.id, rating);
    setState(() {
      _userRating = rating;
      widget.novel.userRating = rating;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rating ${rating.toStringAsFixed(1)} berhasil disimpan!'),
          backgroundColor: AppColors.secondaryBlue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFeatured = widget.novel is FeaturedNovel;
    final featureTag = isFeatured ? (widget.novel as FeaturedNovel).featureTag : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.novel.title),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
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
                            child: Image.asset(
                              widget.novel.coverAsset,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.novel.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
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
                
                // Rating Widget Section
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
                        const CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        )
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
                              onRatingUpdate: (rating) {
                                _saveRating(rating);
                              },
                              glow: true,
                              glowColor: Colors.amber.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _userRating > 0 
                                ? 'Rating Anda: ${_userRating.toStringAsFixed(1)} ⭐'
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
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mengapa Kamu Harus Membaca?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Novel ini menawarkan pengalaman membaca yang kaya dengan karakter menarik, konflik yang mendalam, dan pesan moral yang menginspirasi. Cocok dinikmati saat santai maupun sebagai bahan diskusi bersama teman.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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