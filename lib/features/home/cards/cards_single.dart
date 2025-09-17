import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:today_smart/features/fixtures/controllers/fixtures_controller.dart';
import 'package:today_smart/features/fixtures/models/fixture.dart';
import 'package:today_smart/features/localization/localization_ar.dart';

class CardsSingle extends StatefulWidget {
  const CardsSingle({super.key});

  @override
  State<CardsSingle> createState() => _CardsSingleState();
}

class _CardsSingleState extends State<CardsSingle> {
  late Future<List<FixtureModel>> fixturesFuture;
  final GlobalKey _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fixturesFuture = FixturesController().getFixturesByDate(DateTime.now());
  }

  String _formatTime(DateTime dt) => DateFormat('h:mm a', 'ar').format(dt);

  Future<void> _shareCard() async {
    try {
      RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/match_card.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)],
          text: "🎴 بطاقة مباريات اليوم");
    } catch (e) {
      debugPrint("❌ خطأ بالمشاركة: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("بطاقة واحدة"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareCard, // ✅ زر المشاركة
          ),
        ],
      ),
      body: FutureBuilder<List<FixtureModel>>(
        future: fixturesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("خطأ: ${snapshot.error}"));
          }
          final fixtures = snapshot.data ?? [];
          if (fixtures.isEmpty) {
            return const Center(child: Text("ما فيه مباريات اليوم"));
          }

          fixtures.sort((a, b) => a.date.compareTo(b.date));

          return Center(
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: _cardKey,
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage("assets/images/backgrounds/default.png"),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 8)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "📅 مباريات اليوم",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...fixtures.map((match) {
                        final home = LocalizationAr.teamName(
                            match.home.id, match.home.name);
                        final away = LocalizationAr.teamName(
                            match.away.id, match.away.name);
                        final time = _formatTime(match.date);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  home,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                              Text(
                                time,
                                style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  away,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
