import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/core/config/environment.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import '../shell/mission_workspace.dart';

class ProvisioningPage extends StatefulWidget {
  const ProvisioningPage({super.key});

  @override
  State<ProvisioningPage> createState() => _ProvisioningPageState();
}

class _ProvisioningPageState extends State<ProvisioningPage> {
  String _currentStep = "Connecting to Pradigi OS...";
  double _progress = 0.0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _startProvisioningStream();
  }

  Future<void> _startProvisioningStream() async {
    try {
      final dio = ApiDioProvider.getDio();
      final host = Environment.apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$'), '');
      
      final response = await dio.get<ResponseBody>(
        '$host/api/v2/profile/provision-stream',
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data?.stream;
      if (stream == null) return;

      await for (final Uint8List chunk in stream) {
        if (!mounted) break;
        final dataStr = utf8.decode(chunk);
        
        final lines = dataStr.split('\n');
        String? eventName;
        String? eventData;

        for (final line in lines) {
          if (line.startsWith('event:')) {
            eventName = line.substring(6).trim();
          } else if (line.startsWith('data:')) {
            eventData = line.substring(5).trim();
          }
        }

        if (eventName != null && eventData != null) {
          try {
            final parsedData = jsonDecode(eventData);
            setState(() {
              _currentStep = parsedData['message'] ?? eventName;
              _progress += 1.0 / 7.0; // 7 steps in backend
            });

            if (eventName == 'workspace.ready') {
              _isComplete = true;
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MissionWorkspace()),
                );
              }
            }
          } catch (_) {
            // json parse error, ignore
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentStep = "Provisioning Failed. Please restart.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'OS PROVISIONING',
                style: PradigiTypography.h2.copyWith(color: Colors.white54, letterSpacing: 4),
              ),
              const SizedBox(height: 48),
              LinearProgressIndicator(
                value: _isComplete ? 1.0 : _progress,
                backgroundColor: Colors.white24,
                color: Colors.white,
                minHeight: 2,
              ),
              const SizedBox(height: 24),
              Text(
                _currentStep,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
