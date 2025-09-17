// lib/core/data/models.dart
class LeagueRef {
  final int id;
  final String name; // raw EN name; UI can localize
  final String? logo;
  const LeagueRef({required this.id, required this.name, this.logo});
}

class TeamRef {
  final int id;
  final String name; // raw EN name; UI can localize
  final String? logo;
  const TeamRef({required this.id, this.name = '', this.logo});
}

class PlayerRef {
  final int id;
  final String name; // raw EN name; UI can localize
  final String? photo;
  final String? position; // EN (GK/DF/MF/FW/...)
  const PlayerRef({required this.id, this.name = '', this.photo, this.position});
}
