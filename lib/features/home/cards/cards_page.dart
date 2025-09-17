import 'package:flutter/material.dart';
import 'cards_league.dart';
import 'cards_single.dart';
import 'cards_all.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("بطاقات تشاركية")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.blue),
            title: const Text("مرتبة حسب الدوري والوقت"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CardsLeague()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.credit_card, color: Colors.green),
            title: const Text("بطاقة واحدة مرتبة حسب التاريخ والوقت"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CardsSingle()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list, color: Colors.orange),
            title: const Text("المباريات كلها حسب التاريخ والوقت"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CardsAll()),
              );
            },
          ),
        ],
      ),
    );
  }
}
