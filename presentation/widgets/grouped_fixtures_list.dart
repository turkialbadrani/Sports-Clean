import 'package:flutter/material.dart';
import '../models/fixture.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../localization/ar_names.dart';

class GroupedFixturesList extends StatelessWidget {
  final List<FixtureModel> fixtures;
  final Set<int> favorites;
  final void Function(int fixtureId) onToggleFavorite;
  final bool showOnlyFavorites;
  final bool showOnlyHighlights;
  final Set<int> highlightLeagues;

  const GroupedFixturesList({
    super.key,
    required this.fixtures,
    required this.favorites,
    required this.onToggleFavorite,
    required this.showOnlyFavorites,
    required this.showOnlyHighlights,
    required this.highlightLeagues,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = fixtures.where((f) {
      if (showOnlyFavorites && !favorites.contains(f.id)) return false;
      if (showOnlyHighlights && !highlightLeagues.contains(f.league.id)) return false;
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('ما فيه مباريات ضمن الفلترة المحددة.',
              style: Theme.of(context).textTheme.titleMedium),
        ),
      );
    }

    // Group by league id
    final Map<int, List<FixtureModel>> byLeague = {};
    for (final f in filtered) {
      byLeague.putIfAbsent(f.league.id, () => <FixtureModel>[]).add(f);
    }

    final entries = byLeague.entries.toList()
      ..sort((a, b) => leagueAr(a.value.first.league.name).compareTo(leagueAr(b.value.first.league.name)));

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final e = entries[index];
        final league = e.value.first.league;
        return Column(
          children: <Widget>[
            _LeagueHeader(name: leagueAr(league.name), logoUrl: league.logoUrl),
            ...e.value.map((f) => _FixtureRow(
                  f: f,
                  isFavorite: favorites.contains(f.id),
                  onFav: () => onToggleFavorite(f.id),
                )),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _LeagueHeader extends StatelessWidget {
  final String name;
  final String? logoUrl;
  const _LeagueHeader({required this.name, required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
      child: Row(
        children: <Widget>[
          if (logoUrl != null)
            (logoUrl!.toLowerCase().endsWith('.svg'))
                ? SvgPicture.network(logoUrl!, width: 18, height: 18)
                : Image.network(logoUrl!, width: 18, height: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: Theme.of(context).textTheme.titleMedium)),
        ],
      ),
    );
  }
}

class _FixtureRow extends StatelessWidget {
  final FixtureModel f;
  final bool isFavorite;
  final VoidCallback onFav;
  const _FixtureRow({required this.f, required this.isFavorite, required this.onFav});

  @override
  Widget build(BuildContext context) {
    final isFinished = f.status.short == 'FT';
    final isUpcoming = f.status.short == 'NS';
    final statusText = f.isLive ? 'حاليًا' : (isFinished ? 'انتهت' : (isUpcoming ? 'قادمة' : f.status.toArabic()));
    final timeOrScore = (isUpcoming && (f.goals.home == null || f.goals.away == null))
        ? f.kickoffTime()
        : '${f.goals.home ?? f.scoreFull.home ?? '-'} - ${f.goals.away ?? f.scoreFull.away ?? '-'}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Text(statusText, style: Theme.of(context).textTheme.labelMedium),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(teamAr(f.home.name), overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(timeOrScore, style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(teamAr(f.away.name), overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(isFavorite ? Icons.star : Icons.star_border),
          onPressed: onFav,
          tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
        ),
      ),
    );
  }
}
