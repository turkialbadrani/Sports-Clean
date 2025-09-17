class LeagueModel {
  final int id;
  final String name;
  final String? logo;
  final String? type;
  final String? country;
  final String? continent;

  LeagueModel({
    required this.id,
    required this.name,
    this.logo,
    this.type,
    this.country,
    this.continent,
  });

  /// ✅ Getter للتوافق مع الكود القديم
  String? get logoUrl => logo;

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    return LeagueModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'بطولة غير معروفة',
      logo: json['logo'],
      type: json['type'],
      country: json['country'],
      continent: json['continent'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logo': logo,
        'type': type,
        'country': country,
        'continent': continent,
      };
}
