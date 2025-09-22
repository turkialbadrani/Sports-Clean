import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:today_smart/features/localization/ar_names.dart';
import '../../fixtures/models/fixture.dart';
import "package:today_smart/features/fixtures/widgets/fixtures_list_countdown.dart";
import 'chat_button_row.dart'; // ✅ استدعاء الودجت الجديد

class FixturesListCard extends StatelessWidget {
  final FixtureModel fixture;
  const FixturesListCard({super.key, required this.fixture});

  Color _statusColor(String status) {
    if (status.contains("انتهت")) return Colors.red;
    if (status.contains("جارية") || status.contains("مباشر")) return Colors.orange;
    return Colors.grey;
  }

  String _formatMatchDate(DateTime dt) {
    final date = DateFormat('EEEE d MMMM', 'ar').format(dt);
    final time = DateFormat('h:mm a', 'ar').format(dt);
    return "$date - $time";
  }

  @override
  Widget build(BuildContext context) {
    final leagueName = leagueArByIdWithFallback(
      fixture.league.id,
      fixture.league.name,
    );

    final homeTeam = teamArByIdWithFallback(
      fixture.home.id,
      fixture.home.name,
    );

    final awayTeam = teamArByIdWithFallback(
      fixture.away.id,
      fixture.away.name,
    );

    final statusText = fixture.status.toArabic();
    final statusColor = _statusColor(statusText);

    final now = DateTime.now();
    final matchTime = fixture.date;
    final isFinished = statusText.contains("انتهت");
    final isLive = statusText.contains("جارية") || statusText.contains("مباشر");
    final isUpcoming = matchTime.isAfter(now) && !isLive && !isFinished;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🏆 اسم الدوري
            Text(
              leagueName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 🏟️ الفرق + النتيجة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // الفريق المستضيف
                Expanded(
                  child: Column(
                    children: [
                      fixture.home.logoUrl != null && fixture.home.logoUrl!.isNotEmpty
                          ? Image.network(fixture.home.logoUrl!, height: 40)
                          : const Icon(Icons.sports_soccer, size: 40),
                      const SizedBox(height: 4),
                      Text(
                        homeTeam,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // النتيجة
                Column(
                  children: [
                    Text(
                      "${fixture.goals.home ?? '-'} : ${fixture.goals.away ?? '-'}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                // الفريق الضيف
                Expanded(
                  child: Column(
                    children: [
                      fixture.away.logoUrl != null && fixture.away.logoUrl!.isNotEmpty
                          ? Image.network(fixture.away.logoUrl!, height: 40)
                          : const Icon(Icons.sports_soccer, size: 40),
                      const SizedBox(height: 4),
                      Text(
                        awayTeam,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ⏱️ الحالة أو التاريخ
            if (!isUpcoming)
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),

            const SizedBox(height: 4),

            if (isUpcoming) ...[
              Text(
                "🕒 ${_formatMatchDate(matchTime)}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              FixturesListCountdown(matchTime: matchTime),
            ] else if (isFinished) ...[
              Text(
                "📅 ${_formatMatchDate(matchTime)}",
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],

            const SizedBox(height: 8),

            // 🎙️ المعلق
            if (fixture.commentator != null && fixture.commentator!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    fixture.commentator!,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),

            // 📺 القنوات الناقلة (Chips)
            if (fixture.channels != null && fixture.channels!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: fixture.channels!
                      .map(
                        (ch) => Chip(
                          label: Text(
                            ch,
                            style: const TextStyle(fontSize: 11),
                          ),
                          avatar: const Icon(Icons.tv, size: 12),
                          backgroundColor: Colors.blue.shade50,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ),

            const SizedBox(height: 8),

            // ✅ أزرار (تفاصيل / شات)
            ChatButtonRow(fixture: fixture),
          ],
        ),
      ),
    );
  }
}
