import '../../localization/ar_names.dart';
import '../utils/fixtures_extras_helper.dart';

class FixtureTeam {
  final int id;
  final String name;
  final String? logoUrl;

  FixtureTeam({required this.id, required this.name, this.logoUrl});

  factory FixtureTeam.fromJson(Map<String, dynamic> j) => FixtureTeam(
        id: (() {
          final rawId = j['id'];
          if (rawId is int) return rawId;
          return int.tryParse(rawId?.toString() ?? '') ?? 0;
        })(),
        name: teamArByIdWithFallback(
          j['id'],
          j['name'],
        ),
        logoUrl: j['logo'] as String?,
      );
}

class FixtureLeague {
  final int id;
  final String name;
  final String? logoUrl;

  FixtureLeague({required this.id, required this.name, this.logoUrl});

  factory FixtureLeague.fromJson(Map<String, dynamic> j) => FixtureLeague(
        id: (() {
          final rawId = j['id'];
          if (rawId is int) return rawId;
          return int.tryParse(rawId?.toString() ?? '') ?? 0;
        })(),
        name: j['name'] ?? '',
        logoUrl: j['logo'] as String?,
      );
}

class FixtureStatus {
  final String short;
  final String long;

  FixtureStatus({required this.short, required this.long});

  factory FixtureStatus.fromJson(Map<String, dynamic> j) => FixtureStatus(
        short: j['short'] ?? '',
        long: j['long'] ?? '',
      );

  String toArabic() {
    switch (short) {
      case "FT":
        return "انتهت";
      case "NS":
        return "لم تبدأ";
      case "1H":
        return "الشوط الأول";
      case "2H":
        return "الشوط الثاني";
      case "HT":
        return "استراحة";
      case "ET":
        return "أشواط إضافية";
      case "P":
        return "ركلات ترجيح";
      case "CANC":
        return "ملغاة";
      default:
        return long.isNotEmpty ? long : short;
    }
  }
}

class FixtureGoals {
  final int? home;
  final int? away;

  FixtureGoals({this.home, this.away});

  factory FixtureGoals.fromJson(Map<String, dynamic> j) => FixtureGoals(
        home: j['home'],
        away: j['away'],
      );
}

class FixtureModel {
  final int id;
  final DateTime date;
  final FixtureTeam home;
  final FixtureTeam away;
  final FixtureLeague league;
  final FixtureStatus status;
  final FixtureGoals goals;

  // ✅ الإضافات الجديدة
  final String? commentator;
  final List<String>? channels;

  FixtureModel({
    required this.id,
    required this.date,
    required this.home,
    required this.away,
    required this.league,
    required this.status,
    required this.goals,
    this.commentator,
    this.channels,
  });

  // ✅ خصائص مساعدة
  bool get isFinished => status.short == "FT";
  bool get isNotStarted => status.short == "NS";

  factory FixtureModel.fromJson(Map<String, dynamic> j) {
    final id = (() {
      final rawId = j['fixture']?['id'];
      if (rawId is int) return rawId;
      return int.tryParse(rawId?.toString() ?? '') ?? 0;
    })();

    final extra = FixturesExtrasHelper.getExtra(id);

    if (extra != null) {
      print("🎙️ Fixture=$id -> معلق=${extra.commentator}, قنوات=${extra.channels}");
    } else {
      print("❌ Fixture=$id -> لا يوجد بيانات إضافية");
    }

    return FixtureModel(
      id: id,
      date: DateTime.tryParse(j['fixture']?['date'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      home: FixtureTeam.fromJson(j['teams']?['home'] ?? {}),
      away: FixtureTeam.fromJson(j['teams']?['away'] ?? {}),
      league: FixtureLeague.fromJson(j['league'] ?? {}),
      status: FixtureStatus.fromJson(j['fixture']?['status'] ?? {}),
      goals: FixtureGoals.fromJson(j['goals'] ?? {}),
      commentator: extra?.commentator,
      channels: extra?.channels,
    );
  }
}
