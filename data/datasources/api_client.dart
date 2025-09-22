import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const _base = 'https://v3.football.api-sports.io';

  final String apiKey;
  final String timezone;
  final List<int> leagues;

  ApiClient({required this.apiKey, required this.timezone, required this.leagues});

  Map<String, String> get _headers => {
        'x-rapidapi-key': apiKey,
        'x-rapidapi-host': 'v3.football.api-sports.io',
      };

  Future<List<Map<String, dynamic>>> fixturesByDate(String ymd) async {
    // We request by date and timezone only (no league) to reduce complexity, then filter by leagues.
    final uri = Uri.parse('$_base/fixtures?date=$ymd&timezone=$timezone');
    final r = await http.get(uri, headers: _headers);
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    final list = (data['response'] as List).cast<Map<String, dynamic>>();
    if (leagues.isEmpty) return list;
    return list.where((m) {
      final leagueId = (m['league']?['id']) as int?;
      return leagueId != null && leagues.contains(leagueId);
    }).toList();
  }
}
