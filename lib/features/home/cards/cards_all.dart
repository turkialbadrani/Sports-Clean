import 'package:flutter/material.dart';
import 'package:today_smart/features/fixtures/controllers/fixtures_controller.dart';
import 'package:today_smart/features/fixtures/models/fixture.dart';
import 'package:today_smart/features/localization/localization_ar.dart';
import 'package:intl/intl.dart';

class CardsAll extends StatefulWidget {
  const CardsAll({super.key});

  @override
  State<CardsAll> createState() => _CardsAllState();
}

class _CardsAllState extends State<CardsAll> {
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
      appBar: AppBar(title: const Text("كل المباريات")),
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

          fixtures.sort((a, b) => a.date.compareTo(b.date));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fixtures.length,
            itemBuilder: (context, index) {
              final match = fixtures[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.black.withOpacity(0.6),
                child: ListTile(
                  title: Text(
                    "${LocalizationAr.teamName(match.home.id, match.home.name)} vs "
                    "${LocalizationAr.teamName(match.away.id, match.away.name)}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    _formatTime(match.date),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
