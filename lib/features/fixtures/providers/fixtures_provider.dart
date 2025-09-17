// lib/features/fixtures/providers/fixtures_provider.dart

import 'package:flutter/foundation.dart';
import 'package:today_smart/features/fixtures/models/fixture.dart';
import 'package:today_smart/features/fixtures/services/fixtures_repository.dart';

// ✅ استدعاء الفلاتر من ملف مركزي
import 'package:today_smart/features/fixtures/utils/fixtures_filters.dart';

class FixturesProvider with ChangeNotifier {
  final FixturesRepository _repo;

  List<FixtureModel> _fixtures = [];
  bool _isLoading = false;
  String? _error;

  FixturesProvider(this._repo);

  List<FixtureModel> get fixtures => _fixtures;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// ✅ تحميل المباريات لليوم (أو أي تاريخ يحدده المستخدم)
  Future<void> loadFixtures({DateTime? date}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final targetDate = date ?? DateTime.now();
      _fixtures = await _repo.getFixtures(date: targetDate);
    } catch (e) {
      _fixtures = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ جلب مباريات فريق محدد (Home أو Away) باستخدام فلتر مركزي
  List<FixtureModel> getTeamFixtures(int teamId) {
    return filterByTeam(_fixtures, teamId);
  }
}
