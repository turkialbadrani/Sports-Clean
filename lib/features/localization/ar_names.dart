
// lib/features/localization/ar_names.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

Map<String, String> _teamsAr = {};
Map<String, String> _leaguesAr = {};
Map<String, String> _playersAr = {};
Map<String, String> _countriesAr = {}; 

bool _inited = false;

bool _isArabic(String text) {
  final arabic = RegExp(r'[\u0600-\u06FF]');
  return arabic.hasMatch(text);
}

/// ===============================
/// تهيئة مرّة واحدة وقت الإقلاع
/// ===============================
Future<void> initArLocalization() async {
  if (_inited) return;
  await Future.wait([
    loadTeamsAr(),
    loadLeaguesAr(),
    loadPlayersAr(),
    loadCountriesAr(),
  ]);
  _inited = true;
}

Set<int> preferredLeagueIdsFromAssets() {
  final out = <int>{};
  for (final k in _leaguesAr.keys) {
    final id = int.tryParse(k);
    if (id != null) out.add(id);
  }
  return out;
}

/// ===============================
/// تحميل ملفات JSON
/// ===============================
Future<void> loadTeamsAr() async {
  final data = await rootBundle.loadString('assets/localization/teams_ar.json');
  final Map<String, dynamic> jsonMap = json.decode(data);
  _teamsAr = jsonMap.map((k, v) => MapEntry(k.toString(), v.toString()));
}

Future<void> loadLeaguesAr() async {
  final data = await rootBundle.loadString('assets/localization/leagues_ar.json');
  final Map<String, dynamic> jsonMap = json.decode(data);
  _leaguesAr = jsonMap.map((k, v) => MapEntry(k.toString(), v.toString()));
}

Future<void> loadPlayersAr() async {
  final data = await rootBundle.loadString('assets/localization/players_ar.json');
  final Map<String, dynamic> jsonMap = json.decode(data);
  _playersAr = jsonMap.map((k, v) => MapEntry(k.toString(), v.toString()));
}

Future<void> loadCountriesAr() async {
  try {
    final data = await rootBundle.loadString('assets/localization/countries_ar.json');
    final Map<String, dynamic> jsonMap = json.decode(data);
    _countriesAr = jsonMap.map((k, v) => MapEntry(k.toString(), v.toString()));
  } catch (_) {
    _countriesAr = {};
  }
}

/// ===============================
/// دوال التعريب مع fallback
/// ===============================
String teamArByIdWithFallback(dynamic id, [String? fallback]) {
  final key = id.toString();

  if (_teamsAr.containsKey(key)) {
    final value = _teamsAr[key]!;
    if (value.trim().isNotEmpty) {
      return value;
    }
  }

  if (fallback != null && fallback.isNotEmpty) {
    return fallback;
  }

  return "";
}

String leagueArByIdWithFallback(dynamic id, [String? fallback]) {
  final key = id.toString();

  if (_leaguesAr.containsKey(key)) {
    final value = _leaguesAr[key]!;
    if (value.trim().isNotEmpty) {
      return value;
    }
  }

  if (fallback != null && fallback.isNotEmpty) {
    return fallback;
  }

  return "";
}

String playerArByIdWithFallback(dynamic id, [String? fallback]) {
  final key = id.toString();

  if (_playersAr.containsKey(key)) {
    final value = _playersAr[key]!;
    if (value.trim().isNotEmpty) {
      return value;
    }
  }

  if (fallback != null && fallback.isNotEmpty) {
    return fallback;
  }

  return "";
}

String countryArByNameWithFallback(String? name, [String fallback = 'غير محدد']) {
  final key = (name ?? '').trim();
  if (key.isEmpty) return fallback;
  final found = _countriesAr[key];
  if (found != null && found.trim().isNotEmpty) return found;
  return name ?? fallback;
}

/// ===============================
/// Aliases
/// ===============================
String teamArById(dynamic id, [String? fallback]) =>
    teamArByIdWithFallback(id, fallback);

String leagueArById(dynamic id, [String? fallback]) =>
    leagueArByIdWithFallback(id, fallback);

String playerArById(dynamic id, [String? fallback]) =>
    playerArByIdWithFallback(id, fallback);

String countryArByName(String? name, [String fallback = 'غير محدد']) =>
    countryArByNameWithFallback(name, fallback);

/// ========= واجهة موحّدة للأسماء العربية =========
enum ArNameKind { league, team, player, country }

String arName({
  required ArNameKind kind,
  int? id,
  String? name,
  String fallback = '',
}) {
  switch (kind) {
    case ArNameKind.league:
      return leagueArByIdWithFallback(id, name ?? fallback);
    case ArNameKind.team:
      return teamArByIdWithFallback(id, name ?? fallback);
    case ArNameKind.player:
      return playerArByIdWithFallback(id, name ?? fallback);
    case ArNameKind.country:
      return countryArByNameWithFallback(name, fallback.isEmpty ? 'غير محدد' : fallback);
  }
}

/// ويدجت بديلة لـ Text
class ArNameText extends StatelessWidget {
  final ArNameKind kind;
  final int? id;
  final String? name;
  final String fallback;

  final int maxLines;
  final TextOverflow overflow;
  final TextStyle? style;
  final TextAlign? textAlign;

  const ArNameText({
    super.key,
    required this.kind,
    this.id,
    this.name,
    this.fallback = '',
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.style,
    this.textAlign,
  });

  factory ArNameText.league({required int id, required String fallback, TextStyle? style, int maxLines = 1}) =>
      ArNameText(kind: ArNameKind.league, id: id, fallback: fallback, style: style, maxLines: maxLines);

  factory ArNameText.team({required int id, required String fallback, TextStyle? style, int maxLines = 1}) =>
      ArNameText(kind: ArNameKind.team, id: id, fallback: fallback, style: style, maxLines: maxLines);

  factory ArNameText.player({required int id, required String fallback, TextStyle? style, int maxLines = 1}) =>
      ArNameText(kind: ArNameKind.player, id: id, fallback: fallback, style: style, maxLines: maxLines);

  factory ArNameText.country({required String name, String fallback = 'غير محدد', TextStyle? style, int maxLines = 1}) =>
      ArNameText(kind: ArNameKind.country, name: name, fallback: fallback, style: style, maxLines: maxLines);

  @override
  Widget build(BuildContext context) {
    final display = arName(kind: kind, id: id, name: name, fallback: fallback);
    return Text(
      display,
      maxLines: maxLines,
      overflow: overflow,
      textDirection: TextDirection.rtl,
      textAlign: textAlign,
      style: style ?? Theme.of(context).textTheme.bodyMedium,
    );
  }
}

/// ===============================
/// خرائط كاملة للعرض (للاستخدام في الإعدادات)
/// ===============================
Map<int, String> get leaguesMap =>
    _leaguesAr.map((k, v) => MapEntry(int.parse(k), v));

Map<int, String> get teamsMap =>
    _teamsAr.map((k, v) => MapEntry(int.parse(k), v));

Map<int, String> get playersMap =>
    _playersAr.map((k, v) => MapEntry(int.parse(k), v));
