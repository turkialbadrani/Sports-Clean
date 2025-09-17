// lib/features/fixtures/utils/fixtures_filters.dart
//
// ✅ هذا الملف يحتوي على جميع دوال الفلترة الخاصة بالمباريات.
// الهدف: مكان مركزي واحد يسهل تعديله وإعادة استخدامه في أي مكان.
// الفلاتر المتوفرة: حسب الدوري، الفريق، التاريخ.

import 'package:flutter/foundation.dart' show kReleaseMode;
import '../models/fixture.dart';

bool get _shouldLog => !kReleaseMode;

/// 🔹 فلترة حسب الدوريات المسموحة
List<FixtureModel> filterByAllowedLeagues(
  List<FixtureModel> fixtures,
  Set<int> allowedLeagues,
) {
  if (allowedLeagues.isEmpty) {
    if (_shouldLog) {
      print("⚠️ allowedLeagues فاضي → ما فيه نتائج");
    }
    return [];
  }

  final filtered =
      fixtures.where((f) => allowedLeagues.contains(f.league.id)).toList();

  if (_shouldLog) {
    print("🎯 filterByAllowedLeagues: "
        "input=${fixtures.length}, "
        "allowed=${allowedLeagues.length}, "
        "output=${filtered.length}");
  }

  return filtered;
}

/// 🔹 فلترة حسب فريق معيّن (Home أو Away)
List<FixtureModel> filterByTeam(
  List<FixtureModel> fixtures,
  int teamId,
) {
  final filtered =
      fixtures.where((f) => f.home.id == teamId || f.away.id == teamId).toList();

  if (_shouldLog) {
    print("🎯 filterByTeam: team=$teamId, output=${filtered.length}");
  }

  return filtered;
}

/// 🔹 فلترة حسب التاريخ (yyyy-MM-dd)
List<FixtureModel> filterByDate(
  List<FixtureModel> fixtures,
  DateTime date,
) {
  final filtered = fixtures.where((f) {
    final fixtureDate = f.date; // ✅ f.date هو DateTime من الموديل
    return fixtureDate.year == date.year &&
        fixtureDate.month == date.month &&
        fixtureDate.day == date.day;
  }).toList();

  if (_shouldLog) {
    print("🎯 filterByDate: ${date.toIso8601String()}, output=${filtered.length}");
  }

  return filtered;
}
