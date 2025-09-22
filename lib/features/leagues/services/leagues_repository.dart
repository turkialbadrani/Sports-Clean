import 'package:today_smart/config/app_config.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:today_smart/core/services/api_client.dart';
import 'package:today_smart/core/json_to_hive/hive_boxes.dart';
import 'package:hive/hive.dart';
import 'package:today_smart/features/leagues/models/league.dart';

class LeaguesRepository {
  final ApiClient _client;

  // ✅ كاش محلي للمفضلات
  static Set<int>? _preferredFromAssets;

  // ✅ مزود اختياري (مثلاً يقرأ من Hive)
  static Future<Set<int>> Function()? preferredIdsProvider;

  LeaguesRepository([ApiClient? client])
      : _client = client ??
            ApiClient(
              apiKey: AppConfig.apiKey,
              timezone: AppConfig.timezone,
              leagues: AppConfig.leagues,
            );

  factory LeaguesRepository.create() => LeaguesRepository();

  // =========================
  // مصادر التفضيل (IDs)
  // =========================

  /// 1) من assets/localization/leagues_extended.json
  static Future<Set<int>> _loadPreferredFromAssets() async {
    if (_preferredFromAssets != null) return _preferredFromAssets!;
    try {
      final raw = await rootBundle
          .loadString('assets/localization/leagues_extended.json');
      final list = json.decode(raw) as List<dynamic>;
      final ids = <int>{};
      for (final e in list) {
        if (e is Map && e['id'] != null) {
          ids.add(e['id'] as int);
        }
      }
      _preferredFromAssets = ids;
      return ids;
    } catch (_) {
      _preferredFromAssets = <int>{};
      return _preferredFromAssets!;
    }
  }

  /// دمج (assets + provider + .env)
  static Future<Set<int>> _resolvePreferredIds(List<int> envWhitelist) async {
    final fromAssets = await _loadPreferredFromAssets();
    final fromProvider =
        (preferredIdsProvider != null) ? await preferredIdsProvider!.call() : <int>{};
    final fromEnv = envWhitelist.toSet();
    return <int>{}..addAll(fromAssets)..addAll(fromProvider)..addAll(fromEnv);
  }

  // =========================
  // API (مباشر)
  // =========================

  /// يجلب الدوريات الحالية ويصفيها بالمفضلات
  Future<List<LeagueModel>> fetchLeagues() async {
    final res = await _client.get("leagues", params: {'current': true});

    var list = (res['response'] as List? ?? [])
        .map((e) => LeagueModel.fromJson(e))
        .toList();

    final preferred = await _resolvePreferredIds(_client.leagues);

    if (preferred.isNotEmpty) {
      list = list.where((l) => preferred.contains(l.id)).toList();
    }

    return list;
  }

  Future<List<LeagueModel>> getAllLeagues() => fetchLeagues();

  Future<dynamic> fetchLeagueDetails(int leagueId) async {
    final res = await _client.get("leagues", params: {'id': leagueId});
    return res['response'];
  }

  Future<int?> getCurrentSeason(int leagueId) async {
    final res = await _client.get("leagues", params: {'id': leagueId});
    final response = (res['response'] as List?) ?? const [];
    if (response.isEmpty) return null;

    final data = response.first;
    final seasons = (data is Map ? data['seasons'] as List? : null) ?? const [];

    for (final s in seasons) {
      if (s is Map && s['current'] == true) {
        final year = s['year'];
        if (year is int) return year;
      }
    }

    int? maxYear;
    for (final s in seasons) {
      if (s is Map && s['year'] is int) {
        final y = s['year'] as int;
        if (maxYear == null || y > maxYear) maxYear = y;
      }
    }
    return maxYear;
  }

  Future<List<int>> getSeasons(int leagueId) async {
    final res = await _client.get("leagues", params: {'id': leagueId});
    final response = (res['response'] as List?) ?? const [];
    if (response.isEmpty) return const [];

    final data = response.first;
    final seasons = (data is Map ? data['seasons'] as List? : null) ?? const [];
    final out = <int>[];

    for (final s in seasons) {
      final y = (s is Map) ? s['year'] : null;
      if (y is int) out.add(y);
    }
    out.sort();
    return out;
  }

  /// جلب فرق الدوري لموسم محدد
  Future<List<Map<String, dynamic>>> getTeamsByLeague(int leagueId,
      {int? season}) async {
    final useSeason = season ?? await getCurrentSeason(leagueId);
    if (useSeason == null) return const <Map<String, dynamic>>[];

    final res = await _client.get(
      "teams",
      params: {'league': leagueId, 'season': useSeason},
    );

    final raw = (res['response'] as List?) ?? const [];
    final typed = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is Map) {
        typed.add(Map<String, dynamic>.from(item));
      }
    }
    return typed;
  }

  // =========================
  // Hive (محلي)
  // =========================

  /// تحميل الدوريات من JSON إلى Hive (مرة واحدة)
  static Future<void> loadLeaguesToHive() async {
    final box = await Hive.openBox(HiveBoxes.leagues);
    if (box.isNotEmpty) return;

    final raw =
        await rootBundle.loadString('assets/localization/leagues_extended.json');
    final list = json.decode(raw) as List<dynamic>;

    final leagues = list
        .whereType<Map<String, dynamic>>()
        .map((e) => LeagueModel.fromJson(e).toJson())
        .toList();

    await box.put('all', leagues);
  }

  /// جلب كل الدوريات من Hive
  static List<LeagueModel> getAllFromHive() {
    final box = Hive.box(HiveBoxes.leagues);
    final data = box.get('all', defaultValue: []) as List;
    return data
        .map((e) => LeagueModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// جلب الدوريات حسب القارة
  static List<LeagueModel> getByContinent(String continent) {
    return getAllFromHive()
        .where((league) => league.continent == continent)
        .toList();
  }

  /// جلب الدوريات حسب الدولة
  static List<LeagueModel> getByCountry(String country) {
    return getAllFromHive()
        .where((league) => league.country == country)
        .toList();
  }

  // =========================
  // Helpers
  // =========================
  static List<int> _parseCsvInts(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    return raw
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .where((v) => v != null)
        .cast<int>()
        .toList();
  }
}
