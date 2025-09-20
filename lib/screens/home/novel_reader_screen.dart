import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/novel_model.dart';

class NovelReaderScreen extends StatelessWidget {
  const NovelReaderScreen({
    super.key,
    required this.novel,
  });

  final Novel novel;

  @override
  Widget build(BuildContext context) {
    final paragraphs = novel.content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Baca ${novel.title}'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        novel.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Oleh ${novel.author}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...paragraphs.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            line,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
