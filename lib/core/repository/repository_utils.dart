class RepositoryUtils {
  /// 🔢 يحول أي قيمة إلى int بشكل آمن
  static int asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  /// 📅 يحدد أفضل موسم للاستخدام في API
  static int bestSeasonForApi() {
    final now = DateTime.now();
    return now.month >= 7 ? now.year : now.year - 1;
  }
}
