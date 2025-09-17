import 'dart:convert';
import 'dart:io';

/// قائمة أسماء مشهورة معروفة بالعربي (تقدر تكبرها بنفسك)
final Map<String, String> famousPlayers = {
  "Cristiano Ronaldo": "كريستيانو رونالدو",
  "Lionel Messi": "ليونيل ميسي",
  "Karim Benzema": "كريم بنزيما",
  "Mohamed Salah": "محمد صلاح",
  "Neymar": "نيمار",
  "Kylian Mbappé": "كيليان مبابي",
  "Luka Modrić": "لوكا مودريتش",
  "Sofyan Amrabat": "سفيان أمرابط",
  "Christian Eriksen": "كريستيان إريكسن",
  "Raphaël Varane": "رافاييل فاران",
  "Victor Lindelöf": "فيكتور ليندلوف",
  "Mason Greenwood": "ماسون غرينوود",
  "Anthony Martial": "أنتوني مارسيال",
  "Jonny Evans": "جوني إيفانز",
  "Thiago Silva": "تياغو سيلفا",
};

/// تحويل صوتي (Transliteration) بسيط من إنجليزي إلى عربي
String transliterate(String name) {
  final map = {
    "a": "ا", "b": "ب", "c": "ك", "d": "د", "e": "ي", "f": "ف",
    "g": "ج", "h": "ه", "i": "ي", "j": "ج", "k": "ك", "l": "ل",
    "m": "م", "n": "ن", "o": "و", "p": "ب", "q": "ق", "r": "ر",
    "s": "س", "t": "ت", "u": "و", "v": "ف", "w": "و", "x": "كس",
    "y": "ي", "z": "ز"
  };

  return name.split("").map((ch) {
    final lower = ch.toLowerCase();
    return map.containsKey(lower) ? map[lower]! : ch;
  }).join("");
}

Future<void> main() async {
  final idsFile = File('assets/localization/players_ids.json');
  if (!idsFile.existsSync()) {
    stderr.writeln("❌ players_ids.json غير موجود");
    exit(1);
  }

  final idsMap =
      json.decode(await idsFile.readAsString()) as Map<String, dynamic>;

  final Map<String, String> arabized = {};

  idsMap.forEach((id, engName) {
    if (famousPlayers.containsKey(engName)) {
      arabized[id] = famousPlayers[engName]!;
    } else {
      arabized[id] = transliterate(engName);
    }
  });

  final outFile = File('assets/localization/players_ar_filled.json');
  outFile.writeAsStringSync(
      const JsonEncoder.withIndent("  ").convert(arabized));

  stdout.writeln(
      "✅ تم إنشاء players_ar_filled.json بعدد ${arabized.length} لاعب (كلهم متعربين)");
}
