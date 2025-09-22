import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoteBottomSheet extends StatefulWidget {
  final dynamic matchId; // ✅ يقبل int أو String
  final String homeTeam;
  final String awayTeam;
  final bool isFinished; // ✅ جديد

  const VoteBottomSheet({
    super.key,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    this.isFinished = false, // default
  });

  @override
  State<VoteBottomSheet> createState() => _VoteBottomSheetState();
}

class _VoteBottomSheetState extends State<VoteBottomSheet> {
  String? _selectedOption;

  Future<void> _submitVote() async {
    if (_selectedOption == null) return;

    final docRef = FirebaseFirestore.instance
        .collection("polls")
        .doc(widget.matchId.toString());

    await FirebaseFirestore.instance.runTransaction((txn) async {
      final snapshot = await txn.get(docRef);
      if (!snapshot.exists) {
        txn.set(docRef, {
          "home": 0,
          "away": 0,
          "draw": 0,
        });
      }

      txn.update(docRef, {
        _selectedOption!: FieldValue.increment(1),
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ تم تسجيل التصويت")),
    );

    setState(() {
      _selectedOption = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isFinished
                ? "📊 توقعات ${widget.homeTeam} VS ${widget.awayTeam}"
                : "📊 التصويت: ${widget.homeTeam} VS ${widget.awayTeam}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // ✅ إذا المباراة لم تنته -> خيارات التصويت
          if (!widget.isFinished) ...[
            RadioListTile<String>(
              title: Text(widget.homeTeam),
              value: "home",
              groupValue: _selectedOption,
              onChanged: (v) => setState(() => _selectedOption = v),
            ),
            RadioListTile<String>(
              title: Text(widget.awayTeam),
              value: "away",
              groupValue: _selectedOption,
              onChanged: (v) => setState(() => _selectedOption = v),
            ),
            RadioListTile<String>(
              title: const Text("تعادل"),
              value: "draw",
              groupValue: _selectedOption,
              onChanged: (v) => setState(() => _selectedOption = v),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitVote,
              child: const Text("تصويت"),
            ),
            const SizedBox(height: 16),
          ],

          // ✅ النتائج (تظهر في كل الحالات)
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("polls")
                .doc(widget.matchId.toString())
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text("لا يوجد تصويت بعد");
              }
              final data = snapshot.data!;
              final homeVotes = data["home"] ?? 0;
              final awayVotes = data["away"] ?? 0;
              final drawVotes = data["draw"] ?? 0;

              // ✅ تحديد التوقع الأكثر
              String mostExpected = widget.homeTeam;
              int maxVotes = homeVotes;
              if (awayVotes > maxVotes) {
                mostExpected = widget.awayTeam;
                maxVotes = awayVotes;
              }
              if (drawVotes > maxVotes) {
                mostExpected = "تعادل";
                maxVotes = drawVotes;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isFinished)
                    Text("📌 التوقع الأكثر كان: $mostExpected ($maxVotes صوت)"),
                  const SizedBox(height: 8),
                  const Text("📊 النتائج:"),
                  Text("${widget.homeTeam}: $homeVotes"),
                  Text("${widget.awayTeam}: $awayVotes"),
                  Text("تعادل: $drawVotes"),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
