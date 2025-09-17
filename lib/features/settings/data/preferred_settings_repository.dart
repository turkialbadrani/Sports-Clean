
// lib/features/settings/data/preferred_settings_repository.dart
import 'package:hive/hive.dart';

class PreferredSettingsRepository {
  static const _prefsBoxName = 'user_prefs';

  Future<Box> _openPrefsBox() async {
    return await Hive.openBox(_prefsBoxName);
  }

  /// 🌙 الوضع الليلي
  Future<bool> getDarkMode() async {
    final box = await _openPrefsBox();
    return box.get('dark_mode', defaultValue: false);
  }

  Future<void> setDarkMode(bool value) async {
    final box = await _openPrefsBox();
    await box.put('dark_mode', value);
  }

  /// ⚽ الأندية المفضلة
  Future<List<int>> getPreferredTeams() async {
    final box = await _openPrefsBox();
    return List<int>.from(box.get('preferred_teams', defaultValue: []));
  }

  Future<void> setPreferredTeams(List<int> teams) async {
    final box = await _openPrefsBox();
    await box.put('preferred_teams', teams);
  }

  /// 👤 اللاعبين المفضلين
  Future<List<int>> getPreferredPlayers() async {
    final box = await _openPrefsBox();
    return List<int>.from(box.get('preferred_players', defaultValue: []));
  }

  Future<void> setPreferredPlayers(List<int> players) async {
    final box = await _openPrefsBox();
    await box.put('preferred_players', players);
  }
}
