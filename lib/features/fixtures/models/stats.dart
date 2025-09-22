class FixtureStatistics {
  final int? teamId;
  final String teamName;
  final String? teamLogo;
  final List<FixtureStatItem> stats;

  FixtureStatistics({
    this.teamId,
    required this.teamName,
    this.teamLogo,
    required this.stats,
  });

  factory FixtureStatistics.fromJson(Map<String, dynamic> json) {
    return FixtureStatistics(
      teamId: json['team']?['id'],
      teamName: json['team']?['name'] ?? '',
      teamLogo: json['team']?['logo'],
      stats: (json['statistics'] as List<dynamic>? ?? [])
          .map((e) => FixtureStatItem.fromJson(e))
          .toList(),
    );
  }
}

class FixtureStatItem {
  final String type;
  final String value;

  FixtureStatItem({
    required this.type,
    required this.value,
  });

  factory FixtureStatItem.fromJson(Map<String, dynamic> json) {
    return FixtureStatItem(
      type: json['type'] ?? '',
      value: json['value']?.toString() ?? '-',
    );
  }
}
