class LineupPlayer {
  final int id;
  final String name;
  final int number;
  final String pos;

  LineupPlayer({
    required this.id,
    required this.name,
    required this.number,
    required this.pos,
  });

  factory LineupPlayer.fromJson(Map<String, dynamic> j) => LineupPlayer(
        id: j['player']?['id'] ?? 0,
        name: j['player']?['name'] ?? '',
        number: j['player']?['number'] ?? 0,
        pos: j['player']?['pos'] ?? '',
      );
}

class Lineup {
  final int teamId;
  final String teamName;
  final String? teamLogo;
  final String formation;
  final String coach;
  final List<LineupPlayer> startXI;
  final List<LineupPlayer> subs;

  Lineup({
    required this.teamId,
    required this.teamName,
    this.teamLogo,
    required this.formation,
    required this.coach,
    required this.startXI,
    required this.subs,
  });

  factory Lineup.fromJson(Map<String, dynamic> j) => Lineup(
        teamId: j['team']?['id'] ?? 0,
        teamName: j['team']?['name'] ?? '',
        teamLogo: j['team']?['logo'],
        formation: j['formation'] ?? '',
        coach: j['coach']?['name'] ?? '',
        startXI: (j['startXI'] as List<dynamic>? ?? [])
            .map((p) => LineupPlayer.fromJson(p))
            .toList(),
        subs: (j['substitutes'] as List<dynamic>? ?? [])
            .map((p) => LineupPlayer.fromJson(p))
            .toList(),
      );
}
