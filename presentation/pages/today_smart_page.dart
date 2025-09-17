import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../models/fixture.dart';
import '../../services/api_client.dart';
import '../../services/fixtures_repository.dart';
import '../../widgets/fixture_card.dart';

class TodaySmartPage extends StatefulWidget {
  const TodaySmartPage({super.key});

  @override
  State<TodaySmartPage> createState() => _TodaySmartPageState();
}

class _TodaySmartPageState extends State<TodaySmartPage> with SingleTickerProviderStateMixin {
  late final FixturesRepository repo;
  late final TabController _tab;

  bool _loading = true;
  String? _error;

  // Core day lists
  List<FixtureModel> yesterday = <FixtureModel>[];
  List<FixtureModel> today = <FixtureModel>[];
  List<FixtureModel> tomorrow = <FixtureModel>[];

  // Nearest tabs
  DateTime? nearestUpcomingDay;
  List<FixtureModel> nearestUpcoming = <FixtureModel>[];
  DateTime? nearestRecentDay;
  List<FixtureModel> nearestRecent = <FixtureModel>[];

  @override
  void initState() {
    super.initState();

    final envApi     = dotenv.env['API_KEY'] ?? '';
    final envTZ      = dotenv.env['TZ'] ?? 'Asia/Riyadh';
    final envLeagues = dotenv.env['LEAGUES'] ?? '';

    final leagues = envLeagues.isEmpty
        ? <int>[39, 140, 307]
        : envLeagues.split(',').map((e) => int.tryParse(e.trim())).whereType<int>().toList();

    final api = ApiClient(apiKey: envApi, timezone: envTZ, leagues: leagues);
    repo = FixturesRepository(api);

    _tab = TabController(length: 5, vsync: this, initialIndex: 2);
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() { _loading = true; _error = null; });

    try {
      final now = DateTime.now();
      final baseDay = DateTime(now.year, now.month, now.day);
      final results = await Future.wait<List<FixtureModel>>([
        repo.loadForDate(baseDay.subtract(const Duration(days: 1))),
        repo.loadForDate(baseDay),
        repo.loadForDate(baseDay.add(const Duration(days: 1))),
      ]);

      setState(() {
        yesterday = results[0];
        today = results[1];
        tomorrow = results[2];
      });

      // Compute nearest for the two extra tabs
      final nearestUp = await _findNearestUpcoming(baseDay);
      final nearestRe = await _findNearestRecent(baseDay);
      setState(() {
        nearestUpcomingDay = nearestUp?.$1;
        nearestUpcoming = nearestUp?.$2 ?? <FixtureModel>[];
        nearestRecentDay = nearestRe?.$1;
        nearestRecent = nearestRe?.$2 ?? <FixtureModel>[];
      });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  /// Returns (day, fixtures) for first day after base with fixtures (up to 14 days)
  Future<(DateTime, List<FixtureModel>)?> _findNearestUpcoming(DateTime base) async {
    for (int i = 1; i <= 14; i++) {
      final d = base.add(Duration(days: i));
      final list = await repo.loadForDate(d);
      if (list.isNotEmpty) return (d, list);
    }
    return null;
  }

  /// Returns (day, fixtures) for first day before base with fixtures (up to 14 days)
  Future<(DateTime, List<FixtureModel>)?> _findNearestRecent(DateTime base) async {
    for (int i = 1; i <= 14; i++) {
      final d = base.subtract(Duration(days: i));
      final list = await repo.loadForDate(d);
      if (list.isNotEmpty) return (d, list);
    }
    return null;
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String _arabicDate(DateTime d) {
    final dow = DateFormat('EEEE', 'ar').format(d);
    final dm = DateFormat('dd/MM', 'ar').format(d);
    return '$dow $dm';
    }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final baseDay = DateTime(now.year, now.month, now.day);
    final yDay = baseDay.subtract(const Duration(days: 1));
    final tDay = baseDay.add(const Duration(days: 1));

    final List<Widget> tabs = <Widget>[
      Tab(text: "أقرب آخر مباريات\n${nearestRecentDay != null ? _arabicDate(nearestRecentDay!) : ''}"),
      Tab(text: "أمس\n${_arabicDate(yDay)}"),
      Tab(text: "اليوم\n${_arabicDate(baseDay)}"),
      Tab(text: "غداً\n${_arabicDate(tDay)}"),
      Tab(text: "أقرب مباريات قادمة\n${nearestUpcomingDay != null ? _arabicDate(nearestUpcomingDay!) : ''}"),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('مباريات (SPL/EPL/LaLiga)'),
        bottom: TabBar(controller: _tab, isScrollable: true, tabs: tabs),
        actions: <Widget>[
          IconButton(onPressed: _loadAll, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null)
              ? _ErrorView(message: _error!, onRetry: _loadAll)
              : TabBarView(
                  controller: _tab,
                  children: <Widget>[
                    _NearestTabView(label: 'أقرب آخر مباريات', date: nearestRecentDay, fixtures: nearestRecent),
                    _FixturesList(dayLabel: 'أمس', emptyHint: 'ما فيه مباريات أمس ضمن الدوريات المحددة.', fixtures: yesterday),
                    _todayBody(baseDay),
                    _FixturesList(dayLabel: 'غداً', emptyHint: 'ما فيه مباريات بكرة ضمن الدوريات المحددة.', fixtures: tomorrow),
                    _NearestTabView(label: 'أقرب مباريات قادمة', date: nearestUpcomingDay, fixtures: nearestUpcoming),
                  ],
                ),
    );
  }

  Widget _todayBody(DateTime baseDay) {
    if (today.isNotEmpty) {
      return _FixturesList(dayLabel: 'اليوم', emptyHint: '', fixtures: today);
    }
    // Fallback if today empty: show nearest upcoming, else recent
    if (nearestUpcoming.isNotEmpty) {
      return _NearestTabView(label: 'أقرب مباريات قادمة', date: nearestUpcomingDay, fixtures: nearestUpcoming);
    }
    return _NearestTabView(label: 'أقرب آخر مباريات', date: nearestRecentDay, fixtures: nearestRecent);
  }
}

class _FixturesList extends StatelessWidget {
  final String dayLabel;
  final String emptyHint;
  final List<FixtureModel> fixtures;

  const _FixturesList({required this.dayLabel, required this.emptyHint, required this.fixtures});

  @override
  Widget build(BuildContext context) {
    if (fixtures.isEmpty) {
      return Center(child: Text(emptyHint, style: Theme.of(context).textTheme.titleMedium));
    }
    return ListView.builder(
      itemCount: fixtures.length,
      itemBuilder: (context, index) => FixtureCard(f: fixtures[index]),
    );
  }
}

class _NearestTabView extends StatelessWidget {
  final String label;
  final DateTime? date;
  final List<FixtureModel> fixtures;
  const _NearestTabView({required this.label, required this.date, required this.fixtures});

  @override
  Widget build(BuildContext context) {
    if (fixtures.isEmpty) {
      return Center(child: Text('لا توجد مباريات قريبة.', style: Theme.of(context).textTheme.titleMedium));
    }
    final header = date != null ? '${label} — ${DateFormat('EEEE dd/MM', 'ar').format(date!)}' : label;
    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        Text(header, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: fixtures.length,
            itemBuilder: (context, index) => FixtureCard(f: fixtures[index]),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('تعذّر التحميل', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}
