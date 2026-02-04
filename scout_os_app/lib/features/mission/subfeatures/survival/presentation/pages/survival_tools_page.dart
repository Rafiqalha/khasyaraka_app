import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_mastery_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/data/survival_mastery_model.dart';
import 'package:scout_os_app/routes/app_routes.dart';

class SurvivalToolsPage extends StatefulWidget {
  const SurvivalToolsPage({super.key});

  @override
  State<SurvivalToolsPage> createState() => _SurvivalToolsPageState();
}

class _SurvivalToolsPageState extends State<SurvivalToolsPage> {
  static const _background = Color(0xFFF5F5F5);
  static const _primaryGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SurvivalMasteryController>().loadMastery();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SurvivalMasteryController>();
    
    final tools = <_SurvivalTool>[
      _SurvivalTool(
        title: 'Compass Pro',
        subtitle: 'Real Magnetometer',
        icon: Icons.explore,
        toolType: 'compass',
        isReady: true,
        routeName: AppRoutes.survivalCompass,
      ),
      _SurvivalTool(
        title: 'Clinometer',
        subtitle: 'Angle/Height Measure',
        icon: Icons.straighten,
        toolType: 'clinometer',
        isReady: true,
        routeName: AppRoutes.survivalClinometer,
      ),
      _SurvivalTool(
        title: 'Pedometer',
        subtitle: 'Step Counter',
        icon: Icons.directions_walk,
        toolType: 'pedometer',
        isReady: false,
      ),
      _SurvivalTool(
        title: 'Morse Torch',
        subtitle: 'Flashlight Telegraph',
        icon: Icons.flash_on,
        toolType: 'morse',
        isReady: false,
      ),
      _SurvivalTool(
        title: 'Leveler',
        subtitle: 'Waterpass',
        icon: Icons.horizontal_rule,
        toolType: 'leveler',
        isReady: true,
        routeName: AppRoutes.survivalRiver,
      ),
      _SurvivalTool(
        title: 'GPS Tracker',
        subtitle: 'Coordinate Finder',
        icon: Icons.gps_fixed,
        toolType: 'gps_tracker',
        isReady: true,
        routeName: AppRoutes.survivalGpsTracker,
      ),
    ];

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: Text(
          'SURVIVAL KIT',
          style: GoogleFonts.cinzel(
            color: _primaryGreen,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _primaryGreen),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: tools.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final tool = tools[index];
                  final mastery = controller.getMasteryForTool(tool.toolType);
                  
                  return _SurvivalToolCard(
                    tool: tool,
                    mastery: mastery,
                    onTap: () {
                      if (tool.isReady && tool.routeName != null) {
                        Navigator.pushNamed(context, tool.routeName!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur belum tersedia.')),
                        );
                      }
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _SurvivalTool {
  const _SurvivalTool({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.toolType,
    required this.isReady,
    this.routeName,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String toolType;
  final bool isReady;
  final String? routeName;
}

class _SurvivalToolCard extends StatelessWidget {
  const _SurvivalToolCard({
    required this.tool,
    required this.mastery,
    required this.onTap,
  });

  final _SurvivalTool tool;
  final SurvivalMasteryModel? mastery;
  final VoidCallback onTap;

  static const _surface = Colors.white;
  static const _primaryGreen = Color(0xFF2E7D32);
  static const _textDark = Color(0xFF1B5E20);
  static const _gold = Color(0xFFFFD600);

  @override
  Widget build(BuildContext context) {
    final accent = tool.isReady ? _primaryGreen : Colors.grey;
    final shadow = Colors.black.withValues(alpha: 0.08);
    
    final level = mastery?.currentLevel ?? 1;
    final progress = mastery?.progressToNextLevel ?? 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1),
          boxShadow: [
            BoxShadow(
              color: shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(tool.icon, color: accent, size: 28),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Lv. $level',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tool.title,
                    style: GoogleFonts.playfairDisplay(
                      color: _textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tool.subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 10,
                    ),
                  ),
                  const Spacer(),
                  // Rank Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tool.isReady ? _primaryGreen : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tool.isReady ? 'Ready' : 'Locked',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // XP Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.black12,
                      valueColor: AlwaysStoppedAnimation(accent),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            // Lock Icon Overlay for locked tools
            if (!tool.isReady)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.black38,
                      size: 32,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
