import 'dart:async';
import 'package:flutter/material.dart';

class MissionBriefingController extends ChangeNotifier {
  MissionBriefingController({required int seconds})
      : _remaining = seconds,
        _total = seconds;

  final int _total;
  int _remaining;
  Timer? _timer;

  int get remaining => _remaining;
  bool get isLocked => _remaining > 0;
  double get progress => _total == 0 ? 1 : (_total - _remaining) / _total;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 0) {
        timer.cancel();
        notifyListeners();
        return;
      }
      _remaining -= 1;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
