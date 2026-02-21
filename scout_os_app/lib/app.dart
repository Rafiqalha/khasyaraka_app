import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/core/config/theme_config.dart'; // Import tema yang baru dibuat
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/core/widgets/main_scaffold.dart';

class ScoutOSApp extends StatelessWidget {
  const ScoutOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TrainingController())],
      child: MaterialApp(
        title: 'Khasyaraka - Scout OS',
        debugShowCheckedModeBanner: false,

        // --- PASANG TEMA DI SINI ---
        theme: ThemeConfig.lightTheme,

        home: const MainScaffold(),
      ),
    );
  }
}
