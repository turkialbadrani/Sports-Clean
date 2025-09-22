
// lib/features/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'settings_provider.dart';
import 'widgets/favorite_selector.dart';
import 'package:today_smart/core/json_to_hive/hive_boxes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Map<int, String> _mapFromBox(Box box) {
    final data = box.get('all', defaultValue: []);
    if (data is List) {
      return {
        for (var e in data)
          if (e is Map && e['id'] != null && e['name'] != null)
            e['id'] as int: e['name'] as String,
      };
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    final leaguesBox = Hive.box(HiveBoxes.leagues);
    final clubsBox = Hive.box(HiveBoxes.clubs);
    final playersBox = Hive.box(HiveBoxes.players);

    final leaguesMap = _mapFromBox(leaguesBox);
    final teamsMap = _mapFromBox(clubsBox);
    final playersMap = _mapFromBox(playersBox);

    return Scaffold(
      appBar: AppBar(
        title: const Text("الإعدادات"),
      ),
      body: ListView(
        children: [
          // 🌙 الوضع الداكن
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text("الوضع الداكن"),
            value: provider.isDarkMode,
            onChanged: (val) {
              provider.toggleDarkMode(val);
            },
          ),

          // ⚽ الدوريات المفضلة
          ListTile(
            leading: const Icon(Icons.sports_soccer),
            title: const Text("الدوريات المفضلة"),
            subtitle: Text("${provider.preferredLeagues.length} دوري"),
            onTap: () async {
              await FavoriteSelector.show(
                context,
                title: "الدوريات المفضلة",
                items: leaguesMap, // ✅ من Hive
                selectedItems: provider.preferredLeagues.toSet(),
                onConfirm: (selected) {
                  provider.updatePreferredLeagues(selected.toList());
                },
              );
            },
          ),

          // 🏟 الأندية المفضلة
          ListTile(
            leading: const Icon(Icons.shield),
            title: const Text("الأندية المفضلة"),
            subtitle: Text("${provider.preferredTeams.length} نادٍ"),
            onTap: () async {
              await FavoriteSelector.show(
                context,
                title: "الأندية المفضلة",
                items: teamsMap, // ✅ من Hive
                selectedItems: provider.preferredTeams.toSet(),
                onConfirm: (selected) {
                  provider.updatePreferredTeams(selected.toList());
                },
              );
            },
          ),

          // 👤 اللاعبين المفضلين
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("اللاعبين المفضلين"),
            subtitle: Text("${provider.preferredPlayers.length} لاعب"),
            onTap: () async {
              await FavoriteSelector.show(
                context,
                title: "اللاعبين المفضلين",
                items: playersMap, // ✅ من Hive
                selectedItems: provider.preferredPlayers.toSet(),
                onConfirm: (selected) {
                  provider.updatePreferredPlayers(selected.toList());
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
