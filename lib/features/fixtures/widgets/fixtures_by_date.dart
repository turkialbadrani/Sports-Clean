import 'package:flutter/material.dart';

class FixturesByDate extends StatelessWidget {
  const FixturesByDate({super.key});

  final List<Map<String, dynamic>> fixtures = const [
    {
      "league": "الدوري السعودي",
      "home": "النصر",
      "away": "الهلال",
      "date": "2025-08-27 21:00"
    },
    {
      "league": "الدوري السعودي",
      "home": "الاتحاد",
      "away": "الأهلي",
      "date": "2025-08-28 20:30"
    },
    {
      "league": "الدوري الإنجليزي",
      "home": "مان سيتي",
      "away": "أرسنال",
      "date": "2025-08-27 19:45"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📅 المباريات")),
      body: ListView.builder(
        itemCount: fixtures.length,
        itemBuilder: (context, index) {
          final f = fixtures[index];
          return ListTile(
            title: Text("${f["home"]} vs ${f["away"]}"),
            subtitle: Text("${f["league"]} - ${f["date"]}"),
          );
        },
      ),
    );
  }
}
