import 'package:today_smart/core/services/api_client.dart';

class Competition {
  final int id;
  final String name;
  final bool isCup;

  Competition({
    required this.id,
    required this.name,
    required this.isCup,
  });
}

/// ✅ جلب منافسة واحدة بالـ ID
Future<Competition?> fetchCompetitionById(ApiClient client, int id) async {
  try {
    final data = await client.get("leagues", params: {"id": id});
    final resp = data['response'] as List?;
    if (resp == null || resp.isEmpty) return null;

    final league = resp.first['league'];
    if (league == null) return null;

    return Competition(
      id: league['id'] ?? id,
      name: league['name'] ?? "Unknown",
      isCup: (league['type']?.toString().toLowerCase() ?? "league") == "cup",
    );
  } catch (e) {
    print("⚠️ Error fetching competition $id: $e");
    return null;
  }
}
