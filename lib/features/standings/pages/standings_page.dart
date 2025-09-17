import 'package:flutter/material.dart';
import 'standings_body.dart';

class StandingsPage extends StatelessWidget {
  const StandingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📊 جدول الترتيب'),
      ),
      body: StandingsBody(),
    );
  }
}
