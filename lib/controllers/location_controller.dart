import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class LocationController extends GetxController {
  final Rx<Position?> currentLocation = Rx<Position?>(null);

  void updateLocation(Position position) {
    currentLocation.value = position;
  }
} 