import 'package:intl/intl.dart';

import '../models/fixture.dart';
import 'api_client.dart';

class FixturesRepository {
  final ApiClient api;
  FixturesRepository(this.api);

  final Map<String, List<FixtureModel>> _cache = <String, List<FixtureModel>>{};

String _ymd(DateTime d) => DateFormat('yyyy-MM-dd', 'en').format(d); // <- مهم


  /// Load fixtures for a specific calendar day (API timezone already applied).
  Future<List<FixtureModel>> loadForDate(DateTime day) async {
    final key = _ymd(day);
    final cached = _cache[key];
    if (cached != null) return cached;

    final raw = await api.fixturesByDate(key); // List<Map<String, dynamic>>
    final result = raw.map<FixtureModel>((m) => FixtureModel.fromJson(m)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    _cache[key] = result;
    return result;
  }
}
