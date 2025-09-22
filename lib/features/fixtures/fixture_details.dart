import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fixture.dart';

class FixtureDetailsPage extends StatelessWidget {
  final FixtureModel fixture;

  const FixtureDetailsPage({super.key, required this.fixture});

  String _formatDate(DateTime dt) {
    final date = DateFormat('EEEE d MMMM', 'ar').format(dt);
    final time = DateFormat('h:mm a', 'ar').format(dt);
    return "$date - $time";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fixture.league.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🏆 الدوري
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (fixture.league.logoUrl != null &&
                    fixture.league.logoUrl!.isNotEmpty)
                  Image.network(fixture.league.logoUrl!, height: 32),
                const SizedBox(width: 8),
                Text(
                  fixture.league.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // الفرق + النتيجة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeam(fixture.home.name, fixture.home.logoUrl),
                Column(
                  children: [
                    Text(
                      "${fixture.goals.home ?? '-'} : ${fixture.goals.away ?? '-'}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fixture.status.toArabic(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                  ],
                ),
                _buildTeam(fixture.away.name, fixture.away.logoUrl),
              ],
            ),

            const SizedBox(height: 20),

            // التاريخ
            Text(
              "📅 ${_formatDate(fixture.date)}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // 🔹 Placeholder عشان تضيف Tabs لاحقاً
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text("إحصائيات المباراة (قريباً)"),
              ),
            ),
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.groups),
                title: const Text("تشكيلة الفريقين (قريباً)"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeam(String name, String? logoUrl) {
    return Column(
      children: [
        logoUrl != null && logoUrl.isNotEmpty
            ? Image.network(logoUrl, height: 50)
            : const Icon(Icons.sports_soccer, size: 50),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
