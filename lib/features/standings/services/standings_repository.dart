import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:today_smart/core/services/api_client.dart';
import 'package:today_smart/core/utils/repository_utils.dart';
import '../models/standing.dart';

class StandingGroup {
  final String name;
  final List<StandingModel> table;

  StandingGroup({required this.name, required this.table});

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "table": table.map((s) => s.toJson()).toList(),
    };
  }

  factory StandingGroup.fromJson(Map<String, dynamic> json) {
    return StandingGroup(
      name: json["name"] ?? "",
      table: (json["table"] as List<dynamic>? ?? [])
          .map((e) => StandingModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class LeagueStanding {
  final int leagueId;
  final String leagueName;
  final int season;
  final List<StandingGroup> groups;
  final bool fromCache;

  LeagueStanding({
    required this.leagueId,
    required this.leagueName,
    required this.season,
    required this.groups,
    this.fromCache = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "leagueId": leagueId,
      "leagueName": leagueName,
      "season": season,
      "groups": groups.map((g) => g.toJson()).toList(),
    };
  }

  factory LeagueStanding.fromJson(Map<String, dynamic> json, {bool fromCache = false}) {
    // صيغة جديدة
    if (json["groups"] is List) {
      return LeagueStanding(
        leagueId: json["leagueId"] ?? 0,
        leagueName: json["leagueName"] ?? "",
        season: json["season"] ?? 0,
        groups: (json["groups"] as List<dynamic>)
            .map((e) => StandingGroup.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        fromCache: fromCache,
      );
    }

    // fallback للصيغة القديمة (table فقط)
    if (json["table"] is List) {
      final table = (json["table"] as List)
          .map((e) => StandingModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return LeagueStanding(
        leagueId: json["leagueId"] ?? 0,
        leagueName: json["leagueName"] ?? "",
        season: json["season"] ?? 0,
        groups: [StandingGroup(name: "", table: table)],
        fromCache: fromCache,
      );
    }

    return LeagueStanding(
      leagueId: json["leagueId"] ?? 0,
      leagueName: json["leagueName"] ?? "",
      season: json["season"] ?? 0,
      groups: const [],
      fromCache: fromCache,
    );
  }
}

class StandingsRepository {
  final ApiClient apiClient;
  final List<int> allowedLeagues;

  static const _boxName = "standings_cache_v2"; // ✅ غيرنا الاسم عشان ما يتعارض مع الكاش القديم
  static const _ttl = Duration(minutes: 10);

  StandingsRepository({
    required this.apiClient,
    required this.allowedLeagues,
  });

  Future<LeagueStanding?> getStandings(int leagueId, {bool forceApi = false}) async {
    final box = await Hive.openBox(_boxName);

    // 1️⃣ من الكاش
    if (!forceApi) {
      final cached = box.get(leagueId.toString());
      if (cached != null) {
        final ts = cached["timestamp"] as int;
        final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
        if (age < _ttl) {
          return LeagueStanding.fromJson(
            Map<String, dynamic>.from(cached["data"]),
            fromCache: true,
          );
        }
      }
    }

    // 2️⃣ من API
    final season = RepositoryUtils.bestSeasonForApi();
    final data = await apiClient.get("standings", params: {
      "league": leagueId.toString(),
      "season": season.toString(),
    });

    final resp = data['response'];
    if (resp is! List || resp.isEmpty) return null;

    final first = resp.first;
    if (first is! Map) return null;

    final league = first['league'];
    if (league is! Map) return null;

    final standings = league['standings'];
    if (standings is! List || standings.isEmpty) return null;

    final List<StandingGroup> groups = [];

    // ✅ الحالة 1: عدة قوائم (كل وحدة مجموعة)
    if (standings.length > 1) {
      for (var i = 0; i < standings.length; i++) {
        final groupList = standings[i];
        if (groupList is! List) continue;

        final tableParsed = groupList
            .map<StandingModel>((row) => StandingModel.fromJson(Map<String, dynamic>.from(row)))
            .toList();

        String groupName = "";
        if (groupList.isNotEmpty && groupList.first is Map) {
          final firstRow = Map<String, dynamic>.from(groupList.first);
          final rawGroup = (firstRow['group'] ?? "") as String;
          groupName = _extractGroupName(rawGroup, i);
        }

        groups.add(StandingGroup(name: groupName, table: tableParsed));
      }
    } else {
      // ✅ الحالة 2: قائمة وحدة لكن فيها كل الفرق بمجموعات مختلفة
      final single = standings.first;
      if (single is! List) return null;

      final rows = single
          .map<StandingModel>((row) => StandingModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();

      final Map<String, List<StandingModel>> byGroup = {};
      for (final r in rows) {
        final key = (r.group ?? "").trim();
        final groupName = _extractGroupName(key, 0);
        byGroup.putIfAbsent(groupName, () => []).add(r);
      }

      int idx = 0;
      byGroup.forEach((name, list) {
        final gName = (name.isEmpty) ? "Group ${String.fromCharCode(65 + idx)}" : name;
        groups.add(StandingGroup(name: gName, table: list));
        idx++;
      });
    }

    // ✅ Debug print
    debugPrint("📊 Standings for league $leagueId → ${groups.length} groups found");
    for (var g in groups) {
      debugPrint("   - ${g.name} (${g.table.length} teams)");
    }

    final standing = LeagueStanding(
      leagueId: league['id'] ?? leagueId,
      leagueName: league['name'] ?? "League $leagueId",
      season: league['season'] ?? season,
      groups: groups,
      fromCache: false,
    );

    await box.put(leagueId.toString(), {
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "data": standing.toJson(),
    });

    return standing;
  }

  static String _extractGroupName(String raw, int index) {
    if (raw.isNotEmpty) {
      final re = RegExp(r'(Group\s+[A-Z0-9]+)', caseSensitive: false);
      final m = re.firstMatch(raw);
      if (m != null) return m.group(1)!.trim();
      return raw.trim();
    }
    final letter = String.fromCharCode(65 + index); // 65 = A
    return "Group $letter";
  }
}
