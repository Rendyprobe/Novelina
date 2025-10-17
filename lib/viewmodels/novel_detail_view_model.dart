import '../models/comment_model.dart';
import '../models/novel_stats.dart';
import '../services/novel_interaction_service.dart';

class NovelDetailViewModel {
  NovelDetailViewModel({NovelInteractionService? service})
      : _service = service ?? const NovelInteractionService();

  final NovelInteractionService _service;

  NovelStats stats = const NovelStats(readCount: 0, commentCount: 0);
  List<NovelComment> comments = const [];
  bool statsLoading = true;
  bool commentsLoading = true;
  bool submittingComment = false;

  Future<void> initialize(String novelId) async {
    await Future.wait([
      _loadStats(novelId),
      _loadComments(novelId),
    ]);
  }

  Future<void> refresh(String novelId) async {
    await Future.wait([
      _loadStats(novelId),
      _loadComments(novelId),
    ]);
  }

  Future<void> _loadStats(String novelId) async {
    statsLoading = true;
    try {
      final loaded = await _service.fetchStats(novelId);
      stats = loaded;
    } finally {
      statsLoading = false;
    }
  }

  Future<void> _loadComments(String novelId) async {
    commentsLoading = true;
    try {
      comments = await _service.fetchComments(novelId);
    } finally {
      commentsLoading = false;
    }
  }

  Future<void> recordRead(String novelId) async {
    stats = await _service.incrementRead(novelId);
  }

  Future<NovelComment> addComment({
    required String novelId,
    required String userName,
    required String content,
  }) async {
    submittingComment = true;
    try {
      final comment = await _service.submitComment(
        novelId: novelId,
        userName: userName,
        content: content,
      );
      comments = [comment, ...comments];
      stats = stats.copyWith(commentCount: stats.commentCount + 1);
      return comment;
    } finally {
      submittingComment = false;
    }
  }
}
