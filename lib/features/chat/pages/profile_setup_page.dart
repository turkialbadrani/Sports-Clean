import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileSetupPage extends StatefulWidget {
  final AuthService authService;
  const ProfileSetupPage({super.key, required this.authService});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _controller = TextEditingController();

  void _saveName() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    await widget.authService.saveDisplayName(name);

    if (mounted) {
      Navigator.pop(context, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("اختر اسمك")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("اختر اسم العرض الذي تريده في الشات:"),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "اكتب اسمك هنا",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveName,
              child: const Text("حفظ"),
            ),
          ],
        ),
      ),
    );
  }
}
