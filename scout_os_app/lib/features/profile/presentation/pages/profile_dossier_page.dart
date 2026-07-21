import 'package:flutter/material.dart';
import '../../../../shared/components/ai_empty_state.dart';
import '../../../../shared/theme/design_tokens.dart';

class ProfileDossierPage extends StatelessWidget {
  const ProfileDossierPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColorTokens.surface,
      body: SafeArea(
        child: AiEmptyState(
          title: 'Agent Dossier',
          description: 'Loading clearance and historical operations...',
          icon: Icons.badge,
        ),
      ),
    );
  }
}
