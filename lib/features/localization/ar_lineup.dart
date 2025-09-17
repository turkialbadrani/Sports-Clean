// lib/features/localization/ar_lineup.dart

/// ✅ تعريب مراكز اللاعبين في التشكيلة
String lineupPositionAr(String pos) {
  final map = {
    "G": "حارس مرمى",
    "D": "مدافع",
    "M": "وسط",
    "F": "مهاجم",
  };

  return map[pos] ?? pos; // fallback لو طلع رمز جديد غير متوقع
}
