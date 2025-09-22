
import 'package:flutter/material.dart';

class PlayerDetailsPage extends StatelessWidget {
  final int playerId;
  final String playerName;

  const PlayerDetailsPage({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(playerName)),
      body: Center(
        child: Text(
          "تفاصيل اللاعب رقم $playerId: $playerName",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
