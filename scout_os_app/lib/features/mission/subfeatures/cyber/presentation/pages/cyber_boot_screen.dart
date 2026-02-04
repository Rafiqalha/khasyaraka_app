import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/glitch_effect.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/scanline_overlay.dart';
import 'package:scout_os_app/routes/app_routes.dart';

class CyberBootScreen extends StatefulWidget {
  const CyberBootScreen({super.key});

  @override
  State<CyberBootScreen> createState() => _CyberBootScreenState();
}

class _CyberBootScreenState extends State<CyberBootScreen> {
  static const List<String> _messages = [
    "INITIALIZING...",
    "BYPASSING FIREWALL...",
    "ESTABLISHING SECURE CONNECTION...",
    "ACCESS GRANTED.",
  ];

  Timer? _textTimer;
  Timer? _navTimer;
  int _messageIndex = 0;
  bool _hasVibratedAccess = false;

  @override
  void initState() {
    super.initState();
    _textTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _messageIndex = (_messageIndex + 1) % _messages.length;
      });
      HapticFeedback.lightImpact();
      if (!_hasVibratedAccess && _messages[_messageIndex] == "ACCESS GRANTED.") {
        _hasVibratedAccess = true;
        HapticFeedback.vibrate();
      }
    });
    _navTimer = Timer(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.cyberDashboard);
    });
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GlitchEffect(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Stack(
            children: [
              const Positioned.fill(child: ScanlineOverlay()),
              Center(
                child: Image.asset(
                  'assets/icons/cyber/cyber_logo.png',
                  width: 300,
                ),
              ),
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    _messages[_messageIndex],
                    style: CyberTheme.body().copyWith(color: CyberTheme.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
