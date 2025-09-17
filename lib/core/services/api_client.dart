import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String apiKey;
  final String timezone;
  final List<int> leagues;

  ApiClient({
    required this.apiKey,
    required this.timezone,
    required this.leagues,
  });

  Map<String, String> get _headers => {
        'x-apisports-key': apiKey,
        // شِل السطر تحت إذا ما تستخدم rapidapi proxy
        'x-rapidapi-host': 'v3.football.api-sports.io',
      };

  // نحول القيم لـ String / List<String> قبل بناء الـ URI
  Map<String, dynamic> _stringifyParams(Map<String, dynamic>? params) {
    if (params == null) return const {};
    final out = <String, dynamic>{};
    params.forEach((k, v) {
      if (v == null) return;
      if (v is Iterable) {
        out[k] = v.map((e) => e.toString()).toList();
      } else {
        out[k] = v.toString();
      }
    });
    return out;
  }

  /// ✅ واجهة متوافقة مع الاستدعاءات القديمة:
  /// apiClient.get("players/topscorers", params: {...})
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? params}) async {
    final qp = _stringifyParams(params);
    final uri = Uri.https("v3.football.api-sports.io", "/$path", qp);

    final r = await http.get(uri, headers: _headers);

    if (r.statusCode != 200) {
      throw Exception("API error ${r.statusCode}: ${r.body}");
    }

    final decoded = json.decode(r.body);
    if (decoded is Map<String, dynamic>) return decoded;

    return {
      "get": path,
      "response": decoded,
      "results": decoded is List ? decoded.length : 0,
    };
  }

  /// تفاصيل الدوري عبر ?id=
  Future<Map<String, dynamic>> getLeagueDetails(int leagueId) async {
    final response = await get(
      "leagues",
      params: {'id': leagueId},
    );
    // نرجع الـ body كامل (اللي فيه response/parameters/…)
    return response;
  }
}
