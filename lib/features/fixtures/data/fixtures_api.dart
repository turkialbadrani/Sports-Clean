import 'dart:convert';
// TODO: استيراد http لازم يكون محصور بالـ Repository فقط
// TODO: الاستيراد هذا لازم ينقل للـ Repository فقط
import 'package:http/http.dart' as http;

class FixturesApi {
  final String apiKey;
  final String baseUrl;

  FixturesApi({
    required this.apiKey,
    this.baseUrl = "https://v3.football.api-sports.io", // 👈 الـ API الأساسي
  });

  /// 👇 دالة عامة لاستدعاء الـ API
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? params,
  }) async {
    final uri = Uri.parse("$baseUrl/$endpoint").replace(queryParameters: params);
    final response = await // TODO: انقل هذا الاستدعاء إلى Repository
// TODO: هذا الاستدعاء لازم ينقل للـ Repository
http.get(
      uri,
      headers: {
        "x-apisports-key": apiKey,
        "Accept": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("فشل الاتصال: ${response.statusCode}");
    }

    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception("خطأ في قراءة البيانات: $e");
    }
  }
}
