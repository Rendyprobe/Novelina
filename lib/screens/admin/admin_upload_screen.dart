import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_colors.dart';
import '../../core/storage_helper.dart';
import '../../services/novel_catalog_service.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _genreController = TextEditingController();
  final _ratingController = TextEditingController(text: '4.0');
  final _marketingController = TextEditingController();
  final _featureTagController = TextEditingController();

  final List<_ChapterFormData> _chapters = [
    _ChapterFormData(),
  ];

  String? _coverDataUri;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _synopsisController.dispose();
    _genreController.dispose();
    _ratingController.dispose();
    _marketingController.dispose();
    _featureTagController.dispose();
    for (final chapter in _chapters) {
      chapter.dispose();
    }
    super.dispose();
  }

  void _addChapter() {
    setState(() {
      _chapters.add(_ChapterFormData());
    });
  }

  void _removeChapter(int index) {
    if (_chapters.length <= 1) return;
    final removed = _chapters.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  Widget? _buildCoverPreview() {
    if (_coverDataUri == null) {
      return null;
    }

    final preview = _coverDataUri!;
    if (preview.startsWith('data:image')) {
      try {
        final bytes = base64.decode(preview.split(',').last);
        return Container(
          width: 90,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover),
          ),
        );
      } catch (_) {
        return null;
      }
    }

    return Container(
      width: 90,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(preview), fit: BoxFit.cover),
      ),
    );
  }

  Future<void> _pickCover() async {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unggah cover hanya tersedia pada versi web.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();
    await uploadInput.onChange.first;

    final file = uploadInput.files?.first;
    if (file == null) return;

    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    await reader.onLoad.first;

    setState(() {
      _coverDataUri = reader.result as String?;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_coverDataUri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan unggah gambar cover terlebih dahulu.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final chapterContents = <Map<String, dynamic>>[];
    for (var i = 0; i < _chapters.length; i++) {
      final chapter = _chapters[i];
      final title = chapter.titleController.text.trim();
      final content = chapter.contentController.text.trim();
      if (title.isEmpty || content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bab ke-${i + 1} belum lengkap.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      chapterContents.add({
        'chapter_no': i + 1,
        'title': title,
        'content': content,
      });
    }

    final ratingInput = _ratingController.text.trim();
    final parsedRating = ratingInput.isEmpty ? 0.0 : double.tryParse(ratingInput);
    if (parsedRating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format rating tidak valid. Gunakan angka, misalnya 4.5'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (parsedRating < 0 || parsedRating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating harus berada di antara 0 hingga 5.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    final rating = double.parse(parsedRating.toStringAsFixed(2));

    setState(() => _isSubmitting = true);

    try {
      final userId = await StorageHelper.getUserId();
      if (userId <= 0) {
        throw Exception('Sesi pengguna tidak ditemukan. Silakan masuk kembali.');
      }
      const service = NovelCatalogService();
      await service.createNovel(
        userId: userId,
        payload: {
          'id': _generateId(_titleController.text),
          'title': _titleController.text.trim(),
          'author': _authorController.text.trim(),
          'synopsis': _synopsisController.text.trim(),
          'genre': _genreController.text.trim(),
          'cover_asset': _coverDataUri,
          'marketing_message': _marketingController.text.trim().isEmpty
              ? null
              : _marketingController.text.trim(),
          'feature_tag': _featureTagController.text.trim().isEmpty
              ? null
              : _featureTagController.text.trim(),
          'rating': rating,
          'chapters': chapterContents.length,
          'chapter_contents': chapterContents,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Novel berhasil diunggah!'),
          backgroundColor: AppColors.secondaryBlue,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      final rawMessage = error.toString();
      final message = rawMessage.startsWith('Exception: ') ? rawMessage.substring(11) : rawMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunggah novel: $message'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _generateId(String title) {
    var slug = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    slug = slug.replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    if (slug.isEmpty) {
      return 'novel-${DateTime.now().millisecondsSinceEpoch}';
    }
    return slug;
  }

  @override
  Widget build(BuildContext context) {
    final coverPreview = _buildCoverPreview();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Novel Baru'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Judul Novel'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _authorController,
                      decoration: const InputDecoration(labelText: 'Penulis'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Penulis wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _genreController,
                      decoration: const InputDecoration(labelText: 'Genre'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Genre wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _synopsisController,
                      decoration: const InputDecoration(labelText: 'Sinopsis'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(labelText: 'Rating (0-5)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _marketingController,
                      decoration: const InputDecoration(labelText: 'Pesan Pemasaran (opsional)'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _featureTagController,
                      decoration: const InputDecoration(labelText: 'Feature Tag (opsional)'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _pickCover,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Unggah Cover'),
                        ),
                        const SizedBox(width: 16),
                        if (coverPreview != null) coverPreview,
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Daftar Bab',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._chapters.asMap().entries.map((entry) {
                      final index = entry.key;
                      final chapter = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Bab ${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (_chapters.length > 1)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        onPressed: _isSubmitting ? null : () => _removeChapter(index),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: chapter.titleController,
                                  decoration: const InputDecoration(labelText: 'Judul Bab'),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: chapter.contentController,
                                  decoration: const InputDecoration(labelText: 'Isi Bab'),
                                  maxLines: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _isSubmitting ? null : _addChapter,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Bab'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.cloud_upload_rounded),
                        label: Text(_isSubmitting ? 'Mengunggah...' : 'Simpan Novel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    );
  }
}

class _ChapterFormData {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  void dispose() {
    titleController.dispose();
    contentController.dispose();
  }
}

