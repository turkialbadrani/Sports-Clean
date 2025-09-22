import 'package:today_smart/features/localization/ar_names.dart';

String teamNameAr(int? id, String? en) {
  final fallback = en ?? '';
  if (id == null) return fallback;
  final ar = teamArById(id, fallback);
  return ar ?? fallback;
}
