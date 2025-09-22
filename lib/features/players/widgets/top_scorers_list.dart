import 'package:flutter/material.dart';
import 'package:today_smart/features/localization/ar_names.dart';

class TopScorersList extends StatelessWidget {
  final List<Map<String, dynamic>> scorers;

  const TopScorersList({super.key, required this.scorers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🥅 قائمة الهدافين")),
      body: ListView.separated(
        itemCount: scorers.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final player = scorers[index];

          final playerName = player["player"]["name"] ?? "لاعب";
          final teamId = player["team"]["id"];
          final teamName = player["team"]["name"]; // من الـ API

          final teamNameAr = teamArByIdWithFallback(teamId, teamName);

          return ListTile(
            leading: CircleAvatar(child: Text("${index + 1}")),
            title: Text(playerName),
            subtitle: Text(teamNameAr),
            trailing: Text("أهداف: ${player["goals"]}"),
          );
        },
      ),
    );
  }
}
