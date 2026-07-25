import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import 'package:scout_os_app/core/config/environment.dart';
import 'package:scout_os_app/features/os/presentation/providers/catalog_provider.dart';
import 'provisioning_page.dart';

class PradigiInterviewPage extends ConsumerStatefulWidget {
  final String academyId;
  final String specializationId;

  const PradigiInterviewPage({
    super.key,
    required this.academyId,
    required this.specializationId,
  });

  @override
  ConsumerState<PradigiInterviewPage> createState() => _PradigiInterviewPageState();
}

class _PradigiInterviewPageState extends ConsumerState<PradigiInterviewPage> {
  int _step = 0;
  String _mission = '';
  String _experience = '';
  String _executionIntent = '';

  void _nextStep() async {
    if (_step == 2) {
      await _initializeProfile();
    } else {
      setState(() {
        _step++;
      });
    }
  }

  Future<void> _initializeProfile() async {
    try {
      final dio = ApiDioProvider.getDio();
      final host = Environment.apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$'), '');
      
      final payload = {
        'academy_id': widget.academyId,
        'specialization_id': widget.specializationId,
      };

      await dio.post('$host/api/v2/catalog/journeys/initialize', data: payload);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProvisioningPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OS Initialization Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 0) return _buildCatalogStep('missions', 'What is your primary mission?', (id) { _mission = id; _nextStep(); });
    if (_step == 1) return _buildCatalogStep('experiences', 'What best describes your experience level?', (id) { _experience = id; _nextStep(); });
    if (_step == 2) return _buildCatalogStep('execution-intents', 'How would you like to execute this trajectory?', (id) { _executionIntent = id; _nextStep(); });
    
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildCatalogStep(String resource, String question, Function(String) onSelect) {
    final asyncData = ref.watch(catalogProvider(resource));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),
              Text(question, style: PradigiTypography.h1),
              const Spacer(),
              Expanded(
                flex: 4,
                child: asyncData.when(
                  data: (items) {
                    if (items.isEmpty) return const Center(child: Text('No options available.'));
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildOption(item['title'] ?? 'Unknown', () => onSelect(item['id']));
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
