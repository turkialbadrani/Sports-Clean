import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../services/standings_repository.dart';
import '../models/standing.dart';

enum LoadState { idle, loading, success, error }

class StandingsProvider with ChangeNotifier {
  final StandingsRepository _repo;
  StandingsProvider(this._repo);

  LoadState _state = LoadState.idle;
  String? _error;
  LeagueStanding? _leagueStanding;
  bool _fromCache = false;

  int _selectedGroupIndex = 0;

  // Getters
  LoadState get state => _state;
  String? get error => _error;
  LeagueStanding? get leagueStanding => _leagueStanding;
  bool get fromCache => _fromCache;

  // ✅ يظهر دومًا لو فيه أي مجموعة (حتى لو وحدة)
  bool get hasGroups => (_leagueStanding?.groups.isNotEmpty ?? false);

  List<String> get groupNames {
    final groups = _leagueStanding?.groups ?? const [];
    return groups.asMap().entries.map((e) {
      final name = e.value.name.trim();
      return name.isEmpty ? "Group ${String.fromCharCode(65 + e.key)}" : name;
    }).toList();
  }

  int get selectedGroupIndex => _selectedGroupIndex;

  List<StandingModel> get currentTable {
    final groups = _leagueStanding?.groups ?? const [];
    if (groups.isEmpty) return const [];
    final idx = (_selectedGroupIndex >= 0 && _selectedGroupIndex < groups.length)
        ? _selectedGroupIndex
        : 0;
    return groups[idx].table;
  }

  Future<void> load(int leagueId) async {
    _state = LoadState.loading;
    _error = null;
    _fromCache = false;
    notifyListeners();

    try {
      final box = await Hive.openBox("standings_cache_v2");
      final cacheKey = leagueId.toString();

      final cached = box.get(cacheKey);
      if (cached != null) {
        final savedAt =
            DateTime.tryParse(cached['savedAt'] ?? '') ?? DateTime(2000);
        final payload = cached['payload'];

        if (DateTime.now().difference(savedAt).inMinutes < 10 && payload != null) {
          _leagueStanding = LeagueStanding.fromJson(payload);
          _fromCache = true;
          _state = LoadState.success;
          _selectedGroupIndex = 0;
          notifyListeners();
          return;
        }
      }

      final result = await _repo
          .getStandings(leagueId)
          .timeout(const Duration(seconds: 12));

      if (result == null) {
        _leagueStanding = null;
        _state = LoadState.success;
        _selectedGroupIndex = 0;
      } else {
        _leagueStanding = result;
        _fromCache = false;
        _selectedGroupIndex = 0;

        await box.put(cacheKey, {
          'savedAt': DateTime.now().toIso8601String(),
          'payload': result.toJson(),
        });

        _state = LoadState.success;
      }
    } catch (e) {
      _state = LoadState.error;
      _error = e.toString();
      _leagueStanding = null;
      _fromCache = false;
      _selectedGroupIndex = 0;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh(int leagueId) async {
    _state = LoadState.loading;
    _error = null;
    _fromCache = false;
    notifyListeners();

    try {
      final box = await Hive.openBox("standings_cache_v2");
      final cacheKey = leagueId.toString();
      await box.delete(cacheKey);

      final result = await _repo
          .getStandings(leagueId, forceApi: true)
          .timeout(const Duration(seconds: 12));

      if (result == null) {
        _leagueStanding = null;
        _selectedGroupIndex = 0;
      } else {
        _leagueStanding = result;
        _fromCache = false;
        _selectedGroupIndex = 0;

        await box.put(cacheKey, {
          'savedAt': DateTime.now().toIso8601String(),
          'payload': result.toJson(),
        });
      }

      _state = LoadState.success;
    } catch (e) {
      _state = LoadState.error;
      _error = e.toString();
      _leagueStanding = null;
      _selectedGroupIndex = 0;
    } finally {
      notifyListeners();
    }
  }

  void selectGroupByIndex(int index) {
    if (_leagueStanding == null) return;
    if (index < 0 || index >= (_leagueStanding!.groups.length)) return;
    _selectedGroupIndex = index;
    notifyListeners();
  }
}
