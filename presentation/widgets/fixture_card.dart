import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/fixture.dart';
import '../localization/ar_names.dart';

class FixtureCard extends StatelessWidget {
  final FixtureModel f;
  const FixtureCard({super.key, required this.f});

  Widget _teamRow(BuildContext context, FixtureTeam team, {bool isHome = true}) {
    final name = teamAr(team.name);
    final logo = team.logoUrl;
    Widget logoWidget;
    if (logo != null && logo.toLowerCase().endsWith('.svg')) {
      logoWidget = SvgPicture.network(logo, width: 28, height: 28, fit: BoxFit.contain);
    } else {
      logoWidget = Image.network(logo ?? '', width: 28, height: 28, fit: BoxFit.contain, errorBuilder: (c, e, s) {
        return const SizedBox(width: 28, height: 28);
      });
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (!isHome) const SizedBox(width: 6),
        logoWidget,
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        if (isHome) const SizedBox(width: 6),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFinished = f.status.short == 'FT';
    final isUpcoming = f.status.short == 'NS';
    final statusText = f.isLive ? '• مباشر' : (isFinished ? 'انتهت' : (isUpcoming ? 'قادمة' : f.status.toArabic()));

    final scoreText = (isUpcoming && (f.goals.home == null || f.goals.away == null))
        ? f.kickoffTime()
        : '${f.goals.home ?? f.scoreFull.home ?? '-'} - ${f.goals.away ?? f.scoreFull.away ?? '-'}';

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (f.league.logoUrl != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 4),
                    child: (f.league.logoUrl!.toLowerCase().endsWith('.svg'))
                        ? SvgPicture.network(f.league.logoUrl!, width: 18, height: 18)
                        : Image.network(f.league.logoUrl!, width: 18, height: 18),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    leagueAr(f.league.name),
                    style: Theme.of(context).textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(statusText, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(child: _teamRow(context, f.home)),
                Text(scoreText, style: Theme.of(context).textTheme.titleMedium),
                Expanded(child: Align(alignment: Alignment.centerRight, child: _teamRow(context, f.away, isHome: false))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
