class LeagueTree {
  final String name; // القارة
  final List<CountryTree> countries;

  LeagueTree({
    required this.name,
    required this.countries,
  });
}

class CountryTree {
  final String name;
  final String flag;
  final String continent;
  final List<LeagueNode> leagues;

  CountryTree({
    required this.name,
    required this.flag,
    required this.continent,
    required this.leagues,
  });
}

class LeagueNode {
  final int id;
  final String name;
  final String logo;
  final int season;

  LeagueNode({
    required this.id,
    required this.name,
    required this.logo,
    required this.season,
  });

  factory LeagueNode.fromJson(Map<String, dynamic> json) {
    return LeagueNode(
      id: json["id"] ?? 0,
      name: json["name"] ?? "بطولة غير معروفة",
      logo: json["logo"] ?? "",
      season: json["season"] ?? 0,
    );
  }
}
