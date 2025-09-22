import 'package:flutter/material.dart';
import 'dart:async';

class FixturesListCountdown extends StatefulWidget {
  final DateTime matchTime;

  const FixturesListCountdown({super.key, required this.matchTime});

  @override
  State<FixturesListCountdown> createState() => _FixturesListCountdownState();
}

class _FixturesListCountdownState extends State<FixturesListCountdown> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.matchTime.difference(DateTime.now());
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _timeLeft = widget.matchTime.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft.isNegative) {
      return const Text(
        "بدأت المباراة",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }

    final hours = _timeLeft.inHours;
    final minutes = _timeLeft.inMinutes % 60;
    final seconds = _timeLeft.inSeconds % 60;

    return Text(
      "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
    );
  }
}
