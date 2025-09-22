import 'package:flutter/material.dart';
import 'package:today_smart/features/localization/ar_names.dart';
import '../../leagues/models/league.dart'; // ✅ LeagueModel
import 'package:today_smart/features/localization/localization_ar.dart';
import 'package:today_smart/features/leagues/league_details_page.dart';

class TodaySmartStandingList extends StatelessWidget {
  final List<LeagueModel> leagues;

  const TodaySmartStandingList({super.key, required this.leagues});

  @override
  Widget build(BuildContext context) {
    if (leagues.isEmpty) {
      return const Center(child: Text("لا توجد بطولات"));
    }

    return ListView.builder(
      itemCount: leagues.length,
      itemBuilder: (context, index) {
        final league = leagues[index];

        final leagueName = LocalizationAr.leagueName(
          league.id,
          leagueArByIdWithFallback(league.id, league.name),
        );

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LeagueDetailsPage(
                  leagueId: league.id,
                  leagueName: leagueName, // ✅ تمرير الاسم
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: league.logoUrl != null &&
                        league.logoUrl!.isNotEmpty
                    ? NetworkImage(league.logoUrl!)
                    : null,
                child: (league.logoUrl == null || league.logoUrl!.isEmpty)
                    ? const Icon(Icons.shield)
                    : null,
              ),
              title: Text(leagueName),
              subtitle: Text("الدولة: ${league.country ?? 'غير معروف'}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        );
      },
    );
  }
}
