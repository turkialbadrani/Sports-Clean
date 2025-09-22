import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LeaguesLoader {
  /// تحميل كل الدوريات من leagues_ar.json
  static Future<Map<int, String>> loadLeagues() async {
    final data =
        await rootBundle.loadString('assets/localization/leagues_ar.json');
    final Map<String, dynamic> jsonMap = json.decode(data);
    return jsonMap.map((key, value) => MapEntry(int.parse(key), value.toString()));
  }
}
