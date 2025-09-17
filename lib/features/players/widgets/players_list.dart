import 'package:flutter/material.dart';

class PlayersList extends StatelessWidget {
  const PlayersList({super.key});

  final List<Map<String, dynamic>> players = const [
    {"name": "كريستيانو رونالدو", "team": "النصر", "position": "مهاجم"},
    {"name": "سالم الدوسري", "team": "الهلال", "position": "جناح"},
    {"name": "حمدان الشمراني", "team": "الاتحاد", "position": "مدافع"},
    {"name": "رياض محرز", "team": "الأهلي", "position": "وسط"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("👥 قائمة اللاعبين")),
      body: ListView.separated(
        itemCount: players.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final player = players[index];
          return ListTile(
            leading: CircleAvatar(child: Text(player["name"][0])),
            title: Text(player["name"]),
            subtitle: Text("${player["team"]} - ${player["position"]}"),
          );
        },
      ),
    );
  }
}
