import 'package:flutter/material.dart';
import 'package:today_smart/features/polls/services/poll_service.dart';
import 'package:today_smart/features/fixtures/models/fixture.dart';

class PollPage extends StatefulWidget {
  final FixtureModel fixture;

  const PollPage({super.key, required this.fixture});

  @override
  State<PollPage> createState() => _PollPageState();
}

class _PollPageState extends State<PollPage> {
  final _pollService = PollService();
  String? _selectedOption;
  String? _myVote;

  @override
  void initState() {
    super.initState();
    _loadMyVote();
    _initPoll();
  }

  Future<void> _initPoll() async {
    await _pollService.createPoll(
      matchId: widget.fixture.id.toString(),
      question: "من يفوز بالمباراة؟",
      options: [
        widget.fixture.home.name,
        widget.fixture.away.name,
        "تعادل",
      ],
    );
  }

  Future<void> _loadMyVote() async {
    final vote = await _pollService.getMyVote(widget.fixture.id.toString());
    setState(() {
      _myVote = vote;
    });
  }

  Future<void> _submitVote() async {
    if (_selectedOption == null) return;
    await _pollService.vote(
      matchId: widget.fixture.id.toString(),
      option: _selectedOption!,
    );
    await _loadMyVote();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ تم تسجيل تصويتك")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📊 التصويت: ${widget.fixture.home.name} VS ${widget.fixture.away.name}"),
      ),
      body: StreamBuilder(
        stream: _pollService.streamPoll(widget.fixture.id.toString()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data();
          if (data == null) return const Text("لا يوجد تصويت بعد");

          final votes = Map<String, dynamic>.from(data['votes'] ?? {});
          final total = votes.values.fold<int>(0, (a, b) => a + (b as int));

          double percent(int count) => total == 0 ? 0 : (count / total * 100);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_myVote == null) ...[
                  ...votes.keys.map((option) {
                    return RadioListTile<String>(
                      value: option,
                      groupValue: _selectedOption,
                      title: Text(option),
                      onChanged: (val) => setState(() => _selectedOption = val),
                    );
                  }),
                  ElevatedButton(
                    onPressed: _submitVote,
                    child: const Text("تصويت"),
                  ),
                ] else
                  Text("✅ أنت صوتّ: $_myVote", style: const TextStyle(fontSize: 16)),

                const Divider(height: 32),
                Text("📊 النتائج:", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...votes.entries.map((entry) {
                  final option = entry.key;
                  final count = entry.value as int;
                  return _buildResultRow(option, count, percent(count));
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultRow(String label, int votes, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(
            flex: 5,
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blue,
              minHeight: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text("$votes (${percent.toStringAsFixed(1)}%)"),
        ],
      ),
    );
  }
}
