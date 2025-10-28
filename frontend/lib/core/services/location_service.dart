import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationService {
  static Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<String?> getCurrentCountryCode() async {
    try {
      final hasPermission = await _handlePermission();

      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final countryCode = placemarks.first.isoCountryCode;
        return countryCode;
      }
    } catch (e) {
      // If there's an error, return null and let the app handle the default case
      print('Error getting location: $e');
    }
    return null;
  }
}

// Provider for the current country code
final currentCountryProvider = FutureProvider<String?>((ref) async {
  return LocationService.getCurrentCountryCode();
});
