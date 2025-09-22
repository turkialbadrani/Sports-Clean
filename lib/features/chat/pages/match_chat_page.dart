import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../widgets/message_bubble.dart';

class MatchChatPage extends StatefulWidget {
  final int matchId;
  final String homeTeam;
  final String awayTeam;

  const MatchChatPage({
    super.key,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
  });

  @override
  State<MatchChatPage> createState() => _MatchChatPageState();
}

class _MatchChatPageState extends State<MatchChatPage> {
  final TextEditingController _controller = TextEditingController();
  final auth = AuthService();
  final chatService = ChatService();

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await chatService.sendMessage(
      matchId: widget.matchId.toString(),
      text: text,
    );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.homeTeam} 🆚 ${widget.awayTeam}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatService.getMessages(widget.matchId.toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("💬 لا توجد رسائل بعد"));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final text = msg["text"] ?? "";
                    final uid = msg["uid"] ?? "";
                    final isMine = uid == auth.currentUser?.uid;

                    return MessageBubble(
                      message: text,
                      isMine: isMine,
                      userName: auth.getDisplayName() ?? "مجهول",
                      time: (msg["createdAt"] as Timestamp?)?.toDate(),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "اكتب رسالتك...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
