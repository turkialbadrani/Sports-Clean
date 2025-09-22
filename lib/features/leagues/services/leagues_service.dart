import 'package:today_smart/core/services/api_client.dart';

class LeaguesService {
  final ApiClient apiClient;

  LeaguesService(this.apiClient);

  Future<List<Map<String, dynamic>>> fetchCountries() async {
    final data = await apiClient.get("countries");
    return List<Map<String, dynamic>>.from(data["response"] ?? []);
  }

  Future<List<Map<String, dynamic>>> fetchLeagues(String country) async {
    final data = await apiClient.get("leagues", params: {"country": country});
    return List<Map<String, dynamic>>.from(data["response"] ?? []);
  }

  Future<List<Map<String, dynamic>>> fetchTeams(int leagueId, int season) async {
    final data = await apiClient.get("teams", params: {
      "league": leagueId.toString(),
      "season": season.toString(),
    });
    return List<Map<String, dynamic>>.from(data["response"] ?? []);
  }
}
