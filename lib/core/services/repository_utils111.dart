class RepositoryUtils {
  /// تحديد الموسم الأنسب
  static int bestSeasonForApi() {
    final now = DateTime.now();
    return now.month >= 7 ? now.year : now.year - 1;
  }

  /// تحويل أي قيمة إلى int
  static int asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
