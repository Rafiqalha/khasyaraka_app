/// Example: How to Use the SurvivalCard Widget
/// 
/// This file demonstrates all the ways you can use the new SurvivalCard widget
/// in your Flutter applications.

import 'package:flutter/material.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/presentation/widgets/survival_card.dart';
import 'package:scout_os_app/routes/app_routes.dart';

// ============================================================================
// EXAMPLE 1: Basic Usage with Live Preview
// ============================================================================

class BasicSurvivalCardExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SurvivalCard(
      // Required parameters
      title: '🧭 Kompas',                    // Tool name with emoji
      subtitle: 'Magnetometer',              // Tool type
      description: 'Real-time magnetic heading',  // What it does
      accentColor: Color(0xFF00D084),        // Green accent
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.survivalCompass);
      },
      
      // Optional parameters
      preview: CompassPreview(),             // Live data widget
    );
  }
}

// ============================================================================
// EXAMPLE 2: Custom Background Color
// ============================================================================

class CustomBackgroundExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SurvivalCard(
      title: '🌡️ Thermometer',
      subtitle: 'Temperature Sensor',
      description: 'Ambient temperature reading',
      accentColor: Colors.red,
      onTap: () => print('Temperature tool tapped'),
      backgroundColor: Color(0xFF2C3E50),   // Custom dark background
      preview: TemperaturePreview(),
    );
  }
}

// ============================================================================
// EXAMPLE 3: Card with Emoji Icon Only (No Preview Widget)
// ============================================================================

class IconOnlyExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SurvivalCard(
      title: '⚙️ Settings',
      subtitle: 'Preferences',
      description: 'Configure tool options',
      accentColor: Colors.blueAccent,
      onTap: () => Navigator.pushNamed(context, '/settings'),
      icon: '⚙️',  // This will display in the center if no preview provided
    );
  }
}

// ============================================================================
// EXAMPLE 4: Full Dashboard Grid (3 Cards)
// ============================================================================

class SurvivalDashboardExample extends StatelessWidget {
  static const _darkBackground = Color(0xFF0D1B2A);
  static const _darkCard = Color(0xFF1B2F47);
  static const _tacticalGreen = Color(0xFF00D084);
  static const _accentOrange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        backgroundColor: _darkCard,
        title: Text('SURVIVAL KIT'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            // Card 1: Compass
            SurvivalCard(
              title: '🧭 Kompas',
              subtitle: 'Magnetometer',
              description: 'Real-time magnetic heading',
              accentColor: _tacticalGreen,
              onTap: () => Navigator.pushNamed(context, AppRoutes.survivalCompass),
              preview: CompassPreview(),
            ),
            
            // Card 2: Clinometer
            SurvivalCard(
              title: '📐 Klinometer',
              subtitle: 'Angle Meter',
              description: 'Pitch & roll angles',
              accentColor: _accentOrange,
              onTap: () => Navigator.pushNamed(context, AppRoutes.survivalClinometer),
              preview: ClinometerPreview(),
            ),
            
            // Card 3: GPS Tracker
            SurvivalCard(
              title: '📍 GPS Tracker',
              subtitle: 'Location Data',
              description: 'Coordinates & altitude',
              accentColor: _tacticalGreen,
              onTap: () => Navigator.pushNamed(context, AppRoutes.survivalGpsTracker),
              preview: GpsPreview(),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 5: Dynamic Card List
// ============================================================================

class DynamicCardListExample extends StatefulWidget {
  @override
  _DynamicCardListExampleState createState() => _DynamicCardListExampleState();
}

class _DynamicCardListExampleState extends State<DynamicCardListExample> {
  final List<Map<String, dynamic>> tools = [
    {
      'title': '🧭 Kompas',
      'subtitle': 'Magnetometer',
      'description': 'Real-time magnetic heading',
      'color': Color(0xFF00D084),
      'icon': '🧭',
    },
    {
      'title': '📐 Klinometer',
      'subtitle': 'Angle Meter',
      'description': 'Pitch & roll angles',
      'color': Color(0xFFFF6B35),
      'icon': '📐',
    },
    {
      'title': '📍 GPS Tracker',
      'subtitle': 'Location Data',
      'description': 'Coordinates & altitude',
      'color': Color(0xFF00D084),
      'icon': '📍',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return SurvivalCard(
          title: tool['title'],
          subtitle: tool['subtitle'],
          description: tool['description'],
          accentColor: tool['color'],
          icon: tool['icon'],
          onTap: () => print('${tool['title']} tapped'),
        );
      },
    );
  }
}

// ============================================================================
// EXAMPLE 6: Card with Complex Preview Widget
// ============================================================================

class ComplexPreviewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SurvivalCard(
      title: '📊 Analytics',
      subtitle: 'Data Summary',
      description: 'Real-time analytics',
      accentColor: Colors.purpleAccent,
      onTap: () => print('Analytics tapped'),
      preview: CustomAnalyticsPreview(),
    );
  }
}

class CustomAnalyticsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '45.2°',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Current Reading',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// EXAMPLE 7: Responsive Card Layout
// ============================================================================

class ResponsiveCardLayoutExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen width to determine grid columns
    final width = MediaQuery.of(context).size.width;
    final columns = width > 600 ? 3 : 2;  // 3 columns on tablet, 2 on phone

    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        // Your SurvivalCard widgets here
      ],
    );
  }
}

// ============================================================================
// EXAMPLE 8: Card with Custom Styling
// ============================================================================

class CustomStyledCardExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SurvivalCard(
      title: '🎯 Target',
      subtitle: 'Targeting System',
      description: 'Aim and lock',
      accentColor: Colors.amber,
      backgroundColor: Color(0xFF1A1A2E),  // Custom very dark background
      icon: '🎯',
      onTap: () => print('Target system engaged'),
    );
  }
}

// ============================================================================
// PLACEHOLDER PREVIEW WIDGETS
// ============================================================================

class CompassPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('123°', style: TextStyle(fontSize: 24, color: Colors.white)),
        Text('SE', style: TextStyle(fontSize: 14, color: Colors.green)),
      ],
    );
  }
}

class ClinometerPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('45.3°', style: TextStyle(fontSize: 24, color: Colors.white)),
        Text('Pitch', style: TextStyle(fontSize: 14, color: Colors.orange)),
      ],
    );
  }
}

class GpsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('-6.1234', style: TextStyle(fontSize: 12, color: Colors.white)),
        Text('106.7654', style: TextStyle(fontSize: 12, color: Colors.white)),
        Text('45m', style: TextStyle(fontSize: 14, color: Colors.green)),
      ],
    );
  }
}

class TemperaturePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('28°C', style: TextStyle(fontSize: 28, color: Colors.red)),
        Text('Warm', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// ============================================================================
// NOTES
// ============================================================================

/*
KEY POINTS:

1. REQUIRED PARAMETERS:
   - title: String (e.g., '🧭 Kompas')
   - subtitle: String (e.g., 'Magnetometer')
   - description: String (e.g., 'Real-time magnetic heading')
   - accentColor: Color (e.g., Color(0xFF00D084))
   - onTap: VoidCallback (navigation or action)

2. OPTIONAL PARAMETERS:
   - preview: Widget (live data display)
   - backgroundColor: Color (custom card background)
   - icon: String (emoji, shown if no preview)

3. STYLING:
   - Colors: Customize via accentColor parameter
   - Size: Automatic via parent GridView
   - Border: Always 2px, auto-colored
   - Shadow: Auto-colored based on accentColor

4. NO GAMIFICATION:
   - No levels
   - No badges
   - No progress bars
   - No locked states
   - All cards always active

5. PERFORMANCE:
   - Efficient rendering
   - No unnecessary rebuilds
   - Smooth animations
   - Responsive to sensor data

6. CUSTOMIZATION:
   - Easy to theme
   - Reusable across app
   - Mix and match colors
   - Add to any grid layout
*/
