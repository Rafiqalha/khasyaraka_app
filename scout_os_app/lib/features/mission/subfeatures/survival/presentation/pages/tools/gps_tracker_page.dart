import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_mastery_controller.dart';

class GpsTrackerPage extends StatefulWidget {
  const GpsTrackerPage({super.key});

  @override
  State<GpsTrackerPage> createState() => _GpsTrackerPageState();
}

class _GpsTrackerPageState extends State<GpsTrackerPage> {
  static const _background = Color(0xFFF5F5F5);
  static const _surface = Colors.white;
  static const _primaryGreen = Color(0xFF2E7D32);
  static const _gold = Color(0xFFFFD600);
  static const _riverBlue = Color(0xFF1565C0);
  static const _textDark = Color(0xFF1B5E20);
  static const _hudText = Colors.black87;
  static const _noiseThresholdMeters = 2.0;
  static const _markerAnimDuration = Duration(milliseconds: 700);

  final MapController _mapController = MapController();
  final Distance _distance = const Distance();

  StreamSubscription<Position>? _positionSubscription;
  bool _hasCentered = false;
  bool _isTracking = false;

  LatLng? _currentPosition;
  LatLng? _lastPosition;
  LatLng? _basecampPosition;
  final List<Marker> _customMarkers = [];
  int _shelterCount = 0;
  bool _isBacktracking = false;
  final List<LatLng> _polyLineCoordinates = [];

  double _heading = 0.0;
  double _speedKmh = 0.0;
  double _altitude = 0.0;
  double _distanceToBasecamp = 0.0;
  double _trackDistance = 0.0;
  double _pendingStepDistance = 0.0;
  double _rewardedDistanceMeters = 0.0;

  // Approximate step length in meters (adjustable)
  static const double _stepThresholdMeters = 0.7;

  @override
  void initState() {
    super.initState();
    _startLocationStream();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startLocationStream() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      _showPermissionDialog(
        message: 'Aktifkan layanan lokasi untuk menggunakan GPS Tracker.',
        openSettings: false,
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      if (!mounted) return;
      _showPermissionDialog(
        message: 'Izin lokasi dibutuhkan untuk GPS Tracker. Buka pengaturan?',
        openSettings: true,
      );
      return;
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(_onPositionUpdate);
  }

  void _onPositionUpdate(Position position) {
    final newPosition = LatLng(position.latitude, position.longitude);
    final previousPosition = _currentPosition ?? _lastPosition;
    final delta = previousPosition == null
        ? double.infinity
        : _distance.as(LengthUnit.Meter, previousPosition, newPosition);

    _speedKmh = position.speed * 3.6;
    _heading = _resolveHeading(
      position.heading,
      previousPosition,
      newPosition,
      _speedKmh,
    );
    _speedKmh = position.speed * 3.6;
    _altitude = position.altitude;

    if (delta < _noiseThresholdMeters) {
      setState(() {});
      return;
    }

    _currentPosition = newPosition;

    if (_isBacktracking) {
      _handleBacktrackErase(newPosition);
    } else if (_isTracking) {
      final lastPoint = _polyLineCoordinates.isNotEmpty
          ? _polyLineCoordinates.last
          : newPosition;
      final delta = _distance.as(LengthUnit.Meter, lastPoint, newPosition);
      if (delta > 0.0) {
        _pendingStepDistance += delta;
      }

      // Only draw path if user has "stepped" enough distance
      if (_pendingStepDistance >= _stepThresholdMeters) {
        _trackDistance += _pendingStepDistance;
        _pendingStepDistance = 0.0;
        _polyLineCoordinates.add(newPosition);
      } else if (_polyLineCoordinates.isEmpty) {
        _polyLineCoordinates.add(newPosition);
      }
    }

    if (_basecampPosition != null) {
      _distanceToBasecamp = _distance.as(
        LengthUnit.Meter,
        _basecampPosition!,
        newPosition,
      );
    }

    if (!_hasCentered) {
      _hasCentered = true;
      _mapController.move(newPosition, 17);
    }

    _lastPosition = newPosition;
    setState(() {});
  }

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      setState(() {
        _isTracking = false;
      });
      await _rewardTrackingDistance();
      return;
    }

    setState(() {
      _isTracking = true;
      _isBacktracking = false;
      if (_currentPosition != null) {
        _polyLineCoordinates.add(_currentPosition!);
        _pendingStepDistance = 0.0;
      }
    });
  }

  Future<void> _rewardTrackingDistance() async {
    final deltaDistance = _trackDistance - _rewardedDistanceMeters;
    if (deltaDistance <= 0) return;

    final controller = context.read<SurvivalMasteryController>();
    final response = await controller.recordAction(
      toolType: 'gps_tracker',
      xpGained: 0,
      metadata: {
        'distance_meters': deltaDistance,
        'altitude_gain_meters': 0.0,
        'max_altitude': _altitude,
      },
    );

    _rewardedDistanceMeters = _trackDistance;

    if (!mounted || response == null) return;

    final km = (deltaDistance / 1000).toStringAsFixed(2);
    final xp = response.xpGained;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Misi Selesai'),
        content: Text('Jarak: $km km\nXP Didapatkan: +$xp'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _setBasecamp() {
    if (_currentPosition == null) return;
    setState(() {
      _basecampPosition = _currentPosition;
      _distanceToBasecamp = 0.0;
      _customMarkers.removeWhere((marker) => marker.key == const ValueKey('basecamp'));
      _customMarkers.add(
        Marker(
          key: const ValueKey('basecamp'),
          point: _currentPosition!,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.flag,
            color: _gold,
            size: 32,
          ),
        ),
      );
    });
  }

  void _markShelter() {
    if (_currentPosition == null) return;
    setState(() {
      _shelterCount += 1;
      final label = 'Pos $_shelterCount';
      _customMarkers.add(
        Marker(
          key: ValueKey('shelter_$_shelterCount'),
          point: _currentPosition!,
          width: 70,
          height: 50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.home_outlined,
                color: _primaryGreen,
                size: 26,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _primaryGreen, width: 1),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: _primaryGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _toggleBacktrack() {
    if (_polyLineCoordinates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rute kosong. Tidak ada jejak untuk backtrack.')),
      );
      return;
    }
    setState(() {
      _isBacktracking = !_isBacktracking;
      if (_isBacktracking) {
        _isTracking = false;
      }
    });
  }

  void _handleBacktrackErase(LatLng current) {
    if (_polyLineCoordinates.isEmpty) return;
    final lastPoint = _polyLineCoordinates.last;
    final dist = _distance.as(LengthUnit.Meter, current, lastPoint);
    if (dist <= 15.0) {
      setState(() {
        _polyLineCoordinates.removeLast();
      });
      HapticFeedback.lightImpact();
      if (_polyLineCoordinates.isEmpty) {
        _isBacktracking = false;
        _showRouteClearedDialog();
      }
    }
  }

  Future<void> _showRouteClearedDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Basecamp'),
        content: const Text('Welcome back to Basecamp! Route cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _recenter() {
    if (_currentPosition == null) return;
    _mapController.move(_currentPosition!, 17);
  }

  Future<void> _showPermissionDialog({
    required String message,
    required bool openSettings,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GPS Permission'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          if (openSettings)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text('Buka Pengaturan'),
            ),
        ],
      ),
    );
  }

  String _formatCoord(LatLng? coord) {
    if (coord == null) return '-';
    return '${coord.latitude.toStringAsFixed(5)}, ${coord.longitude.toStringAsFixed(5)}';
  }

  double _resolveHeading(
    double sensorHeading,
    LatLng? previous,
    LatLng current,
    double speedKmh,
  ) {
    if (sensorHeading.isNaN || sensorHeading < 0 || speedKmh < 0.5) {
      if (previous == null) return _heading;
      final bearing = _calculateBearing(previous, current);
      return bearing.isNaN ? _heading : bearing;
    }
    return sensorHeading;
  }

  double _calculateBearing(LatLng from, LatLng to) {
    final lat1 = _degToRad(from.latitude);
    final lat2 = _degToRad(to.latitude);
    final dLon = _degToRad(to.longitude - from.longitude);
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final bearing = math.atan2(y, x);
    return (_radToDeg(bearing) + 360) % 360;
  }

  double _degToRad(double deg) => deg * (math.pi / 180);

  double _radToDeg(double rad) => rad * (180 / math.pi);

  @override
  Widget build(BuildContext context) {
    final customMarkers = _customMarkers;
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? const LatLng(-7.2575, 112.7521),
              initialZoom: 15,
              backgroundColor: _background,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.scout_os_app',
              ),
              if (_polyLineCoordinates.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polyLineCoordinates,
                      strokeWidth: 4,
                      color: _riverBlue,
                    ),
                  ],
                ),
              if (_currentPosition != null)
                SmoothLocationMarker(
                  position: _currentPosition!,
                  fallbackHeading: _heading,
                  headingStream: FlutterCompass.events,
                  duration: _markerAnimDuration,
                ),
              if (customMarkers.isNotEmpty)
                MarkerLayer(markers: customMarkers),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            top: topInset + 12,
            child: _buildTopStatusBar(),
          ),
          Positioned(
            right: 16,
            top: topInset + 90,
            child: Column(
              children: [
                _mapFab(
                  icon: Icons.my_location,
                  onTap: _recenter,
                ),
                const SizedBox(height: 12),
                _mapFab(
                  icon: Icons.flag,
                  onTap: _setBasecamp,
                ),
                const SizedBox(height: 12),
                _mapFab(
                  icon: Icons.home_outlined,
                  onTap: _markShelter,
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatusBar() {
    final status = _currentPosition == null
        ? 'Mencari GPS...'
        : _basecampPosition == null
            ? 'GPS Siap • Belum set Basecamp'
            : 'Jarak ke Basecamp: ${_distanceToBasecamp.toStringAsFixed(1)} m';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.satellite_alt, color: _primaryGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              status,
              style: GoogleFonts.poppins(
                color: _textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapFab({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: _surface,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: _textDark, size: 22),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    final speed = _speedKmh.toStringAsFixed(1);
    final altitude = _altitude.toStringAsFixed(1);
    final distance = _trackDistance.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isTracking ? const Color(0xFFD32F2F) : _primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                    elevation: 6,
                  ),
                  onPressed: _toggleTracking,
                  child: Text(_isTracking ? 'STOP' : 'START'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _riverBlue,
                  side: BorderSide(
                    color: _riverBlue.withValues(
                      alpha: _polyLineCoordinates.isEmpty ? 0.4 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  shape: const StadiumBorder(),
                ),
                onPressed:
                    _polyLineCoordinates.isEmpty ? null : _toggleBacktrack,
                child: Text(_isBacktracking ? 'BACKTRACK OFF' : 'BACKTRACK'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statTile('Speed', '$speed km/h'),
              _statTile('Altitude', '$altitude m'),
              _statTile('Distance', '$distance m'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _hudText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class SmoothLocationMarker extends StatefulWidget {
  const SmoothLocationMarker({
    super.key,
    required this.position,
    required this.fallbackHeading,
    this.headingStream,
    this.duration = const Duration(milliseconds: 700),
  });

  final LatLng position;
  final double fallbackHeading;
  final Stream<CompassEvent>? headingStream;
  final Duration duration;

  @override
  State<SmoothLocationMarker> createState() => _SmoothLocationMarkerState();
}

class _SmoothLocationMarkerState extends State<SmoothLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<LatLng> _positionAnimation;
  LatLng _animatedPosition = const LatLng(0, 0);

  StreamSubscription<CompassEvent>? _headingSub;
  double _heading = 0.0;

  @override
  void initState() {
    super.initState();
    _animatedPosition = widget.position;
    _heading = widget.fallbackHeading;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _positionAnimation = LatLngTween(
      begin: widget.position,
      end: widget.position,
    ).animate(_controller)
      ..addListener(() {
        setState(() {
          _animatedPosition = _positionAnimation.value;
        });
      });
    _controller.forward();

    if (widget.headingStream != null) {
      _headingSub = widget.headingStream!.listen((event) {
        final value = event.heading;
        if (value == null) return;
        setState(() {
          _heading = value;
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant SmoothLocationMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position) {
      _controller.reset();
      _positionAnimation = LatLngTween(
        begin: _animatedPosition,
        end: widget.position,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward();
    }
    if (_headingSub == null && widget.headingStream != null) {
      _headingSub = widget.headingStream!.listen((event) {
        final value = event.heading;
        if (value == null) return;
        setState(() {
          _heading = value;
        });
      });
    }
  }

  @override
  void dispose() {
    _headingSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heading = _heading.isNaN || _heading < 0
        ? widget.fallbackHeading
        : _heading;
    final turns = (heading % 360) / 360.0;

    return MarkerLayer(
      markers: [
        Marker(
          point: _animatedPosition,
          width: 40,
          height: 40,
          child: AnimatedRotation(
            turns: turns,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.navigation,
                color: Color(0xFF2E7D32),
                size: 26,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end})
      : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    return LatLng(
      begin!.latitude + (end!.latitude - begin!.latitude) * t,
      begin!.longitude + (end!.longitude - begin!.longitude) * t,
    );
  }
}
