import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/fixture.dart';
import '../services/fixtures_repository.dart';

// ✅ استدعاء الفلاتر من ملف مركزي
import '../utils/fixtures_filters.dart';
import '../../localization/ar_names.dart';
import 'package:today_smart/core/json_to_hive/hive_boxes.dart';

class FixturesController {
  late final FixturesRepository repo;

  FixturesController() {
    // 🟢 قراءة الدوريات المفضلة من Hive
    final prefsBox = Hive.box('user_prefs');
    final hiveLeagues =
        (prefsBox.get('preferred_leagues') as List?)?.cast<int>() ?? <int>[];

    // 🟡 إذا فاضي → نجيب الدوريات كلها من Hive (leagues box)
    final leaguesBox = Hive.box(HiveBoxes.leagues);
    final fallbackLeagues = (leaguesBox.get('all', defaultValue: []) as List)
        .map((e) => (e as Map)['id'] as int?)
        .whereType<int>()
        .toList();

    final allowedLeagues =
        hiveLeagues.isNotEmpty ? hiveLeagues : fallbackLeagues;

    repo = FixturesRepository(
      apiKey: dotenv.env['API_KEY'] ?? '',
      allowedLeagues: allowedLeagues,
    );
  }

  /// ✅ جلب المباريات لتاريخ محدد مع فلترة إضافية بالتاريخ
  Future<List<FixtureModel>> getFixturesByDate(DateTime date) async {
    final fixtures = await repo.getFixtures(date: date);

    // 🔹 نفلترهم عشان يطابقون التاريخ المطلوب
    final filtered = filterByDate(fixtures, date);

    // 🟡 Debug: نطبع إذا فيه أسماء أندية بالإنجليزي
    final regexEnglish = RegExp(r'[A-Za-z]');

    for (var f in filtered) {
      final home = teamArByIdWithFallback(f.home.id, f.home.name);
      final away = teamArByIdWithFallback(f.away.id, f.away.name);

      if (regexEnglish.hasMatch(home)) {
        print(
            "\x1B[33m🟡 نادي مكتوب بالإنجليزي: ID=${f.home.id}, name=$home\x1B[0m");
      }
      if (regexEnglish.hasMatch(away)) {
        print(
            "\x1B[33m🟡 نادي مكتوب بالإنجليزي: ID=${f.away.id}, name=$away\x1B[0m");
      }
    }

    return filtered;
  }
}
