class FixtureEvent {
  final int? playerId;
  final String? playerName;
  final int? teamId;
  final String teamName;
  final String type;
  final String detail;
  final int minute;

  FixtureEvent({
    this.playerId,
    this.playerName,
    this.teamId,
    required this.teamName,
    required this.type,
    required this.detail,
    required this.minute,
  });

  factory FixtureEvent.fromJson(Map<String, dynamic> json) {
    return FixtureEvent(
      playerId: json['player']?['id'],
      playerName: json['player']?['name'],
      teamId: json['team']?['id'],
      teamName: json['team']?['name'] ?? '',
      type: json['type'] ?? '',
      detail: json['detail'] ?? '',
      minute: json['time']?['elapsed'] ?? 0,
    );
  }
}
