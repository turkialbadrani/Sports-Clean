class StandingModel {
  final int teamId;
  final String? teamName;
  final String? logoUrl;

  final int points;
  final int played;
  final int win;
  final int draw;
  final int lose;

  /// ✅ الترتيب الحالي
  final int? rank;

  /// ✅ الترتيب السابق (يدعم أكثر من مفتاح محتمل من الـ API)
  final int? previousRank;

  /// ✅ اسم المجموعة كما يجي من الـ API (مثال: "Group A")
  final String? group;

  StandingModel({
    required this.teamId,
    this.teamName,
    this.logoUrl,
    required this.points,
    required this.played,
    required this.win,
    required this.draw,
    required this.lose,
    this.rank,
    this.previousRank,
    this.group,
  });

  factory StandingModel.fromJson(Map<String, dynamic> json) {
    final team = (json['team'] as Map?)?.cast<String, dynamic>() ?? const {};
    final stats = json;

    // بعض مزودي البيانات يغيرون اسم previousRank
    final dynamic prevRaw = stats['previousRank'] ??
        stats['previous_rank'] ??
        stats['prevRank'] ??
        stats['previous'];

    return StandingModel(
      teamId: _asInt(team['id']),
      teamName: _asString(team['name']),
      logoUrl: _asString(team['logo']),
      points: _asInt(stats['points']),
      played: _asInt((stats['all'] as Map?)?['played']),
      win: _asInt((stats['all'] as Map?)?['win']),
      draw: _asInt((stats['all'] as Map?)?['draw']),
      lose: _asInt((stats['all'] as Map?)?['lose']),
      rank: _asInt(stats['rank'], nullable: true),
      previousRank: _asInt(prevRaw, nullable: true),
      group: _asString(stats['group']), // ✅ نخزن المجموعة مباشرة
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "teamId": teamId,
      "teamName": teamName,
      "logoUrl": logoUrl,
      "points": points,
      "played": played,
      "win": win,
      "draw": draw,
      "lose": lose,
      "rank": rank,
      "previousRank": previousRank,
      "group": group,
    };
  }

  // ---- Helpers ----
  static int _asInt(dynamic v, {bool nullable = false}) {
    if (v == null) return nullable ? 0 : 0;
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v) ?? (nullable ? 0 : 0);
    return nullable ? 0 : 0;
  }

  static String? _asString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }
}
