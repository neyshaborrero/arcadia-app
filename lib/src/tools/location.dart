import 'package:arcadia_mobile/src/structure/location.dart';
import 'package:geolocator/geolocator.dart';

Future<AppLocation?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled, handle accordingly
    return null;
  }

  // Check for location permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      //return 'Location permissions are denied';
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print('Location permissions are permanently denied');
    return null;
  }

  // If permissions are granted, get the current location
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  print('Location: ${position.latitude}, ${position.longitude}');
  return AppLocation(
      latitude: position.latitude, longitude: position.longitude);
}
