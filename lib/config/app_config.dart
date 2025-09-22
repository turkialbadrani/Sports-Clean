class AppConfig {
  // 👇 API Key الحقيقي من .env
  static const String apiKey = "4e0499ca8c1bbad9f5383b79159fd191";

  // 👇 Timezone (كان TZ في .env)
  static const String timezone = "Asia/Riyadh";

  // 👇 نقدر نضيف الثيم إذا تحتاجه (كان THEME في .env)
  static const String theme = "dark";

  // 👇 leagues حط القيم اللي كنت تستخدمها (إذا موجودة بملف .env آخر أو ثابتة عندك)
  static const List<int> leagues = [8, 564, 556]; 
}
