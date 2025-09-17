import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// الدوريات المطلوبة:
/// 152 = SPL (الدوري السعودي)
/// 39  = EPL (الدوري الإنجليزي)
/// 140 = LaLiga (الدوري الإسباني)
const leagues = <int>[152, 39, 140];
const season = 2024;

Future<void> main() async {
  final apiKey = await _readApiKey();
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln("❌ لم يتم العثور على API_KEY أو API_FOOTBALL_KEY في .env");
    exit(1);
  }

  final players = <int, String>{};

  for (final leagueId in leagues) {
    stdout.writeln("🏟️ جاري جلب الفرق للدوري $leagueId ...");
    final teamIds = await _fetchTeams(leagueId, apiKey);
    for (final teamId in teamIds) {
      await _fetchPlayers(teamId, apiKey, players);
    }
  }

  // ✅ طباعة أول 10 لاعبين للتأكيد
  stdout.writeln("\n🔍 أول 10 لاعبين جلبهم الـ API:");
  players.entries.take(10).forEach((entry) {
    stdout.writeln("ID: ${entry.key} | Name: ${entry.value}");
  });

  // ✅ كتابة ملف القالب (العربي الفاضي)
  final file = File('assets/localization/players_ar.json');
  file.createSync(recursive: true);
  file.writeAsStringSync(
    const JsonEncoder.withIndent("  ").convert(
      Map.fromEntries(players.keys.map((id) => MapEntry(id.toString(), ""))),
    ),
  );

  // ✅ كتابة ملف ids -> names بالإنجليزي
  final idsFile = File('assets/localization/players_ids.json');
  idsFile.createSync(recursive: true);
  idsFile.writeAsStringSync(
    const JsonEncoder.withIndent("  ").convert(
      players.map((k, v) => MapEntry(k.toString(), v)),
    ),
  );

  stdout.writeln(
      "\n✅ تم إنشاء players_ar.json و players_ids.json بعدد ${players.length} لاعب");
}

/// يقرأ API key من ملف .env (يدعم API_KEY و API_FOOTBALL_KEY)
Future<String?> _readApiKey() async {
  final envFile = File('.env');
  if (!envFile.existsSync()) return null;

  final lines = await envFile.readAsLines();
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith("API_FOOTBALL_KEY=")) {
      return trimmed.split("=").last.trim();
    }
    if (trimmed.startsWith("API_KEY=")) {
      return trimmed.split("=").last.trim();
    }
  }
  return null;
}

Future<List<int>> _fetchTeams(int leagueId, String apiKey) async {
  final url = Uri.parse(
      "https://v3.football.api-sports.io/teams?league=$leagueId&season=$season");
  final res = await http.get(url, headers: {"x-apisports-key": apiKey});
  if (res.statusCode != 200) {
    throw Exception("خطأ في جلب الفرق: ${res.statusCode} ${res.body}");
  }
  final data = json.decode(res.body) as Map<String, dynamic>;
  return (data["response"] as List)
      .map((e) => e["team"]["id"] as int)
      .toList();
}

Future<void> _fetchPlayers(
    int teamId, String apiKey, Map<int, String> out) async {
  int page = 1;
  while (true) {
    final url = Uri.parse(
        "https://v3.football.api-sports.io/players?team=$teamId&season=$season&page=$page");
    final res = await http.get(url, headers: {"x-apisports-key": apiKey});
    if (res.statusCode != 200) {
      throw Exception("خطأ في جلب لاعبي الفريق $teamId: ${res.statusCode} ${res.body}");
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    final response = (data["response"] as List).cast<Map<String, dynamic>>();

    for (final row in response) {
      final p = row["player"] as Map<String, dynamic>;
      final id = p["id"] as int;
      final name = (p["name"] as String?)?.trim();
      if (name != null && name.isNotEmpty) {
        out[id] = name;
      }
    }

    final paging = data["paging"] as Map<String, dynamic>? ?? {};
    final total = (paging["total"] as num?)?.toInt() ?? 1;
    if (page >= total) break;
    page++;
  }
}
