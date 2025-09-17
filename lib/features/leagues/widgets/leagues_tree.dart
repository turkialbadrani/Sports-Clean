import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/leagues_provider.dart';
import '../models/league_tree.dart';
import '../league_details_page.dart';

class LeaguesTree extends StatelessWidget {
  final List<LeagueTree> data;

  const LeaguesTree({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      children: data.map((continent) {
        return ExpansionTile(
          title: Text(
            "${_continentEmoji(continent.name)} ${continent.name}",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          children: continent.countries.map((country) {
            return ExpansionTile(
              title: Row(
                children: [
                  if (country.flag.isNotEmpty)
                    Image.network(
                      country.flag,
                      width: 22,
                      height: 22,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.flag, size: 20),
                    )
                  else
                    const Icon(Icons.flag, size: 20),
                  const SizedBox(width: 8),
                  Text(country.name),
                ],
              ),
              onExpansionChanged: (expanded) {
                if (expanded) {
                  context.read<LeaguesProvider>().loadLeagues(country.name);
                }
              },
              children: country.leagues.isNotEmpty
                  ? country.leagues.map((league) {
                      return ListTile(
                        leading: league.logo.isNotEmpty
                            ? Image.network(
                                league.logo,
                                width: 24,
                                height: 24,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.sports_soccer),
                              )
                            : const Icon(Icons.sports_soccer),
                        title: Text(
                          league.name.isNotEmpty
                              ? league.name
                              : "بطولة غير معروفة",
                        ),
                        subtitle: league.season != 0
                            ? Text("Season: ${league.season}")
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LeagueDetailsPage(leagueId: league.id),
                            ),
                          );
                        },
                      );
                    }).toList()
                  : [
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text("⚽ لا توجد بطولات"),
                      )
                    ],
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  String _continentEmoji(String continent) {
    switch (continent.toLowerCase()) {
      case "europe":
        return "🌍";
      case "africa":
        return "🌍";
      case "asia":
        return "🌏";
      case "south america":
        return "🌎";
      case "north america":
        return "🌎";
      case "australia":
      case "oceania":
        return "🌏";
      default:
        return "🌐";
    }
  }
}
