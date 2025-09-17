// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:today_smart/features/fixtures/data/fixtures_api.dart';
import 'package:today_smart/features/leagues/services/leagues_repository.dart';
import 'package:today_smart/core/services/api_client.dart';
import 'package:today_smart/core/utils/repository_utils.dart';

import '../../standings/models/standing.dart';
import '../models/fixture.dart';
import '../models/lineup.dart';
import '../models/event.dart';
import '../models/stats.dart';
import '../utils/fixtures_filters.dart';

class FixturesRepository {
  final FixturesApi api;
  final List<int> allowedLeagues;
  final LeaguesRepository leaguesRepo;

  FixturesRepository({
    String? apiKey,
    required this.allowedLeagues,
  })  : api = FixturesApi(apiKey: apiKey ?? (dotenv.env['API_KEY'] ?? '')),
        leaguesRepo = LeaguesRepository(
          ApiClient(
            apiKey: apiKey ?? (dotenv.env['API_KEY'] ?? ''),
            timezone: "Asia/Riyadh",
            leagues: allowedLeagues,
          ),
        );

  static bool get _shouldLog => !kReleaseMode;

  /// ✅ جلب المباريات
  Future<List<FixtureModel>> getFixtures({required DateTime date}) async {
    final response = await api.get("fixtures", params: {
      "date": date.toIso8601String().split("T").first,
      "timezone": "Asia/Riyadh",
    });

    final List<dynamic> data =
        (response['response'] as List<dynamic>?) ?? const [];

    final fixtures = data
        .whereType<Map<String, dynamic>>()
        .map((e) => FixtureModel.fromJson(e))
        .toList();

    final filtered = filterByAllowedLeagues(fixtures, allowedLeagues.toSet());

    if (_shouldLog) {
      print("📌 FixturesRepository.getFixtures(${date.toIso8601String()})");
      print(" - Allowed leagues: $allowedLeagues");
      print(" - Fixtures fetched: ${fixtures.length}");
      print(" - Fixtures after filter: ${filtered.length}");
    }

    return filtered;
  }

  /// ✅ جلب الترتيب
  Future<List<StandingModel>> getStandings(int leagueId) async {
    final season = await leaguesRepo.getCurrentSeason(leagueId) ??
        RepositoryUtils.bestSeasonForApi();

    final response = await api.get(
      "standings",
      params: {
        "league": leagueId.toString(),
        "season": season.toString(),
      },
    );

    final List<dynamic> data =
        (response['response'] as List<dynamic>?) ?? const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => StandingModel.fromJson(e))
        .toList();
  }

  /// ✅ جلب التشكيلة
  Future<List<Lineup>> getLineups(int fixtureId) async {
    final response = await api.get("fixtures/lineups", params: {
      "fixture": fixtureId.toString(),
    });
    final List<dynamic> data =
        (response['response'] as List<dynamic>?) ?? const [];

    if (data.isEmpty) {
      print("ℹ️ Fixture=$fixtureId -> المباراة لم تبدأ أو لا يوجد تشكيل متاح");
    } else {
      print("✅ Fixture=$fixtureId -> تم جلب ${data.length} تشكيلات");
    }

    return data.map((e) => Lineup.fromJson(e)).toList();
  }

  /// ✅ جلب الأحداث
  Future<List<FixtureEvent>> getEvents(int fixtureId) async {
    final response = await api.get("fixtures/events", params: {
      "fixture": fixtureId.toString(),
    });
    final List<dynamic> data =
        (response['response'] as List<dynamic>?) ?? const [];

    if (data.isEmpty) {
      print(
          "ℹ️ Fixture=$fixtureId -> لا يوجد أحداث (إما المباراة لم تبدأ أو API ما يدعمها)");
    } else {
      print("✅ Fixture=$fixtureId -> تم جلب ${data.length} أحداث");
    }

    return data.map((e) => FixtureEvent.fromJson(e)).toList();
  }

  /// ✅ جلب الإحصائيات
  Future<List<FixtureStatistics>> getStatistics(int fixtureId) async {
    final response = await api.get("fixtures/statistics", params: {
      "fixture": fixtureId.toString(),
    });
    final List<dynamic> data =
        (response['response'] as List<dynamic>?) ?? const [];

    if (data.isEmpty) {
      print(
          "ℹ️ Fixture=$fixtureId -> لا توجد إحصائيات (قد تكون المباراة لم تبدأ بعد)");
    } else {
      print("✅ Fixture=$fixtureId -> تم جلب ${data.length} إحصائيات");
    }

    return data.map((e) => FixtureStatistics.fromJson(e)).toList();
  }
}
