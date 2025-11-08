import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math';

class LocationService {
  StreamSubscription<Position>? _positionStream;
  Position? _lastPosition;
  double _totalDistance = 0.0;
  int _elapsedSeconds = 0;
  Timer? _timer;

  double get totalDistance => _totalDistance;
  int get elapsedSeconds => _elapsedSeconds;
  
  String get formattedDistance => _totalDistance.toStringAsFixed(2);
  
  String get formattedDuration {
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final seconds = _elapsedSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  String get pace {
    if (_totalDistance == 0) return "0'00\"";
    
    final paceSeconds = (_elapsedSeconds / _totalDistance);
    final minutes = paceSeconds ~/ 60;
    final seconds = (paceSeconds % 60).round();
    
    return "$minutes'${seconds.toString().padLeft(2, '0')}\"";
  }

  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    // Check for location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable in settings.');
    }

    return true;
  }

  Future<void> startTracking(Function(double, int, String) onUpdate) async {
    // Check permission first
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      throw Exception('Location permission not granted');
    }

    // Reset values
    _totalDistance = 0.0;
    _elapsedSeconds = 0;
    _lastPosition = null;

    // Start timer for duration
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      onUpdate(_totalDistance, _elapsedSeconds, pace);
    });

    // Configure location settings for better accuracy
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
    );

    // Start listening to position changes
    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        if (_lastPosition != null) {
          final distance = _calculateDistance(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          
          // Only add distance if movement is significant (more than 1 meter)
          // This helps filter out GPS drift when stationary
          if (distance > 0.001) {
            _totalDistance += distance;
            onUpdate(_totalDistance, _elapsedSeconds, pace);
          }
        }
        _lastPosition = position;
      },
      onError: (error) {
        print('Location error: $error');
      },
    );
  }

  void stopTracking() {
    _timer?.cancel();
    _positionStream?.cancel();
    _positionStream = null;
    _timer = null;
  }

  void reset() {
    stopTracking();
    _totalDistance = 0.0;
    _elapsedSeconds = 0;
    _lastPosition = null;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of Earth in kilometers
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  int calculateCalories(double distanceKm, int durationSeconds) {
    // Simple estimation: ~60 calories per km for running
    return (distanceKm * 60).round();
  }
  
  // Get current position once (for testing or initial location)
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) return null;
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }
}