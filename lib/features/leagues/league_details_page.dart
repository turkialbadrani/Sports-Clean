import 'package:flutter/material.dart';
import 'package:today_smart/features/leagues/services/leagues_repository.dart';

class LeagueDetailsPage extends StatefulWidget {
  final int leagueId;
  final String leagueName;

  const LeagueDetailsPage({
    super.key,
    required this.leagueId,
    required this.leagueName,
  });

  @override
  State<LeagueDetailsPage> createState() => _LeagueDetailsPageState();
}

class _LeagueDetailsPageState extends State<LeagueDetailsPage> {
  final LeaguesRepository _repo = LeaguesRepository.create();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _details;
  List<int> _seasons = [];

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final details = await _repo.fetchLeagueDetails(widget.leagueId);
      final seasons = await _repo.getSeasons(widget.leagueId);

      setState(() {
        _details = (details is List && details.isNotEmpty)
            ? Map<String, dynamic>.from(details.first)
            : {};
        _seasons = seasons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.leagueName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("خطأ: $_error"))
              : _buildDetails(),
    );
  }

  Widget _buildDetails() {
    if (_details == null || _details!.isEmpty) {
      return const Center(child: Text("لا توجد تفاصيل متاحة"));
    }

    final country = _details!["country"]?["name"] ?? "غير معروف";
    final logo = _details!["league"]?["logo"];
    final type = _details!["league"]?["type"] ?? "غير محدد";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          if (logo != null && logo.toString().isNotEmpty)
            Center(
              child: Image.network(
                logo,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          const SizedBox(height: 16),
          Text("الدولة: $country",
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("النوع: $type",
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          const Divider(),

          const Text("المواسم المتوفرة:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _seasons
                .map((s) => Chip(label: Text(s.toString())))
                .toList(),
          ),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.people),
            label: const Text("عرض الفرق"),
            onPressed: () {
              // ✅ هنا تقدر تفتح شاشة ثانية لعرض الفرق
              // Navigator.push(context, MaterialPageRoute(
              //   builder: (_) => TeamsPage(leagueId: widget.leagueId),
              // ));
            },
          )
        ],
      ),
    );
  }
}
