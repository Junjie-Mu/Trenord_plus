import 'package:get/get.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:trenord/controllers/location_controller.dart';

class HomeController extends GetxController {
  final locationController = Get.find<LocationController>();
  final places = GoogleMapsPlaces(apiKey: '');
  final RxString currentLocation = 'Choose location...'.obs;
  final Rxn<String> selectedType = Rxn<String>();
  final RxList<PlacesSearchResult> nearbyPlaces = <PlacesSearchResult>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(locationController.currentLocation, (position) {
      if (position != null) {
        searchNearbyPlaces();
      }
    });
  }

  @override
  void onClose() {
    places.dispose();
    super.onClose();
  }

  void updateLocation(String location) {
    currentLocation.value = location;
  }

  void updateSelectedType(String? type) {
    selectedType.value = type;
    searchNearbyPlaces();
  }

  Future<void> searchNearbyPlaces() async {
    if (locationController.currentLocation.value == null) return;
    
    isLoading.value = true;

    try {
      // Location that user choose
      final location = locationController.currentLocation.value!;
      
      if (selectedType.value == null || selectedType.value == 'All') {
        // if type == All
        final responses = await Future.wait([
          places.searchNearbyWithRadius(
            Location(lat: location.latitude, lng: location.longitude),
            5000,
            type: 'tourist_attraction',
            language: 'it',
          ),
          places.searchNearbyWithRadius(
            Location(lat: location.latitude, lng: location.longitude),
            5000,
            type: 'restaurant',
            language: 'it',
          ),
          places.searchNearbyWithRadius(
            Location(lat: location.latitude, lng: location.longitude),
            5000,
            type: 'lodging',
            language: 'it',
          ),
          places.searchNearbyWithRadius(
            Location(lat: location.latitude, lng: location.longitude),
            5000,
            type: 'shopping_mall',
            language: 'it',
          ),
        ]);

        final allPlaces = <PlacesSearchResult>[];
        for (final response in responses) {
          if (response.status == 'OK') {
            final results = response.results.where((place) {
              final mainType = place.types.first;
              switch (mainType) {
                case 'tourist_attraction':
                case 'restaurant':
                case 'lodging':
                case 'shopping_mall':
                  return true;
                default:
                  return false;
              }
            }).toList();

            // Sort by rating
            results.sort((a, b) {
              final ratingA = a.rating ?? 0.0;
              final ratingB = b.rating ?? 0.0;
              return ratingB.compareTo(ratingA);
            });
            allPlaces.addAll(results);
          }
        }

        nearbyPlaces.value = allPlaces;
      } else {
        // Define type
        final response = await places.searchNearbyWithRadius(
          Location(lat: location.latitude, lng: location.longitude),
          5000,
          type: _getPlaceType(selectedType.value),
          language: 'it',
        );
        if (response.status == 'OK') {
          final results = response.results.where((place) {
            return place.types.first == _getPlaceType(selectedType.value);
          }).toList();
          results.sort((a, b) {
            final ratingA = a.rating ?? 0.0;
            final ratingB = b.rating ?? 0.0;
            return ratingB.compareTo(ratingA);
          });
          nearbyPlaces.value = results;
        }
      }
    } catch (e) {
      print('Search Failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // conv types
  String _getPlaceType(String? type) {
    switch (type) {
      case 'Attractions':
        return 'tourist_attraction';
      case 'Restaurant':
        return 'restaurant';
      case 'Lodging':
        return 'lodging';
      case 'Shopping':
        return 'shopping_mall';
      default:
        return 'Attractions';
    }
  }
} 