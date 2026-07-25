import 'package:flutter/material.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import 'package:scout_os_app/features/runtime/presentation/shell/workspace_shell.dart';
import '../../data/datasources/os_remote_datasource.dart';

class MissionPreviewPage extends StatefulWidget {
  final String academyId;
  final String academyTitle;
  final String specializationId;
  final String specializationTitle;

  const MissionPreviewPage({
    super.key,
    required this.academyId,
    required this.academyTitle,
    required this.specializationId,
    required this.specializationTitle,
  });

  @override
  State<MissionPreviewPage> createState() => _MissionPreviewPageState();
}

class _MissionPreviewPageState extends State<MissionPreviewPage> {
  bool _isProvisioning = false;

  Future<void> _provisionAndStartMission0() async {
    setState(() {
      _isProvisioning = true;
    });

    try {
      final dataSource = OsRemoteDataSource();
      await dataSource
          .startMission(
            packId: 'python-fundamental.pack',
            academyId: widget.academyId,
          )
          .timeout(
            const Duration(seconds: 4),
            onTimeout: () => {'status': 'started'},
          );
    } catch (_) {
      // Graceful fallback if offline or mock server
    } finally {
      if (mounted) {
        setState(() {
          _isProvisioning = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WorkspaceShell()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PradigiColors.surface,
      appBar: AppBar(
        backgroundColor: PradigiColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: PradigiColors.textPrimary),
        title: Text('Blueprint Preview', style: PradigiTypography.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.specializationTitle, style: PradigiTypography.h1),
            const SizedBox(height: 8),
            Text(
              'Academy Domain: ${widget.academyTitle}',
              style: PradigiTypography.bodySecondary,
            ),
            const SizedBox(height: 24),

            _buildStatCard(
              'Active Pack Blueprint',
              'Python Fundamental (python-fundamental.pack v1.0.0)',
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Estimated Duration',
              '120 Minutes (8 Adaptive Missions)',
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Initial Step',
              '001_pre_assessment (Python Readiness Diagnostic)',
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Workspace Driver & Image',
              'Docker Container (python:3.11-slim)',
            ),

            const SizedBox(height: 24),
            Text('Pack Mission Flow', style: PradigiTypography.h2),
            const SizedBox(height: 12),

            _buildMissionStepTile('1', '001_pre_assessment', 'Readiness Diagnostic & Mastery Baseline'),
            _buildMissionStepTile('2', '002_variables', 'Variables & Primitive Data Types'),
            _buildMissionStepTile('3', '003_control_flow', 'Conditionals & Boolean Logic'),
            _buildMissionStepTile('4', '004_functions', 'Function Definitions & Parameters'),
            _buildMissionStepTile('5', '005_collections', 'Lists & Dictionaries'),
            _buildMissionStepTile('6', '006_debugging', 'Syntax & Edge Case Debugging Mission'),
            _buildMissionStepTile('7', '007_final_project', 'Mini Project: Student Grade Calculator'),
            _buildMissionStepTile('8', '008_post_assessment', 'Mastery Evaluation & Portfolio Evidence'),

            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PradigiColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: _isProvisioning ? null : _provisionAndStartMission0,
                child: _isProvisioning
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Provisioning Kernel Runtime...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Begin Journey (Launch Mission 1)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PradigiColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PradigiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: PradigiTypography.caption),
          const SizedBox(height: 4),
          Text(
            value,
            style: PradigiTypography.body.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionStepTile(String num, String id, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
