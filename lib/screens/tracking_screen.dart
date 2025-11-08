import 'package:flutter/material.dart';
import '../services/location_service.dart';
import 'running_save_screen.dart';
import 'package:geolocator/geolocator.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final LocationService _locationService = LocationService();
  bool _isTracking = false;

  double _distance = 0.0;
  int _duration = 0;
  String _pace = "0'00\"";
  bool _hasPermission = false;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _locationService.stopTracking();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    setState(() => _isCheckingPermission = true);

    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() => _isCheckingPermission = false);
        _showLocationServiceDialog();
        return;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _hasPermission = false;
          _isCheckingPermission = false;
        });
        _showPermissionDeniedDialog();
        return;
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _hasPermission = false;
          _isCheckingPermission = false;
        });
        _showPermissionRequiredDialog();
        return;
      }

      // Permission granted
      setState(() {
        _hasPermission = true;
        _isCheckingPermission = false;
      });

    } catch (e) {
      setState(() {
        _hasPermission = false;
        _isCheckingPermission = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking permission: $e')),
        );
      }
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_off, color: Colors.red),
            SizedBox(width: 12),
            Text('Lokasi Tidak Aktif'),
          ],
        ),
        content: Text(
          'GPS/Lokasi device Anda tidak aktif. Silakan aktifkan GPS untuk melanjutkan tracking.',
          style: TextStyle(fontFamily: 'Outfit'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
              await Future.delayed(Duration(seconds: 1));
              _checkLocationPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
            ),
            child: Text('Buka Settings'),
          ),
        ],
      ),
    );
  }

  void _showPermissionRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.orange),
            SizedBox(width: 12),
            Text('Izin Lokasi Diperlukan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aplikasi memerlukan akses lokasi untuk:',
              style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            _buildPermissionItem('📍 Melacak jarak lari Anda'),
            _buildPermissionItem('⏱️ Menghitung pace secara akurat'),
            _buildPermissionItem('📊 Mencatat rute perjalanan'),
            SizedBox(height: 12),
            Text(
              'Lokasi Anda hanya digunakan saat tracking dan tidak disimpan ke server.',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _checkLocationPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
            ),
            child: Text('Berikan Izin'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.red),
            SizedBox(width: 12),
            Text('Izin Ditolak'),
          ],
        ),
        content: Text(
          'Izin lokasi ditolak secara permanen. Silakan buka Settings aplikasi untuk mengaktifkan izin lokasi secara manual.',
          style: TextStyle(fontFamily: 'Outfit'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
              await Future.delayed(Duration(seconds: 1));
              _checkLocationPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
            ),
            child: Text('Buka Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontFamily: 'Outfit', fontSize: 14),
      ),
    );
  }

  void _startTracking() async {
    if (!_hasPermission) {
      _checkLocationPermission();
      return;
    }

    try {
      await _locationService.startTracking((distance, duration, pace) {
        if (mounted) {
          setState(() {
            _distance = distance;
            _duration = duration;
            _pace = pace;
          });
        }
      });

      setState(() => _isTracking = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            action: SnackBarAction(
              label: 'Cek Izin',
              onPressed: _checkLocationPermission,
            ),
          ),
        );
      }
    }
  }

  void _pauseTracking() {
    _locationService.stopTracking();
    setState(() => _isTracking = false);
  }

  void _finishTracking() {
    _locationService.stopTracking();

    if (_distance == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jarak tidak boleh 0')),
      );
      return;
    }

    // Navigate to save screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RunningSaveScreen(
          distance: _distance,
          duration: _duration,
          pace: _pace,
          calories: _locationService.calculateCalories(_distance, _duration),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_isTracking) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Batalkan Tracking?'),
                  content: const Text('Data lari akan hilang jika dibatalkan'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tidak'),
                    ),
                    TextButton(
                      onPressed: () {
                        _locationService.reset();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Ya'),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (!_hasPermission && !_isCheckingPermission)
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.orange),
              tooltip: 'Cek Izin Lagi',
              onPressed: _checkLocationPermission,
            ),
        ],
      ),
      body: _isCheckingPermission
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Memeriksa izin lokasi...',
              style: TextStyle(fontFamily: 'Outfit'),
            ),
          ],
        ),
      )
          : !_hasPermission
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 24),
              Text(
                'Izin Lokasi Diperlukan',
                style: TextStyle(
                  fontFamily: 'FugazOne',
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Aplikasi memerlukan akses lokasi untuk melacak jarak dan pace lari Anda.',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _checkLocationPermission,
                icon: Icon(Icons.location_on),
                label: Text('Berikan Izin Lokasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _distance.toStringAsFixed(2),
                style: TextStyle(
                  fontFamily: 'FugazOne',
                  fontSize: 80,
                  fontStyle: FontStyle.italic,
                  height: 1,
                ),
              ),
              Text(
                'Jarak (Km)',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetric(_pace, 'Rata-rata\nPace'),
                  _buildMetric(_formatDuration(_duration), 'Durasi'),
                  _buildMetric(
                    '${_locationService.calculateCalories(_distance, _duration)} kcal',
                    'Kalori',
                  ),
                ],
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'jeda',
                    onPressed: _isTracking ? _pauseTracking : _startTracking,
                    backgroundColor: const Color(0xFF2196F3),
                    child: Icon(
                      _isTracking ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  if (_isTracking || _distance > 0) ...[
                    const SizedBox(width: 24),
                    TextButton(
                      onPressed: _finishTracking,
                      child: Text(
                        'SELESAI',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}