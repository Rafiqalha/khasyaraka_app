import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class GpsTrackerToolPage extends StatefulWidget {
  const GpsTrackerToolPage({super.key});

  @override
  State<GpsTrackerToolPage> createState() => _GpsTrackerToolPageState();
}

class _GpsTrackerToolPageState extends State<GpsTrackerToolPage>
    with TickerProviderStateMixin {
  // --- DUO-STYLE PALETTE ---
  static const _duoGreen = Color(0xFF58CC02); // Bright Green
  static const _duoGreenShadow = Color(
    0xFF58A700,
  ); // Darker Green for 3D effect
  static const _duoBlue = Color(0xFF1CB0F6); // Bright Blue
  static const _duoTeal = Color(0xFF2B7F8C); // Teal-ish
  static const _duoOrange = Color(0xFFFF9600); // Bright Orange
  static const _duoRed = Color(0xFFFF4B4B); // Bright Red
  static const _duoWhite = Colors.white;
  static const _duoGrey = Color(0xFFE5E5E5);

  // --- CONTROLLERS ---
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;

  // --- STATE DATA ---
  Position? _currentPosition;
  bool _isTrackingMe = true;
  double _currentRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _initGps();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // --- GPS LOGIC ---
  Future<void> _initGps() async {
    // Feature disabled: Location permission removed from Manifest per user request
    return;
  }

  void _lockNorth() {
    setState(() => _currentRotation = 0.0);
    _mapController.rotate(0.0);
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy < 10) return _duoGreen;
    if (accuracy < 30) return _duoOrange;
    return _duoRed;
  }

  @override
  Widget build(BuildContext context) {
    final myPos = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(-6.200, 106.816);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ==============================
          // LAYER 1: MAP ENGINE (OSM)
          // ==============================
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: myPos,
              initialZoom: 18.0,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _isTrackingMe = false;
                    _currentRotation = _mapController.camera.rotation;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.khasyaraka.scout_os',
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: myPos,
                    width: 60,
                    height: 60,
                    child: Transform.rotate(
                      angle:
                          _currentRotation *
                          (3.14159 / 180) *
                          -1, // Counter-rotate marker to keep upright if needed, or rotate with heading
                      child: Tooltip(
                        message: "Posisi Saya",
                        child: Image.asset(
                          'assets/images/tunas_kelapa.png',
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.navigation,
                                color: _duoGreen,
                                size: 50,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ==============================
          // LAYER 2: TOP HEADER (FLOATING CARD)
          // ==============================
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: _duoWhite,
                borderRadius: BorderRadius.circular(24),
                border: const Border(
                  bottom: BorderSide(color: _duoGrey, width: 5), // 3D Effect
                  top: BorderSide(color: _duoGrey, width: 2),
                  left: BorderSide(color: _duoGrey, width: 2),
                  right: BorderSide(color: _duoGrey, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.satellite_alt, color: _duoBlue, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    "Sinyal Satelit Aktif",
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==============================
          // LAYER 3: SIDE BUTTONS (LOCK NORTH)
          // ==============================
          Positioned(
            right: 20,
            top: 150,
            child: _build3DIconButton(
              icon: Icons.explore,
              color: _duoWhite,
              iconColor: _duoBlue,
              onTap: _lockNorth,
            ),
          ),

          // ==============================
          // LAYER 4: BOTTOM PANEL (DATA CAPSULES)
          // ==============================
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Floating Action Button (My Location)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isTrackingMe = true;
                      _lockNorth();
                    });
                    if (_currentPosition != null) {
                      _mapController.move(
                        LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        18,
                      );
                    }
                  },
                  child: Container(
                    width: 65,
                    height: 60,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: _duoGreen,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: _duoGreenShadow,
                          offset: Offset(0, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

                // Main Data Panel
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _duoWhite,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Lat & Long Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildDataCapsule(
                              "Latitude",
                              _currentPosition?.latitude.toStringAsFixed(5) ??
                                  "...",
                              _duoTeal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDataCapsule(
                              "Longitude",
                              _currentPosition?.longitude.toStringAsFixed(5) ??
                                  "...",
                              _duoBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Alt & Accuracy Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildDataCapsule(
                              "Altitude",
                              "${_currentPosition?.altitude.toStringAsFixed(1) ?? '0'} m",
                              _duoOrange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDataCapsule(
                              "Akurasi",
                              "±${_currentPosition?.accuracy.toStringAsFixed(0) ?? '0'} m",
                              _currentPosition != null
                                  ? _getAccuracyColor(
                                      _currentPosition!.accuracy,
                                    )
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DIconButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }

  Widget _buildDataCapsule(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Fredoka',
              color: color.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Fredoka',
              color: color, // Darker shade for text readability
              fontSize: 16, // Adjusted for space
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
