import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "package:today_smart/features/fixtures/widgets/fixtures_tab.dart";
import 'package:today_smart/features/standings/widgets/today_smart_standing_list.dart';  // ✅ التسمية الجديدة
import '../leagues/models/league.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:today_smart/features/localization/ar_names.dart'; // ✅ استيراد التعريب

class FixturesPage extends StatefulWidget {
  const FixturesPage({super.key});

  @override
  State<FixturesPage> createState() => _FixturesPageState();
}

class _FixturesPageState extends State<FixturesPage> {
  int _selectedIndex = 0;
  DateTime currentDate = DateTime.now();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: initSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initSettings);

    FirebaseMessaging.instance.getToken().then((token) {
      debugPrint("📲 FCM Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_id',
              'الإشعارات',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${notification.title} • ${notification.body}"),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("📩 فتح إشعار: ${message.notification?.title}");
    });
  }

  void _setYesterday() {
    setState(() {
      currentDate = DateTime.now().subtract(const Duration(days: 1));
    });
  }

  void _setToday() {
    setState(() {
      currentDate = DateTime.now();
    });
  }

  void _setTomorrow() {
    setState(() {
      currentDate = DateTime.now().add(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      currentDate = currentDate.add(const Duration(days: 1));
    });
  }

  void _previousDay() {
    setState(() {
      currentDate = currentDate.subtract(const Duration(days: 1));
    });
  }

  Widget _buildDayButton(String label, DateTime date, VoidCallback onTap) {
    final isSelected = currentDate.year == date.year &&
        currentDate.month == date.month &&
        currentDate.day == date.day;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy/MM/dd', 'ar').format(currentDate);
    final dayName = DateFormat.EEEE('ar').format(currentDate);

    final List<Widget> _pages = [
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // سهم لليوم السابق
              GestureDetector(
                onTap: _previousDay,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.chevron_left, size: 26, color: Colors.black),
                ),
              ),
              const SizedBox(width: 8),
              // الأزرار (أمس | اليوم | غدًا)
              _buildDayButton("أمس", DateTime.now().subtract(const Duration(days: 1)), _setYesterday),
              _buildDayButton("اليوم", DateTime.now(), _setToday),
              _buildDayButton("غدًا", DateTime.now().add(const Duration(days: 1)), _setTomorrow),
              const SizedBox(width: 8),
              // سهم لليوم التالي
              GestureDetector(
                onTap: _nextDay,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.chevron_right, size: 26, color: Colors.black),
                ),
              ),
            ],
          ),
          // التاريخ تحت
          Text(
            "$dayName، $formattedDate",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: FixturesTab(date: currentDate),
          ),
        ],
      ),
      TodaySmartStandingList(   // ✅ التسمية الجديدة
        leagues: [
          LeagueModel(id: 39, name: "الدوري الإنجليزي الممتاز", logo: null),
          LeagueModel(id: 140, name: "الدوري الإسباني", logo: null),
          LeagueModel(id: 307, name: "دوري روشن السعودي", logo: null),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? "كل المباريات" : "جدول الترتيب"),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: "المباريات",  // ✅ التعريب هنا
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: "الترتيب", // ✅ التعريب هنا
          ),
        ],
      ),
    );
  }
}
