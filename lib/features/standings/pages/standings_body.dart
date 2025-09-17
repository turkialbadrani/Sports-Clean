import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../providers/standings_provider.dart';
import '../widgets/league_dropdown.dart';
import '../widgets/group_dropdown.dart';
import '../widgets/standings_table.dart';
import '../widgets/empty_state.dart';

import 'package:today_smart/features/settings/settings_provider.dart';

class StandingsBody extends StatefulWidget {
  const StandingsBody({super.key});

  @override
  State<StandingsBody> createState() => _StandingsBodyState();
}

class _StandingsBodyState extends State<StandingsBody> {
  late int _selectedLeague;
  late Future<List<int>> _futureLeagues;

  @override
  void initState() {
    super.initState();
    _selectedLeague = -1;
    _futureLeagues = Future.value(const <int>[]);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = context.read<SettingsProvider>();
      final leagues = settings.preferredLeagues;
      final saved = Hive.box('user_prefs').get('last_standings_league') as int?;
      final chosen = (saved != null && leagues.contains(saved))
          ? saved
          : (leagues.isNotEmpty ? leagues.first : -1);

      setState(() {
        _futureLeagues = Future.value(leagues);
        _selectedLeague = chosen;
      });

      if (chosen != -1) {
        final provider = context.read<StandingsProvider>();
        provider.load(chosen);
        provider.refresh(chosen);
      }
    });
  }

  Future<void> _refresh(BuildContext context) async {
    if (_selectedLeague == -1) return;
    await context.read<StandingsProvider>().refresh(_selectedLeague);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<List<int>>(
      future: _futureLeagues,
      builder: (context, snap) {
        if (!snap.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),
          );
        }

        final activeLeagues = snap.data!;
        if (_selectedLeague == -1 && activeLeagues.isNotEmpty) {
          _selectedLeague = activeLeagues.first;
        }

        return Consumer<StandingsProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                LeagueDropdown(
                  selectedLeague: _selectedLeague,
                  activeLeagues: activeLeagues,
                  onChanged: (val) {
                    setState(() => _selectedLeague = val);
                    Hive.box('user_prefs').put('last_standings_league', val);
                    final p = context.read<StandingsProvider>();
                    p.load(val);
                    p.refresh(val);
                  },
                ),

                if (provider.hasGroups && provider.groupNames.length > 1)
                  GroupDropdown(
                    groupNames: provider.groupNames,
                    selectedIndex: provider.selectedGroupIndex,
                    onChanged: (val) {
                      context.read<StandingsProvider>().selectGroupByIndex(val);
                    },
                  ),

                Expanded(
                  child: Builder(
                    builder: (context) {
                      switch (provider.state) {
                        case LoadState.loading:
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(cs.primary),
                            ),
                          );
                        case LoadState.error:
                          return Center(child: Text("خطأ: ${provider.error}"));
                        case LoadState.success:
                          final rows = provider.currentTable;
                          if (rows.isEmpty) {
                            return const EmptyState();
                          }
                          return RefreshIndicator(
                            color: cs.primary,
                            onRefresh: () => _refresh(context),
                            child: StandingsTable(
                              rows: rows,
                              groupName: provider.hasGroups
                                  ? provider.groupNames[provider.selectedGroupIndex]
                                  : null,
                              showGroupHeader: provider.hasGroups,
                            ),
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
