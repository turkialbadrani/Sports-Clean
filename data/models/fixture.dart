class FixtureTeam {
  final int id;
  final String name;
  final String? logoUrl;

  FixtureTeam({required this.id, required this.name, this.logoUrl});

  factory FixtureTeam.fromJson(Map<String, dynamic> j) => FixtureTeam(
        id: j['id'] ?? 0,
        name: j['name'] ?? '',
        logoUrl: j['logo'] as String?,
      );
}

class FixtureLeague {
  final int id;
  final String name;
  final String? logoUrl;

  FixtureLeague({required this.id, required this.name, this.logoUrl});

  factory FixtureLeague.fromJson(Map<String, dynamic> j) => FixtureLeague(
        id: j['id'] ?? 0,
        name: j['name'] ?? '',
        logoUrl: j['logo'] as String?,
      );
}

class FixtureStatus {
  final String short; // e.g., FT, NS, 1H
  final String long;
  FixtureStatus({required this.short, required this.long});

  factory FixtureStatus.fromJson(Map<String, dynamic> j) => FixtureStatus(
        short: j['short'] ?? '',
        long: j['long'] ?? '',
      );

  String toArabic() {
    switch (short) {
      case 'FT':
        return 'انتهت';
      case 'NS':
        return 'قادمة';
      case 'HT':
        return 'استراحة';
      case '1H':
      case '2H':
      case 'ET':
        return 'قيد اللعب';
      case 'PST':
        return 'مؤجلة';
      default:
        return long;
    }
  }
}

class FixtureScore {
  final int? home;
  final int? away;
  FixtureScore({this.home, this.away});

  factory FixtureScore.fromJson(Map<String, dynamic>? j) =>
      FixtureScore(home: j?['home'] as int?, away: j?['away'] as int?);
}

class FixtureModel {
  final int id;
  final DateTime date; // already in desired timezone from API
  final FixtureLeague league;
  final FixtureTeam home;
  final FixtureTeam away;
  final FixtureStatus status;
  final FixtureScore goals;
  final FixtureScore scoreFull;

  FixtureModel({
    required this.id,
    required this.date,
    required this.league,
    required this.home,
    required this.away,
    required this.status,
    required this.goals,
    required this.scoreFull,
  });

  factory FixtureModel.fromJson(Map<String, dynamic> j) {
    final f = j['fixture'] as Map<String, dynamic>;
    final t = DateTime.parse((f['date'] ?? DateTime.now().toIso8601String()) as String);
    return FixtureModel(
      id: f['id'] ?? 0,
      date: t,
      league: FixtureLeague.fromJson(j['league'] as Map<String, dynamic>),
      home: FixtureTeam.fromJson((j['teams'] as Map<String, dynamic>)['home']),
      away: FixtureTeam.fromJson((j['teams'] as Map<String, dynamic>)['away']),
      status: FixtureStatus.fromJson((f['status'] as Map<String, dynamic>)),
      goals: FixtureScore.fromJson(j['goals'] as Map<String, dynamic>?),
      scoreFull: FixtureScore.fromJson((j['score'] as Map<String, dynamic>?)?['fulltime'] as Map<String, dynamic>?),
    );
  }

  bool get isLive {
    final s = status.short;
    return s == '1H' || s == '2H' || s == 'ET';
  }

  String kickoffTime() {
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
