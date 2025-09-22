import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class JsonHiveHelper {
  /// ✅ الطريقة الجديدة
  static Future<void> loadJsonToHive({
    required String filePath,
    required String boxName,
  }) async {
    final box = await Hive.openBox(boxName);
    if (box.isNotEmpty) return;

    final data = await rootBundle.loadString(filePath);
    final decoded = json.decode(data);

    List<Map<String, dynamic>> normalized = [];

    if (decoded is List) {
      normalized = decoded
          .whereType<Map>()
          .map((e) => {
                "id": e["id"],
                "name": e["name"],
              })
          .toList();
    } else if (decoded is Map) {
      normalized = decoded.entries
          .map((e) => {
                "id": int.tryParse(e.key) ?? 0,
                "name": e.value.toString(),
              })
          .where((e) => e["id"] != 0 && (e["name"] as String).isNotEmpty)
          .toList();
    }

    await box.put('all', normalized);
  }

  /// ✅ الطريقة القديمة (حفاظًا على التوافق)
  static Future<List<Map<String, dynamic>>> loadJson(String filePath) async {
    final data = await rootBundle.loadString(filePath);
    final decoded = json.decode(data);

    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((e) => {
                "id": e["id"],
                "name": e["name"],
              })
          .toList();
    } else if (decoded is Map) {
      return decoded.entries
          .map((e) => {
                "id": int.tryParse(e.key) ?? 0,
                "name": e.value.toString(),
              })
          .where((e) => e["id"] != 0 && (e["name"] as String).isNotEmpty)
          .toList();
    }

    return [];
  }
}
