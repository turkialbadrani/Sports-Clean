# 🗂 توثيق نظام التخزين (Hive) في التطبيق

هذا الملف يوضح كل **Hive Boxes** في المشروع، دورها، وكيفية استخدام JSON كقيمة افتراضية أولية.

---

## 📦 Hive Boxes

### 1. `HiveBoxes.leagues`
- يحتوي على جميع **الدوريات**.
- مصدر البيانات: `assets/localization/leagues_ar.json`.
- الشكل داخل الصندوق:

```json
[
  { "id": 39, "name": "الدوري الإنجليزي الممتاز" },
  { "id": 61, "name": "الدوري الفرنسي" },
  { "id": 78, "name": "الدوري الألماني" }
]
```

- المفتاح الرئيسي: `"all"`.

---

### 2. `HiveBoxes.clubs`
- يحتوي على جميع **الأندية**.
- مصدر البيانات: `assets/localization/teams_ar.json`.
- الشكل:

```json
[
  { "id": 100, "name": "الهلال" },
  { "id": 101, "name": "النصر" }
]
```

- المفتاح: `"all"`.

---

### 3. `HiveBoxes.players`
- يحتوي على جميع **اللاعبين**.
- مصدر البيانات: `assets/localization/players_ar.json`.
- الشكل:

```json
[
  { "id": 2001, "name": "كريستيانو رونالدو" },
  { "id": 2002, "name": "ليونيل ميسي" }
]
```

- المفتاح: `"all"`.

---

### 4. `user_prefs`
- يخزن **إعدادات المستخدم والمفضلات**.
- المفاتيح داخله:
  - `"dark_mode"` → (bool) الوضع الداكن.
  - `"preferred_leagues"` → (List<int>) الدوريات المفضلة.
  - `"preferred_teams"` → (List<int>) الأندية المفضلة.
  - `"preferred_players"` → (List<int>) اللاعبين المفضلين.
  - `"fcm_token"` → (String) رمز التنبيهات من Firebase.

---

### 5. `top_scorers`
- صندوق للكاش (Cache).
- يخزن قائمة الهدافين لكل دوري.

---

### 6. `players_cache`
- صندوق للكاش (Cache).
- يخزن لاعبي كل فريق.

---

## 🔄 دورة البيانات

1. **JSON (assets)**
   - الملفات `leagues_ar.json`, `teams_ar.json`, `players_ar.json` موجودة كمرجع أساسي.
   - تستخدم فقط أول مرة إذا Hive فاضي.

2. **Hive**
   - بعد التحميل الأول، جميع البيانات تحفظ في Hive (`leagues`, `clubs`, `players`).
   - SettingsPage وباقي الشاشات تقرأ مباشرة من Hive.

3. **User Preferences**
   - إذا Hive فاضي عند التشغيل الأول:
     - `preferred_leagues.json` يحمّل القيم الافتراضية.
   - بعدها يتم الحفظ في `user_prefs`.

---

## ✅ الفائدة
- كل البيانات الآن لها مصدر واحد: **Hive**.
- JSON يستخدم فقط كـ **seed** أول مرة.
- التطبيق صار متسق: كل الشاشات تعتمد على نفس المصدر.
