import 'package:flutter/material.dart';
import '../models/fixture.dart';

class FixturesByLeaguePage extends StatelessWidget {
  FixturesByLeaguePage({super.key});

  final List<Fixture> fixtures = [
    Fixture(league: "الدوري السعودي", homeTeam: "النصر", awayTeam: "الهلال", date: DateTime(2025, 8, 27, 21, 0)),
    Fixture(league: "الدوري السعودي", homeTeam: "الاتحاد", awayTeam: "الأهلي", date: DateTime(2025, 8, 28, 20, 30)),
    Fixture(league: "الدوري الإنجليزي", homeTeam: "مان سيتي", awayTeam: "أرسنال", date: DateTime(2025, 8, 27, 19, 45)),
    Fixture(league: "الدوري الإنجليزي", homeTeam: "تشيلسي", awayTeam: "ليفربول", date: DateTime(2025, 8, 29, 18, 0)),
  ];

  Map<String, List<Fixture>> groupByLeague(List<Fixture> fixtures) {
    final map = <String, List<Fixture>>{};
    for (var f in fixtures) {
      map.putIfAbsent(f.league, () => []);
      map[f.league]!.add(f);
    }
    return map;
  }

  Map<DateTime, List<Fixture>> groupByDate(List<Fixture> fixtures) {
    final map = <DateTime, List<Fixture>>{};
    for (var f in fixtures) {
      final date = DateTime(f.date.year, f.date.month, f.date.day);
      map.putIfAbsent(date, () => []);
      map[date]!.add(f);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final groupedByLeague = groupByLeague(fixtures);

    return Scaffold(
      appBar: AppBar(title: const Text("حسب البطولات")),
      body: ListView(
        children: groupedByLeague.entries.map((leagueEntry) {
          final leagueName = leagueEntry.key;
          final fixtures = leagueEntry.value;
          final groupedByDate = groupByDate(fixtures);

          return ExpansionTile(
            title: Text(leagueName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            children: groupedByDate.entries.map((dateEntry) {
              final date = dateEntry.key;
              final matches = dateEntry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "${date.year}-${date.month}-${date.day}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ...matches.map((m) => ListTile(
                        title: Text("${m.homeTeam} vs ${m.awayTeam}"),
                        subtitle: Text("${m.date.hour}:${m.date.minute.toString().padLeft(2, '0')}"),
                      )),
                ],
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
