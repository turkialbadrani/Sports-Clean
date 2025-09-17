import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMine;
  final String userName;
  final DateTime? time;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.userName,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMine ? Colors.blueAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // اسم المرسل
            Text(
              userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isMine ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),

            // النص
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isMine ? Colors.white : Colors.black,
              ),
            ),

            // التوقيت (اختياري)
            if (time != null) ...[
              const SizedBox(height: 4),
              Text(
                "${time!.hour}:${time!.minute.toString().padLeft(2, '0')}",
                style: TextStyle(
                  fontSize: 10,
                  color: isMine ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
