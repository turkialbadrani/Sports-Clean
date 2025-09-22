import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:today_smart/features/leagues/providers/leagues_provider.dart';
import 'package:today_smart/features/leagues/models/league_tree.dart';

class LeaguesPage extends StatefulWidget {
  const LeaguesPage({super.key});

  @override
  State<LeaguesPage> createState() => _LeaguesPageState();
}

class _LeaguesPageState extends State<LeaguesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<LeaguesProvider>(context, listen: false).loadLeagues());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaguesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("البطولات"),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(LeaguesProvider provider) {
    if (provider.state == LoadState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.state == LoadState.error) {
      return Center(child: Text("خطأ: ${provider.error}"));
    }

    if (provider.state == LoadState.success) {
      final tree = provider.treeData;
      if (tree.isEmpty) {
        return const Center(child: Text("لا توجد بطولات متاحة"));
      }

      return ListView(
        children: tree.map((continent) {
          return ExpansionTile(
            title: Text(continent.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            children: continent.countries.map((country) {
              return ExpansionTile(
                title: Text(country.name,
                    style: const TextStyle(fontSize: 16)),
                children: country.leagues.map((league) {
                  return ListTile(
                    title: Text(league.name),
                    leading: const Icon(Icons.sports_soccer),
                    onTap: () {
                      // ✅ هنا تروح لشاشة تفاصيل الدوري
                      // Navigator.push(context, MaterialPageRoute(
                      //   builder: (_) => LeagueDetailsPage(leagueId: league.id),
                      // ));
                    },
                  );
                }).toList(),
              );
            }).toList(),
          );
        }).toList(),
      );
    }

    return const Center(child: Text("اضغط لتحميل البطولات"));
  }
}
