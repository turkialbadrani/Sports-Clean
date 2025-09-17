// lib/features/settings/settings_provider.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'data/preferred_settings_repository.dart';
import 'package:today_smart/core/json_to_hive/hive_boxes.dart';

class SettingsProvider with ChangeNotifier {
  final PreferredSettingsRepository _repo = PreferredSettingsRepository();

  bool _darkMode = false;
  List<int> _preferredLeagues = [];
  List<int> _preferredTeams = [];
  List<int> _preferredPlayers = [];

  bool get isDarkMode => _darkMode;
  List<int> get preferredLeagues => _preferredLeagues;
  List<int> get preferredTeams => _preferredTeams;
  List<int> get preferredPlayers => _preferredPlayers;

  /// 🟢 تحميل الإعدادات
  Future<void> loadPreferences() async {
    _darkMode = await _repo.getDarkMode();

    final prefsBox = await Hive.openBox('user_prefs');

    // ⚽ الدوريات المفضلة
    _preferredLeagues =
        List<int>.from(prefsBox.get('preferred_leagues', defaultValue: []));
    if (_preferredLeagues.isEmpty) {
      final jsonString = await rootBundle
          .loadString('assets/localization/preferred_leagues.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _preferredLeagues = List<int>.from(jsonList);
      await prefsBox.put('preferred_leagues', _preferredLeagues);
    }

    // 🏟 الأندية المفضلة
    _preferredTeams =
        List<int>.from(prefsBox.get('preferred_teams', defaultValue: []));

    // 👤 اللاعبين المفضلين
    _preferredPlayers =
        List<int>.from(prefsBox.get('preferred_players', defaultValue: []));

    notifyListeners();
  }

  /// 🌙 الوضع الداكن
  Future<void> toggleDarkMode(bool value) async {
    _darkMode = value;
    await _repo.setDarkMode(value);
    notifyListeners();
  }

  /// ⚽ تحديث الدوريات المفضلة (يتأكد من وجودها في Hive)
  Future<void> updatePreferredLeagues(List<int> leagues) async {
    final box = Hive.box(HiveBoxes.leagues);
    final all = box.get('all', defaultValue: []) as List;

    final validIds = all
        .where((e) => e is Map && e['id'] != null)
        .map<int>((e) => e['id'] as int)
        .toSet();

    _preferredLeagues = leagues.where((id) => validIds.contains(id)).toList();

    final prefsBox = Hive.box('user_prefs');
    await prefsBox.put('preferred_leagues', _preferredLeagues);

    notifyListeners();
  }

  /// 🏟 تحديث الأندية المفضلة
  Future<void> updatePreferredTeams(List<int> teams) async {
    final box = Hive.box(HiveBoxes.clubs);
    final all = box.get('all', defaultValue: []) as List;

    final validIds = all
        .where((e) => e is Map && e['id'] != null)
        .map<int>((e) => e['id'] as int)
        .toSet();

    _preferredTeams = teams.where((id) => validIds.contains(id)).toList();

    final prefsBox = Hive.box('user_prefs');
    await prefsBox.put('preferred_teams', _preferredTeams);

    notifyListeners();
  }

  /// 👤 تحديث اللاعبين المفضلين
  Future<void> updatePreferredPlayers(List<int> players) async {
    final box = Hive.box(HiveBoxes.players);
    final all = box.get('all', defaultValue: []) as List;

    final validIds = all
        .where((e) => e is Map && e['id'] != null)
        .map<int>((e) => e['id'] as int)
        .toSet();

    _preferredPlayers =
        players.where((id) => validIds.contains(id)).toList();

    final prefsBox = Hive.box('user_prefs');
    await prefsBox.put('preferred_players', _preferredPlayers);

    notifyListeners();
  }
}
