import 'package:flutter/material.dart';
import 'package:today_smart/features/fixtures/controllers/fixtures_controller.dart';
import 'package:today_smart/features/fixtures/models/fixture.dart';
import 'package:today_smart/features/localization/ar_names.dart'; // ✅ بدل localization_ar.dart
import 'package:intl/intl.dart';

class CardsLeague extends StatefulWidget {
  const CardsLeague({super.key});

  @override
  State<CardsLeague> createState() => _CardsLeagueState();
}

class _CardsLeagueState extends State<CardsLeague> {
  late Future<List<FixtureModel>> fixturesFuture;

  @override
  void initState() {
    super.initState();
    fixturesFuture = FixturesController().getFixturesByDate(DateTime.now());
  }

  String _formatTime(DateTime dt) => DateFormat('h:mm a', 'ar').format(dt);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("حسب الدوري")),
      body: FutureBuilder<List<FixtureModel>>(
        future: fixturesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("خطأ: ${snapshot.error}"));
          }
          final fixtures = snapshot.data ?? [];
          if (fixtures.isEmpty) {
            return const Center(child: Text("ما فيه مباريات اليوم"));
          }

          // 🔹 تجميع حسب الدوري
          final grouped = <String, List<FixtureModel>>{};
          for (var match in fixtures) {
            final leagueName = leagueArByIdWithFallback(match.league.id, leagueArByIdWithFallback(match.league.id, match.league.name)); // ✅ تم التعديل
            grouped.putIfAbsent(leagueName, () => []);
            grouped[leagueName]!.add(match);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Card(
                color: Colors.black.withOpacity(0.6),
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Divider(color: Colors.white30),
                      Column(
                        children: entry.value.map((match) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  teamArByIdWithFallback(match.home.id, match.home.name), // ✅ لضمان الاتساق
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  _formatTime(match.date),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  teamArByIdWithFallback(match.away.id, match.away.name), // ✅ لضمان الاتساق
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
