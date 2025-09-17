// lib/core/data/mappers.dart
import 'models.dart';

int? _toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}');

LeagueRef? mapLeague(dynamic raw) {
  if (raw is Map) {
    final m = Map<String, dynamic>.from(raw);
    Map<String, dynamic>? src;
    if (m.containsKey('id')) {
      src = m;
    } else if (m['league'] is Map) {
      src = Map<String, dynamic>.from(m['league'] as Map);
    }
    if (src != null) {
      final id = _toInt(src['id']);
      final name = (src['name'] ?? '').toString();
      final logo = src['logo']?.toString();
      if (id != null) return LeagueRef(id: id, name: name, logo: logo);
    }
  }
  return null;
}

TeamRef? mapTeam(dynamic raw) {
  if (raw is Map) {
    final m = Map<String, dynamic>.from(raw);
    Map<String, dynamic>? src;
    if (m.containsKey('id')) {
      src = m;
    } else if (m['team'] is Map) {
      src = Map<String, dynamic>.from(m['team'] as Map);
    } else if (m['club'] is Map) {
      src = Map<String, dynamic>.from(m['club'] as Map);
    }
    if (src != null) {
      final id = _toInt(src['id']);
      final name = (src['name'] ?? '').toString();
      final logo = src['logo']?.toString();
      if (id != null) return TeamRef(id: id, name: name, logo: logo);
    }
  }
  return null;
}

PlayerRef? mapPlayer(dynamic raw) {
  if (raw is Map) {
    final m = Map<String, dynamic>.from(raw);
    int? id;
    String? name;
    String? photo;
    String? position;

    if (m.containsKey('id')) {
      id = _toInt(m['id']);
      name = m['name']?.toString();
      photo = (m['photo'] ?? m['image'])?.toString();
      position = m['position']?.toString();
    } else if (m['player'] is Map) {
      final p = Map<String, dynamic>.from(m['player'] as Map);
      id = _toInt(p['id']);
      name = p['name']?.toString();
      photo = (p['photo'] ?? p['image'])?.toString();
      if (m['statistics'] is List && (m['statistics'] as List).isNotEmpty) {
        final stat0 = Map<String, dynamic>.from((m['statistics'] as List).first as Map);
        if (stat0['games'] is Map) {
          position = Map<String, dynamic>.from(stat0['games'] as Map)['position']?.toString() ?? position;
        }
      }
    }

    if (id != null) {
      return PlayerRef(id: id, name: name ?? 'Player $id', photo: photo, position: position);
    }
  }
  return null;
}
