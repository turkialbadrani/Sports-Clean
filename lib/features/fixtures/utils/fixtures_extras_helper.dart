import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class FixtureExtra {
  final int id;
  final String? commentator;
  final List<String>? channels;

  FixtureExtra({
    required this.id,
    this.commentator,
    this.channels,
  });

  factory FixtureExtra.fromJson(Map<String, dynamic> json) {
    return FixtureExtra(
      id: json['id'] ?? 0,
      commentator: json['commentator'],
      channels: json['channels'] != null
          ? List<String>.from(json['channels'])
          : null,
    );
  }
}

class FixturesExtrasHelper {
  static List<FixtureExtra> _extras = [];

  /// ✅ تحميل البيانات من ملف assets/fixtures_extras.json
  static Future<void> load() async {
    final raw = await rootBundle.loadString("assets/fixtures_extras.json");
    final List data = jsonDecode(raw);
    _extras = data.map((e) => FixtureExtra.fromJson(e)).toList();
  }

  /// ✅ الحصول على البيانات الإضافية لمباراة حسب ID
  static FixtureExtra? getExtra(int fixtureId) {
    try {
      return _extras.firstWhere((e) => e.id == fixtureId);
    } catch (_) {
      return null;
    }
  }
}
