import 'package:today_smart/config/app_config.dart';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ← جديد
import 'firebase_options.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Theme + App
import 'theme.dart';
import 'features/home/home_page.dart';

// Providers
import 'features/settings/settings_provider.dart';
import 'features/leagues/providers/leagues_provider.dart';
import 'features/leagues/providers/directory_provider.dart';
import 'features/players/providers/players_provider.dart';
import 'features/fixtures/providers/fixtures_provider.dart';
import 'features/standings/providers/standings_provider.dart';
import 'features/chat/providers/chat_provider.dart';

// Repos + APIs
import 'core/services/api_client.dart';
import 'features/leagues/services/leagues_repository.dart';
import 'features/players/services/players_repository.dart' as api_players;
import 'features/fixtures/services/fixtures_repository.dart';
import 'features/standings/services/standings_repository.dart';
import 'core/data/football_directory_repo.dart';

// Local JSON to Hive
import 'core/json_to_hive/leagues_repository.dart' as local_leagues;
import 'core/json_to_hive/clubs_repository.dart';
import 'core/json_to_hive/players_repository.dart' as local_players;

// Localization
import 'features/localization/localization_ar.dart';
import 'features/localization/ar_names.dart';

// Google Sign-In Service (جديد)
import 'services/google_auth_service.dart';

/// ===== FCM background handler =====
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  try {
    // TODO: تعامل مع الرسالة إن احتجت
  } catch (e, st) {
    await FirebaseCrashlytics.instance.recordError(e, st, reason: 'BG message handler');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase أول شيء
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Boot screen
  runApp(const _BootApp());

  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Crashlytics handlers
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Hive boxes
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox('top_scorers'),
      Hive.openBox('user_prefs'),
      Hive.openBox('players_cache'),
    ]);

    // Env
    final apiKey = AppConfig.apiKey;
    final hasApiKey = (apiKey != null && apiKey.trim().isNotEmpty);

    // Intl
    await initializeDateFormatting('ar', null);
    Intl.defaultLocale = 'ar';
    await LocalizationAr.load();
    await initArLocalization();

    // Local JSON preload (safe)
    try {
      await local_leagues.LeaguesRepository().loadLeagues();
      await ClubsRepository().loadClubs();
      await local_players.PlayersRepository().loadPlayers();
    } catch (e, st) {
      debugPrint('Local JSON preload failed: $e');
      await FirebaseCrashlytics.instance
          .recordError(e, st, reason: 'Local JSON preload failed');
    }

    // Settings + providers
    final settingsProvider = SettingsProvider();
    await settingsProvider.loadPreferences();
    final mergedLeagues = <int>{
      ...settingsProvider.preferredLeagues,
      ...preferredLeagueIdsFromAssets(),
    }.toList();

    // ApiClient
    ApiClient makeClient() => ApiClient(
          apiKey: hasApiKey ? apiKey! : '',
          timezone: "Asia/Riyadh",
          leagues: mergedLeagues,
        );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DirectoryProvider()),
          ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
          Provider<List<int>>.value(value: mergedLeagues),
          ProxyProvider<List<int>, LeaguesRepository>(
            update: (_, leagues, __) => LeaguesRepository(makeClient()),
          ),
          ProxyProvider<List<int>, api_players.PlayersRepository>(
            update: (_, leagues, __) => api_players.PlayersRepository(makeClient()),
          ),
          ProxyProvider<List<int>, FixturesRepository>(
            update: (_, leagues, __) => FixturesRepository(allowedLeagues: leagues),
          ),
          ProxyProvider<List<int>, StandingsRepository>(
            update: (_, leagues, __) => StandingsRepository(
              apiClient: makeClient(),
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
          ChangeNotifierProvider(create: (_) => LeaguesProvider()),
          ChangeNotifierProvider(
            create: (ctx) => PlayersProvider(ctx.read<api_players.PlayersRepository>()),
          ),
          ChangeNotifierProvider(
            create: (ctx) => FixturesProvider(ctx.read<FixturesRepository>()),
          ),
          ChangeNotifierProvider(
            create: (ctx) => StandingsProvider(ctx.read<StandingsRepository>()),
          ),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: MyApp(hasApiKey: hasApiKey),
      ),
    );

    // FCM token handling
    try {
      final box = Hive.box('user_prefs');
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) await box.put('fcm_token', token);
      FirebaseMessaging.instance.onTokenRefresh.listen((t) async => box.put('fcm_token', t));
    } catch (e, st) {
      debugPrint('FCM token handling failed: $e');
      await FirebaseCrashlytics.instance
          .recordError(e, st, reason: 'FCM token handling failed');
    }
  } catch (e, st) {
    await FirebaseCrashlytics.instance.recordError(e, st, fatal: true, reason: 'BOOT ERROR');
    runApp(_BootErrorApp(error: e.toString()));
  }
}

class _BootApp extends StatelessWidget {
  const _BootApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _BootErrorApp extends StatelessWidget {
  final String error;
  const _BootErrorApp({super.key, required this.error});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'تعذّر تشغيل التطبيق:\n$error',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final bool hasApiKey;
  const MyApp({super.key, required this.hasApiKey});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    // إذا ما فيه API_KEY نلتزم بسكرينك القديمة
    if (!hasApiKey) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _NoApiKeyScreen(),
      );
    }

    // إذا فيه API_KEY نضيف بوابة المصادقة
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
      home: const AuthGate(child: HomePage()),
    );
  }
}

/// بوابة مصادقة: إذا المستخدم مسجل يدخل على الواجهة، وإلا يطلع زر Google
class AuthGate extends StatelessWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasData) {
          return child;
        }
        return const SignInScreen();
      },
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _loading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);
    try {
      await GoogleAuthService.signInWithGoogle();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تسجيل الدخول: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _handleGoogleSignIn,
                icon: const Icon(Icons.login),
                label: const Text('تسجيل الدخول بواسطة Google'),
              ),
      ),
    );
  }
}

class _NoApiKeyScreen extends StatelessWidget {
  const _NoApiKeyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '⚠️ مفقود API_KEY في ملف .env\nأضِف API_KEY=XXXX ثم أعد تشغيل التطبيق.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
