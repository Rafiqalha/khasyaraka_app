import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/logic/cyber_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';

// Tool Pages Imports (Keep existing imports)
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/morse_tool_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/rumput_tool_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_kimia_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_ular_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_semaphore_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_angka_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_napoleon_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_an_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_az_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_kotak1_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_kotak2_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_jam_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_koordinat_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_and_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_kotak3_page.dart';

/// Cyber Dashboard Screen - Rich 3D Gradient Cards Redesign
class CyberDashboardScreen extends StatefulWidget {
  const CyberDashboardScreen({super.key});

  @override
  State<CyberDashboardScreen> createState() => _CyberDashboardScreenState();
}

class _CyberDashboardScreenState extends State<CyberDashboardScreen> {
  // Background Color: Deep Navy / Slate
  static const Color _backgroundColor = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    // Load Sandi list on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<CyberController>();
      if (controller.sandiList.isEmpty) {
        controller.loadSandiList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'CYBER INTELLIGENCE',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.w700, // Bold
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: Consumer<CyberController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
          }

          if (controller.errorMessage != null && controller.sandiList.isEmpty) {
            return _buildErrorState(controller);
          }

          if (controller.sandiList.isEmpty) {
            return const Center(child: Text('No Tools Available', style: TextStyle(color: Colors.white)));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9, // Balanced
            ),
            itemCount: controller.sandiList.length,
            itemBuilder: (context, index) {
              final sandi = controller.sandiList[index];
              return _buildCyberCard(context, sandi, controller);
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(CyberController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.orangeAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            'System Error',
            style: GoogleFonts.sourceCodePro(color: Colors.white, fontSize: 16),
          ),
          TextButton(
            onPressed: () => controller.loadSandiList(),
            child: Text('RETRY', style: GoogleFonts.fredoka(color: Colors.cyanAccent)),
          )
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EXCLUSIVE 3D CARD BUILDER
  // ---------------------------------------------------------------------------
  Widget _buildCyberCard(BuildContext context, SandiModel sandi, CyberController controller) {
    final theme = _getCyberTheme(sandi.codename);

    return GestureDetector(
      onTap: () => _navigateToTool(context, sandi, controller),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.gradientColors.last.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          // 3D Effect: Thick Bottom Border (20% Darker)
          border: Border(
            bottom: BorderSide(
              color: _darken(theme.gradientColors.last, 0.2), 
              width: 5.0,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // ---------------------------------------------------------------
              // LAYER 1: Rich Icon Decoration (Watermark)
              // ---------------------------------------------------------------
              if (theme.backgroundIcons.isNotEmpty) ...[
                Positioned(
                  right: -10,
                  top: -10,
                  child: Transform.rotate(
                    angle: -math.pi / 6,
                    child: Icon(
                      theme.backgroundIcons[0],
                      color: Colors.white.withOpacity(0.15),
                      size: 80,
                    ),
                  ),
                ),
                 Positioned(
                  left: -15,
                  bottom: -15,
                  child: Transform.rotate(
                    angle: math.pi / 8,
                    child: Icon(
                      theme.backgroundIcons.length > 1 ? theme.backgroundIcons[1] : theme.backgroundIcons[0],
                      color: Colors.white.withOpacity(0.12),
                      size: 70,
                    ),
                  ),
                ),
              ],

              // ---------------------------------------------------------------
              // LAYER 2: Main Content
              // ---------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Main Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15), // Glassy circle
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                      ),
                      child: Icon(
                        theme.mainIcon,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    
                    // Title
                    Text(
                      sandi.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w700, // Bold
                        color: Colors.white,
                        shadows: [
                          const Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Subtitle (Monospace)
                    Text(
                      _getSubtitle(sandi.category),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4), // Bottom padding balance
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UTILS & NAVIGATION
  // ---------------------------------------------------------------------------

  Color _darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  String _getSubtitle(String category) {
    switch (category.toLowerCase()) {
      case 'encoding': return 'ENCODING.EXE';
      case 'substitution': return 'SUB.CIPHER';
      case 'transposition': return 'TRANS.CIPHER';
      case 'visual': return 'VISUAL.DAT';
      case 'sandi': return 'SANDI.LOG';
      default: return 'CLASSIFIED';
    }
  }

  void _navigateToTool(BuildContext context, SandiModel sandi, CyberController controller) {
    controller.selectSandi(sandi);
    final codename = sandi.codename.toLowerCase();
    
    Widget page;
    switch (codename) {
      case 'morse': page = MorseToolPage(sandi: sandi); break;
      case 'rumput': page = RumputToolPage(sandi: sandi); break;
      case 'kimia': page = SandiKimiaPage(sandi: sandi); break;
      case 'ular': page = SandiUlarPage(sandi: sandi); break;
      case 'semaphore': page = SandiSemaphorePage(sandi: sandi); break;
      case 'angka': page = SandiAngkaPage(sandi: sandi); break;
      case 'napoleon': page = SandiNapoleonPage(sandi: sandi); break;
      case 'an': page = SandiAnPage(sandi: sandi); break;
      case 'az': 
      case 'az_atbash': page = SandiAzPage(sandi: sandi); break;
      case 'kotak_1':
      case 'kotak1': page = SandiKotak1Page(sandi: sandi); break;
      case 'kotak_2':
      case 'kotak2': page = SandiKotak2Page(sandi: sandi); break;
      case 'kotak_3':
      case 'kotak3': page = SandiKotak3Page(sandi: sandi); break;
      case 'jam': page = SandiJamPage(sandi: sandi); break;
      case 'koordinat': page = SandiKoordinatPage(sandi: sandi); break;
      case 'and': page = SandiAndPage(sandi: sandi); break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${sandi.name} coming soon...', style: GoogleFonts.sourceCodePro()),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ---------------------------------------------------------------------------
  // 15 THEME MAPPINGS
  // ---------------------------------------------------------------------------
  _CyberTheme _getCyberTheme(String codename) {
    switch (codename.toLowerCase()) {
      // 1. Morse (Neon Green -> Emerald)
      case 'morse':
        return _CyberTheme(
          gradientColors: [const Color(0xFF39FF14), const Color(0xFF00C853)],
          mainIcon: Icons.hub, // Looks like nodes/connection
          backgroundIcons: [Icons.radio, Icons.more_horiz],
        );
      
      // 2. Semaphore (Orange -> Deep Orange)
      case 'semaphore':
        return _CyberTheme(
          gradientColors: [const Color(0xFFFF9800), const Color(0xFFE65100)],
          mainIcon: Icons.flag,
          backgroundIcons: [Icons.flag_circle, Icons.directions],
        );

      // 3. Sandi Angka (Cyan -> Blue)
      case 'angka':
        return _CyberTheme(
          gradientColors: [const Color(0xFF00E5FF), const Color(0xFF2962FF)],
          mainIcon: Icons.numbers,
          backgroundIcons: [Icons.onetwothree, Icons.calculate],
        );
      
      // 4. Sandi AN (Purple -> Deep Purple)
      case 'an':
      case 'rot13':
      case 'an_rot13':
        return _CyberTheme(
          gradientColors: [const Color(0xFFD500F9), const Color(0xFF6200EA)],
          mainIcon: Icons.rotate_right,
          backgroundIcons: [Icons.lock_open, Icons.replay],
        );

      // 5. Sandi AZ (Indigo -> Blue Grey)
      case 'az':
      case 'az_atbash':
        return _CyberTheme(
          gradientColors: [const Color(0xFF3D5AFE), const Color(0xFF263238)],
          mainIcon: Icons.swap_horiz,
          backgroundIcons: [Icons.compare_arrows, Icons.sync_alt],
        );

      // 6. Sandi Rumput (Light Green -> Forest Green)
      case 'rumput':
        return _CyberTheme(
          gradientColors: [const Color(0xFF76FF03), const Color(0xFF1B5E20)],
          mainIcon: Icons.grass,
          backgroundIcons: [Icons.forest, Icons.terrain],
        );

      // 7. Sandi Kotak 1 (Pink -> Red)
      case 'kotak_1':
      case 'kotak1':
        return _CyberTheme(
          gradientColors: [const Color(0xFFFF4081), const Color(0xFFD32F2F)],
          mainIcon: Icons.grid_3x3,
          backgroundIcons: [Icons.border_all, Icons.grid_goldenratio],
        );

      // 8. Sandi Kotak 2 (Red -> Maroon)
      case 'kotak_2':
      case 'kotak2':
        return _CyberTheme(
          gradientColors: [const Color(0xFFFF5252), const Color(0xFFB71C1C)],
          mainIcon: Icons.grid_4x4,
          backgroundIcons: [Icons.apps, Icons.window],
        );

      // 9. Sandi Kotak 3 (Deep Orange -> Brown)
      case 'kotak_3':
      case 'kotak3':
        return _CyberTheme(
          gradientColors: [const Color(0xFFFF6E40), const Color(0xFF5D4037)],
          mainIcon: Icons.grid_on,
          backgroundIcons: [Icons.table_chart, Icons.widgets],
        );

      // 10. Sandi Kimia (Teal -> CyanAccent)
      case 'kimia':
        return _CyberTheme(
          gradientColors: [const Color(0xFF1DE9B6), const Color(0xFF00ACC1)],
          mainIcon: Icons.science,
          backgroundIcons: [Icons.bubble_chart, Icons.opacity],
        );

      // 11. Sandi Jam (Light Blue -> Navy)
      case 'jam':
        return _CyberTheme(
          gradientColors: [const Color(0xFF4FC3F7), const Color(0xFF0D47A1)],
          mainIcon: Icons.access_time_filled,
          backgroundIcons: [Icons.schedule, Icons.watch],
        );

      // 12. Sandi Koordinat (Amber -> Orange)
      case 'koordinat':
        return _CyberTheme(
          gradientColors: [const Color(0xFFFFC107), const Color(0xFFFF6F00)],
          mainIcon: Icons.gps_fixed,
          backgroundIcons: [Icons.map, Icons.place],
        );

      // 13. Sandi AND (BlueGrey -> Slate)
      case 'and':
        return _CyberTheme(
          gradientColors: [const Color(0xFF78909C), const Color(0xFF37474F)],
          mainIcon: Icons.code,
          backgroundIcons: [Icons.memory, Icons.developer_board],
        );

      // 14. Sandi Ular (Lime -> Green)
      case 'ular':
        return _CyberTheme(
          gradientColors: [const Color(0xFFC6FF00), const Color(0xFF2E7D32)],
          mainIcon: Icons.waves,
          backgroundIcons: [Icons.gesture, Icons.timeline],
        );

      // 15. Sandi Napoleon (Gold -> Dark Gold/Brown)
      case 'napoleon':
        return _CyberTheme(
          gradientColors: [const Color(0xFFFFD700), const Color(0xFFF57F17)],
          mainIcon: Icons.workspace_premium, // Crown replacement
          backgroundIcons: [Icons.military_tech, Icons.emoji_events],
        );

      default:
        // Fallback Theme
        return _CyberTheme(
          gradientColors: [const Color(0xFF90A4AE), const Color(0xFF455A64)],
          mainIcon: Icons.help_outline,
          backgroundIcons: [Icons.security, Icons.shield],
        );
    }
  }
}

class _CyberTheme {
  final List<Color> gradientColors;
  final IconData mainIcon;
  final List<IconData> backgroundIcons;

  _CyberTheme({
    required this.gradientColors,
    required this.mainIcon,
    required this.backgroundIcons,
  });
}
