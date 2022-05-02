import 'package:geolocator/geolocator.dart';

class LocationHelper {
  Future<Position> detectCurrentLocation() async {
    isLocationServiceEnabled();
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  isLocationServiceEnabled() async {
    bool _isServicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_isServicesEnabled) {
      await Geolocator.requestPermission();
    }
  }
}
