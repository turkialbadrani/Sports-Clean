import 'package:flutter/material.dart';
import 'package:today_smart/features/localization/ar_names.dart';
import '../../fixtures/models/fixture.dart';
import "package:today_smart/features/fixtures/widgets/fixtures_list_sort_buttons.dart";
import "package:today_smart/features/fixtures/widgets/fixtures_list_card.dart";

enum SortType { byLeague, byTime }

class FixturesList extends StatefulWidget {
  final List<FixtureModel> fixtures;
  const FixturesList({super.key, required this.fixtures});

  @override
  State<FixturesList> createState() => _FixturesListState();
}

class _FixturesListState extends State<FixturesList> {
  SortType _sortType = SortType.byLeague; // ✅ افتراضياً حسب البطولات

  @override
  Widget build(BuildContext context) {
    if (widget.fixtures.isEmpty) {
      return const Center(child: Text("لا توجد مباريات"));
    }

    return Column(
      children: [
        FixturesListSortButtons(
          sortType: _sortType,
          onChanged: (val) {
            setState(() {
              _sortType = val;
            });
          },
        ),
        Expanded(
          child: _sortType == SortType.byLeague
              ? _buildByLeague(widget.fixtures)
              : _buildByTime(widget.fixtures),
        ),
      ],
    );
  }

  /// 🔹 بناء القائمة مجمعة حسب البطولة مع ترتيب مخصص IDs
  Widget _buildByLeague(List<FixtureModel> fixtures) {
    final Map<String, List<FixtureModel>> grouped = {};

    for (final f in fixtures) {
      final leagueName =
          leagueArByIdWithFallback(f.league.id, f.league.name);
      grouped.putIfAbsent(leagueName, () => []).add(f);
    }

    // ✅ ترتيب IDs مخصص
    final priorityOrder = [
      307, // دوري روشن السعودي
      39,  // الدوري الإنجليزي الممتاز
      140, // الدوري الإسباني
      135, // الدوري الإيطالي
      78,  // الدوري الألماني
      61,  // الدوري الفرنسي
    ];

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final aId = fixtures.firstWhere((f) =>
            leagueArByIdWithFallback(f.league.id, f.league.name) == a).league.id;
        final bId = fixtures.firstWhere((f) =>
            leagueArByIdWithFallback(f.league.id, f.league.name) == b).league.id;

        final ai = priorityOrder.indexOf(aId);
        final bi = priorityOrder.indexOf(bId);

        if (ai != -1 && bi != -1) {
          return ai.compareTo(bi);
        } else if (ai != -1) {
          return -1;
        } else if (bi != -1) {
          return 1;
        } else {
          return a.compareTo(b);
        }
      });

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final leagueName = sortedKeys[index];
        final leagueFixtures = grouped[leagueName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                leagueName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...leagueFixtures.map((f) => FixturesListCard(fixture: f)),
          ],
        );
      },
    );
  }

  /// 🔹 بناء القائمة مرتبة حسب الوقت
  Widget _buildByTime(List<FixtureModel> fixtures) {
    final sorted = List<FixtureModel>.from(fixtures)
      ..sort((a, b) => a.date.compareTo(b.date));

    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final f = sorted[index];
        return FixturesListCard(fixture: f);
      },
    );
  }
}
