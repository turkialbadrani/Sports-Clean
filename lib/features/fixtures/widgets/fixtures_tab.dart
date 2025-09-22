import 'package:flutter/material.dart';
import "package:today_smart/features/fixtures/controllers/fixtures_controller.dart";
import 'fixtures_list.dart';
import '../models/fixture.dart';

class FixturesTab extends StatelessWidget {
  final DateTime date;
  const FixturesTab({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FixtureModel>>(
      future: FixturesController().getFixturesByDate(date),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("خطأ: ${snapshot.error}"));
        }

        final fixtures = snapshot.data ?? [];

        if (fixtures.isEmpty) {
          return const Center(child: Text("لا توجد مباريات في هذا اليوم"));
        }

        return FixturesList(fixtures: fixtures);
      },
    );
  }
}
