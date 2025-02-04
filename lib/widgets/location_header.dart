import 'package:flutter/material.dart';
import 'package:trenord/screens/location/location_screen.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trenord/controllers/home_controller.dart';

class LocationHeader extends StatefulWidget {
  const LocationHeader({super.key});

  @override
  State<LocationHeader> createState() => _LocationHeaderState();
}

class _LocationHeaderState extends State<LocationHeader> {
  final homeController = Get.find<HomeController>();

  void _navigateToLocationScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationScreen(),
      ),
    );

    if (result != null) {
      homeController.updateLocation(result['address'] as String);
      if (result['position'] != null) {
        homeController.locationController.updateLocation(result['position'] as Position);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: InkWell(
        onTap: _navigateToLocationScreen,
        child: Row(
          children: [
            const Icon(
              Icons.location_on,
              color: Color(0xFF1B8E3D),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Obx(() => Text(
                homeController.currentLocation.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              )),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
} 