import 'package:flutter/material.dart';
import 'package:today_smart/features/chat/pages/match_chat_page.dart';
import 'package:today_smart/features/chat/pages/profile_setup_page.dart';
import 'package:today_smart/features/chat/services/auth_service.dart';
import 'package:today_smart/features/polls/widgets/vote_bottom_sheet.dart';
import '../match_details_page.dart';
import '../../fixtures/models/fixture.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatButtonRow extends StatelessWidget {
  final FixtureModel fixture;
  const ChatButtonRow({super.key, required this.fixture});

  Future<void> _enterChat(BuildContext context) async {
    final auth = AuthService();

    try {
      // 1) المستخدم الحالي
      User? user = auth.currentUser;

      // 2) تسجيل الدخول إذا ما فيه مستخدم
      if (user == null) {
        final cred = await auth.signInWithGoogle(); // قد تكون UserCredential? أو User?
        if (cred is UserCredential) {
          user = cred.user;
        } else if (cred is User) {
          user = cred;
        }

        if (user == null) return; // المستخدم لغى

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تم تسجيل الدخول بنجاح")),
        );
      }

      // 3) التحقق/تعيين الاسم المعروض
      var name = auth.getDisplayName();
      if (name == null || name.trim().isEmpty) {
        final pickedName = await Navigator.push<String?>(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileSetupPage(authService: auth),
          ),
        );

        if (pickedName == null || pickedName.trim().isEmpty) return;

        await auth.saveDisplayName(pickedName.trim());
        name = pickedName.trim();

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("👤 تم اختيار اسمك: $name")),
        );
      }

      // 4) الدخول إلى الشات
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MatchChatPage(
            matchId: fixture.id,
            homeTeam: fixture.home.name,
            awayTeam: fixture.away.name,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ صار خطأ: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // زر تفاصيل المباراة
        IconButton(
          tooltip: "تفاصيل المباراة",
          icon: const Icon(Icons.info, color: Colors.blue),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MatchDetailsPage(fixture: fixture),
              ),
            );
          },
        ),

        const SizedBox(width: 12),

        // زر شات المباراة
        IconButton(
          tooltip: "شات المباراة",
          icon: const Icon(Icons.chat, color: Colors.green),
          onPressed: () => _enterChat(context),
        ),

        const SizedBox(width: 12),

        // زر التصويت (BottomSheet)
        IconButton(
          tooltip: fixture.isFinished ? "عرض التوقعات" : "تصويت",
          icon: Icon(
            Icons.poll,
            color: fixture.isFinished ? Colors.orange : Colors.purple,
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => VoteBottomSheet(
                matchId: fixture.id,
                homeTeam: fixture.home.name,
                awayTeam: fixture.away.name,
                isFinished: fixture.isFinished,
              ),
            );
          },
        ),
      ],
    );
  }
}
