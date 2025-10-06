import 'package:shared_preferences/shared_preferences.dart';

class RatingService {
  static const String _ratingPrefix = 'novel_rating_';

  // Simpan rating novel
  static Future<void> saveRating(String novelId, double rating) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_ratingPrefix$novelId', rating);
  }

  // Ambil rating novel
  static Future<double> getRating(String novelId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$_ratingPrefix$novelId') ?? 0.0;
  }

  // Cek apakah user sudah memberi rating
  static Future<bool> hasUserRated(String novelId) async {
    final rating = await getRating(novelId);
    return rating > 0;
  }
}