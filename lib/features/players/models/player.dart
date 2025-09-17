class Player {
  final int id;
  final String name;
  final String photo;
  final int? age;
  final String? nationality;
  final String? position; // ✅ جديد
  final int? teamId; // ✅ جديد

  Player({
    required this.id,
    required this.name,
    required this.photo,
    this.age,
    this.nationality,
    this.position,
    this.teamId,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    final playerJson = json['player'] ?? json;
    final teamJson = (json['statistics'] != null && json['statistics'] is List)
        ? (json['statistics'][0]['team'] as Map<String, dynamic>?)
        : null;

    return Player(
      id: playerJson['id'],
      name: playerJson['name'] ?? '',
      photo: playerJson['photo'] ?? '',
      age: playerJson['age'],
      nationality: playerJson['nationality'],
      position: (json['position'] ?? playerJson['position'])?.toString(),
      teamId: teamJson?['id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photo': photo,
        'age': age,
        'nationality': nationality,
        'position': position,
        'teamId': teamId,
      };
}
