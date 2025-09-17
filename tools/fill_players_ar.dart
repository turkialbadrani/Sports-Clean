import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Wikidata API endpoint
const wikidataUrl =
    "https://www.wikidata.org/w/api.php?action=wbsearchentities&format=json&language=ar&type=item";

Future<void> main() async {
  final file = File('assets/localization/players_ar.json');
  if (!file.existsSync()) {
    stderr.writeln("❌ ملف players_ar.json غير موجود");
    exit(1);
  }

  // اقرأ ملف اللاعبين
  final Map<String, dynamic> players =
      json.decode(await file.readAsString()) as Map<String, dynamic>;

  // اقرأ أيضًا ملف ids -> English names (مهم عشان نعرف نبحث)
  final idsFile = File('assets/localization/players_ids.json');
  if (!idsFile.existsSync()) {
    stderr.writeln("❌ لازم تسوي ملف players_ids.json فيه ids -> names بالإنجليزي");
    exit(1);
  }
  final Map<String, dynamic> idsMap =
      json.decode(await idsFile.readAsString()) as Map<String, dynamic>;

  int filled = 0;
  for (final entry in players.entries) {
    final id = entry.key;
    if (entry.value != null && entry.value.toString().isNotEmpty) {
      continue; // متعرب من قبل
    }

    final engName = idsMap[id];
    if (engName == null) continue;

    final arabicName = await _searchWikidata(engName);
    if (arabicName != null) {
      players[id] = arabicName;
      filled++;
      stdout.writeln("✅ $engName → $arabicName");
    } else {
      stdout.writeln("❌ ما لقيت تعريب لـ $engName");
    }
    // sleep بسيط عشان ما يحظرونا
    await Future.delayed(Duration(milliseconds: 300));
  }

  // اكتب الملف الجديد
  final outFile = File('assets/localization/players_ar_filled.json');
  outFile.writeAsStringSync(const JsonEncoder.withIndent("  ").convert(players));

  stdout.writeln(
      "\n🎉 خلصنا! عبّينا $filled لاعب بالعربي. الناتج موجود في players_ar_filled.json");
}

Future<String?> _searchWikidata(String name) async {
  final url = Uri.parse("$wikidataUrl&search=${Uri.encodeComponent(name)}");
  final res = await http.get(url);
  if (res.statusCode != 200) return null;

  final data = json.decode(res.body) as Map<String, dynamic>;
  final search = data['search'] as List<dynamic>;
  if (search.isEmpty) return null;

  // أول نتيجة غالبًا صحيحة
  final label = search.first['label'];
  return label is String ? label : null;
}
