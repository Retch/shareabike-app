import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static final ValueNotifier<LatLng> location =
      ValueNotifier<LatLng>(const LatLng(52.984362, 13.038633));
  static final ValueNotifier<LatLng> mapCenter =
      ValueNotifier<LatLng>(const LatLng(52.984362, 13.038633));

  static getCurrentLocation() async {
    if (kDebugMode) {
      print("GETTING CURRENT LOCATION");
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    location.value = LatLng(position.latitude, position.longitude);
    mapCenter.value = LatLng(position.latitude, position.longitude);
  }

  static updateMapCenter() {
    if (kDebugMode) {
      print("UPDATING MAP CENTER");
    }
    mapCenter.value = location.value;
    mapCenter.notifyListeners();
  }

  static getCurrentLocationAndUpdateMapCenter() async {
    await getCurrentLocation();
    updateMapCenter();
  }
}
