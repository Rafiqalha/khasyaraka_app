import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/duo_theme.dart';
import '../../data/models/game_modes_models.dart';

class ModeCardWidget extends StatelessWidget {
  final ModeCard mode;
  final VoidCallback onSelect;
  final bool isSelected;
  final int playerCount;

  const ModeCardWidget({
    super.key,
    required this.mode,
    required this.onSelect,
    this.isSelected = false,
    this.playerCount = 0,
  });

  IconData get _iconData {
    switch (mode.icon) {
      case 'robot':
        return Icons.smart_toy_rounded;
      case 'people':
        return Icons.groups_rounded;
      default:
        return Icons.sports_esports_rounded;
    }
  }

  Color get _accentColor {
    switch (mode.icon) {
      case 'robot':
        return DuoTheme.duoBlue;
      case 'people':
        return DuoTheme.duoOrange;
      default:
        return DuoTheme.duoGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPlay = playerCount >= mode.minPlayers;

    return GestureDetector(
      onTap: canPlay ? onSelect : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: isSelected
            ? (Matrix4.identity()..setTranslationRaw(0, -2, 0))
            : Matrix4.identity(),
        child: Container(
          width: double.infinity,
          decoration: DuoTheme.bouncyDecoration(
            mainColor: isSelected ? _accentColor.withValues(alpha: 0.08) : DuoTheme.duoWhite,
            shadowColor: isSelected ? _accentColor.withValues(alpha: 0.3) : DuoTheme.duoGrey,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: canPlay ? 0.12 : 0.05),
                      borderRadius: BorderRadius.circular(DuoTheme.radiusMedium),
                    ),
                    child: Icon(
                      _iconData,
                      color: canPlay ? _accentColor : DuoTheme.duoGreyDark,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode.title,
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: DuoTheme.duoBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person, size: 14, color: DuoTheme.duoGreyDark),
                            const SizedBox(width: 4),
                            Text(
                              '${mode.minPlayers}-${mode.maxPlayers} pemain',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: DuoTheme.duoGreyDark,
                              ),
                            ),
                            if (!canPlay)
                              Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: DuoTheme.duoRed.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Butuh ${mode.minPlayers - playerCount} lagi',
                                      style: GoogleFonts.nunito(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: DuoTheme.duoRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (canPlay)
                    Icon(
                      isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
                      color: _accentColor,
                      size: 22,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                mode.description,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DuoTheme.duoBlackLight,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
