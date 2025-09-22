import 'package:flutter/foundation.dart';
import 'package:today_smart/features/leagues/services/leagues_repository.dart';
import 'package:today_smart/features/leagues/models/league_tree.dart';
import 'package:today_smart/features/leagues/models/league.dart';

enum LoadState { idle, loading, success, error }

class LeaguesProvider with ChangeNotifier {
  LoadState state = LoadState.idle;
  String? error;

  List<LeagueModel> _allLeagues = [];

  List<LeagueModel> get allLeagues => _allLeagues;

  /// 🟢 تحميل الدوريات من Hive (أو JSON إذا فاضي)
  Future<void> loadLeagues() async {
    state = LoadState.loading;
    notifyListeners();
    try {
      await LeaguesRepository.loadLeaguesToHive();
      _allLeagues = LeaguesRepository.getAllFromHive();

      state = LoadState.success;
    } catch (e) {
      error = e.toString();
      state = LoadState.error;
    }
    notifyListeners();
  }

  /// ✅ تبني البيانات كشجرة مرتبة (قارات → دول → بطولات)
  List<LeagueTree> get treeData {
    final grouped = <String, Map<String, List<LeagueModel>>>{};

    for (final league in _allLeagues) {
      final continent = (league.continent?.trim().isNotEmpty ?? false)
          ? league.continent!.trim()
          : "Other";

      final country = (league.country?.trim().isNotEmpty ?? false)
          ? league.country!.trim()
          : "غير معروف";

      grouped.putIfAbsent(continent, () => {});
      grouped[continent]!.putIfAbsent(country, () => []);
      grouped[continent]![country]!.add(league);
    }

    return grouped.entries.map((continentEntry) {
      return LeagueTree(
        name: continentEntry.key,
        countries: continentEntry.value.entries.map((countryEntry) {
          return CountryTree(
            name: countryEntry.key,
            flag: "", // بإمكانك تربط أعلام لاحقاً إذا عندك مصدر
            continent: continentEntry.key,
            leagues: countryEntry.value.map((l) {
              return LeagueNode(
                id: l.id,
                name: l.name,
                logo: l.logoUrl ?? "",
                season: 0, // مواسم تجيبها من API عند الحاجة
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();
  }
}
