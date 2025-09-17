import 'package:flutter/material.dart';
import '../../localization/ar_names.dart';
import '../models/standing.dart';

class StandingsTable extends StatelessWidget {
  /// تقدر تمرر البيانات باسمك القديم `standings` أو الجديد `rows`
  final List<StandingModel>? standings; // قديم (متوافق)
  final List<StandingModel>? rows;      // جديد (يتوافق مع مزود المجموعات)

  /// اسم المجموعة (اختياري). لو ما تبي تعرضه خله null.
  final String? groupName;

  /// إذا true و groupName موجود → يطلع شارة صغيرة فوق الجدول
  final bool showGroupHeader;

  const StandingsTable({
    super.key,
    this.standings,
    this.rows,
    this.groupName,
    this.showGroupHeader = false,
  });

  List<StandingModel> get _data => rows ?? standings ?? const [];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = _data;

    if (data.isEmpty) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Text(
            'لا توجد بيانات للعرض.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14.5),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showGroupHeader && (groupName != null && groupName!.trim().isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.surfaceVariant,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            groupName!.trim(),
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),

                  DataTable(
                    headingRowHeight: 44,
                    dataRowMinHeight: 44,
                    dataRowMaxHeight: 56,
                    dividerThickness: 0.6,
                    columnSpacing: 18,
                    horizontalMargin: 14,
                    headingRowColor: MaterialStateProperty.all(cs.surfaceVariant),
                    headingTextStyle: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                    columns: const [
                      DataColumn(label: Text("المركز")),
                      DataColumn(label: Text("الفريق")),
                      DataColumn(label: Text("لعب")),
                      DataColumn(label: Text("ف")),
                      DataColumn(label: Text("ت")),
                      DataColumn(label: Text("خ")),
                      DataColumn(label: Text("نقاط")),
                    ],
                    rows: List<DataRow>.generate(
                      data.length,
                      (i) {
                        final t = data[i];
                        final int total = data.length;

                        final int rank = t.rank ?? (i + 1);

                        // ✅ تعريب الاسم
                        final String teamName = teamArByIdWithFallback(
                          t.teamId,
                          t.teamName ?? '—',
                        );

                        final String? teamLogo = t.logoUrl;

                        final int played = t.played;
                        final int wins = t.win;
                        final int draws = t.draw;
                        final int losses = t.lose;
                        final int points = t.points;

                        final Color? bg = _rankBgColor(rank: rank, total: total);

                        return DataRow(
                          color: MaterialStateProperty.all(bg),
                          cells: [
                            DataCell(Text(
                              '$rank',
                              style: TextStyle(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            )),
                            DataCell(Row(
                              children: [
                                if (teamLogo != null && teamLogo.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(start: 4.0),
                                    child: Image.network(
                                      teamLogo,
                                      width: 22,
                                      height: 22,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox(width: 22, height: 22),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    teamName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: cs.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            DataCell(Text('$played', style: TextStyle(color: cs.onSurface))),
                            DataCell(Text('$wins',   style: TextStyle(color: cs.onSurface))),
                            DataCell(Text('$draws',  style: TextStyle(color: cs.onSurface))),
                            DataCell(Text('$losses', style: TextStyle(color: cs.onSurface))),
                            DataCell(Text(
                              '$points',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: _pointsColor(rank: rank, total: total, cs: cs),
                              ),
                            )),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Color? _rankBgColor({required int rank, required int total}) {
    if (rank == 1) return Colors.amber.withOpacity(0.12);
    if (rank >= 2 && rank <= 5) return Colors.green.withOpacity(0.10);
    if (rank > total - 3) return Colors.red.withOpacity(0.10);
    return null;
  }

  static Color _pointsColor({
    required int rank,
    required int total,
    required ColorScheme cs,
  }) {
    if (rank == 1) return Colors.amberAccent;
    if (rank >= 2 && rank <= 5) return Colors.lightGreenAccent;
    if (rank > total - 3) return Colors.redAccent;
    return cs.onSurface;
  }
}
