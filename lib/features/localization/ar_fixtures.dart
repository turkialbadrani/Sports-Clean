// lib/features/localization/ar_fixtures.dart

/// ✅ تعريب أنواع الأحداث
String eventTypeAr(String type, String? detail) {
  final map = {
    "Goal": "هدف",
    "Normal Goal": "هدف", // ✅ أهداف عادية
    "Own Goal": "هدف عكسي",
    "Penalty": "ضربة جزاء",
    "Missed Penalty": "ضربة جزاء ضائعة",

    "Card": "بطاقة",
    "Yellow Card": "بطاقة صفراء",
    "Red Card": "بطاقة حمراء",

    "subst": "تبديل",
    "Substitution": "تبديل",
    "Substitution 1": "تبديل 1",
    "Substitution 2": "تبديل 2",
    "Substitution 3": "تبديل 3",
    "Substitution 4": "تبديل 4",

    "Var": "حكم الفيديو",
    "VAR": "حكم الفيديو",
    "var": "حكم الفيديو",
  };

  // ✅ لو التفصيل فيه معلومة إضافية (زي "Yellow Card")
  if (detail != null && detail.isNotEmpty) {
    return map[detail] ?? detail;
  }

  return map[type] ?? type;
}

/// ✅ تعريب أنواع الإحصائيات
String statTypeAr(String type) {
  final map = {
    "Shots on Goal": "تسديدات على المرمى",
    "Shots off Goal": "تسديدات خارج المرمى",
    "Total Shots": "إجمالي التسديدات",
    "Blocked Shots": "تسديدات محجوبة",
    "Shots insidebox": "تسديدات داخل منطقة الجزاء",
    "Shots outsidebox": "تسديدات خارج منطقة الجزاء",
    "Fouls": "أخطاء",
    "Corner Kicks": "ركلات ركنية",
    "Offsides": "تسللات",
    "Ball Possession": "الاستحواذ",
    "Yellow Cards": "بطاقات صفراء",
    "Red Cards": "بطاقات حمراء",
    "Goalkeeper Saves": "تصديات الحارس",
    "Total passes": "إجمالي التمريرات",
    "Passes accurate": "التمريرات الصحيحة",
    "Passes %": "نسبة التمريرات الصحيحة",
    "expected_goals": "الأهداف المتوقعة",
    "goals_prevented": "الأهداف الموقوفة",
  };

  return map[type] ?? type; // fallback للإنجليزي لو ما فيه تعريب
}
