import 'package:flutter/material.dart';
import 'theme.dart';
import 'core/services/api_client.dart';

// Features
import 'features/fixtures/services/fixtures_repository.dart';
import 'features/fixtures/providers/fixtures_provider.dart';
import 'features/settings/settings_provider.dart';
import 'features/standings/providers/standings_provider.dart';
import 'features/standings/services/standings_repository.dart';
import 'features/leagues/providers/leagues_provider.dart';
import 'features/leagues/providers/directory_provider.dart';
import 'features/leagues/services/leagues_repository.dart';
import 'features/home/home_page.dart';
import 'core/data/football_directory_repo.dart';

// ✅ API repositories
import 'features/players/providers/players_provider.dart';
import 'features/players/services/players_repository.dart' as api_players;

// ✅ JSON to Hive Repositories
import 'core/json_to_hive/leagues_repository.dart' as local_leagues;
import 'core/json_to_hive/clubs_repository.dart';
import 'core/json_to_hive/players_repository.dart' as local_players;

// Localization
import 'features/localization/localization_ar.dart';
import 'features/localization/ar_names.dart';

// External packages
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ✅ Chat Provider
import 'features/chat/providers/chat_provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase + Hive
  await Firebase.initializeApp();
  await Hive.initFlutter();

  // ✅ تأكد من فتح جميع الـ Boxes
  await Hive.openBox('top_scorers');
  await Hive.openBox('user_prefs'); // يهمنا للشات وحفظ الاسم
  await Hive.openBox('players_cache');

  // ✅ صناديق JSON المحلية
  await local_leagues.LeaguesRepository().loadLeagues();
  await ClubsRepository().loadClubs();
  await local_players.PlayersRepository().loadPlayers();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Env + Locale + تعريب
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('ar', null);
  Intl.defaultLocale = 'ar';

  await LocalizationAr.load();
  await initArLocalization();

  // ✅ تخزين FCM Token في Hive
  try {
    final box = Hive.box('user_prefs');
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await box.put('fcm_token', token);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await box.put('fcm_token', newToken);
    });
  } catch (_) {}

  // إعدادات المستخدم
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadPreferences();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => DirectoryProvider()),
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),

        ProxyProvider<SettingsProvider, List<int>>(
          update: (_, settings, __) => <int>{
            ...settings.preferredLeagues,
            ...preferredLeagueIdsFromAssets(),
          }.toList(),
        ),

        ProxyProvider<List<int>, LeaguesRepository>(
          update: (_, leagues, __) => LeaguesRepository(
            ApiClient(
              apiKey: dotenv.env['API_KEY']!,
              timezone: "Asia/Riyadh",
              leagues: leagues,
            ),
          ),
        ),
        ProxyProvider<List<int>, api_players.PlayersRepository>(
          update: (_, leagues, __) => api_players.PlayersRepository(
            ApiClient(
              apiKey: dotenv.env['API_KEY']!,
              timezone: "Asia/Riyadh",
              leagues: leagues,
            ),
          ),
        ),
        ProxyProvider<List<int>, FixturesRepository>(
          update: (_, leagues, __) => FixturesRepository(
            allowedLeagues: leagues,
          ),
        ),
        ProxyProvider<List<int>, StandingsRepository>(
          update: (_, leagues, __) => StandingsRepository(
            apiClient: ApiClient(
              apiKey: dotenv.env['API_KEY']!,
              timezone: "Asia/Riyadh",
              leagues: leagues,
            ),
            allowedLeagues: leagues,
          ),
        ),

        ProxyProvider3<LeaguesRepository, api_players.PlayersRepository, List<int>, FootballDirectory>(
          update: (_, leaguesRepo, playersRepo, leagues, __) => FootballDirectory(
            leaguesRepo: leaguesRepo,
            playersRepo: playersRepo,
            allowedLeagues: leagues,
          ),
        ),

        // ✅ Providers
        ChangeNotifierProvider(create: (_) => LeaguesProvider()),
        ChangeNotifierProvider(
          create: (ctx) => PlayersProvider(
            ctx.read<api_players.PlayersRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => FixturesProvider(ctx.read<FixturesRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => StandingsProvider(ctx.read<StandingsRepository>()),
        ),

        // ✅ Chat Provider هنا
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Today Smart',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', '')],
      home: const HomePage(),
    );
  }
}
