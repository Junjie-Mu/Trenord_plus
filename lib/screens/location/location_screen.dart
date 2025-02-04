import 'package:flutter/material.dart';
import 'package:trenord/widgets/trenord_app_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:get/get.dart';
import 'package:trenord/controllers/location_controller.dart';
import 'package:google_maps_webservice/places.dart' as gmw;
import 'package:trenord/utils/ui_utils.dart';
import 'package:trenord/controllers/tts_controller.dart';
import 'package:flutter/rendering.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> with RouteAware {
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentAddress;
  final TextEditingController _searchController = TextEditingController();
  final locationController = Get.find<LocationController>();
  final ttsController = Get.find<TtsController>();
  final places = gmw.GoogleMapsPlaces(apiKey: kGoogleApiKey);
  final RouteObserver<PageRoute> routeObserver = Get.find<RouteObserver<PageRoute>>();

  // Google Places API Key
  static const String kGoogleApiKey = '';

  // Common Locations
  final List<Map<String, dynamic>> _commonLocations = [
    {
      'name': 'Milano',
      'region': 'Lombardia',
      'latitude': 45.4642,
      'longitude': 9.1900,
    },
    {
      'name': 'Como',
      'region': 'Lombardia',
      'latitude': 45.8080,
      'longitude': 9.0851,
    },
    {
      'name': 'Bergamo',
      'region': 'Lombardia',
      'latitude': 45.6983,
      'longitude': 9.6773,
    },
    {
      'name': 'Brescia',
      'region': 'Lombardia',
      'latitude': 45.5416,
      'longitude': 10.2118,
    },
    {
      'name': 'Monza',
      'region': 'Lombardia',
      'latitude': 45.5845,
      'longitude': 9.2744,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakWelcomeMessage();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    places.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _speakWelcomeMessage() {
    if (!ttsController.isTtsEnabled.value) return;
    ttsController.speak('Welcome to Location Selection. You can search for a location, choose from common places, or use your current location.');
  }

  // Search box
  void _handlePlaceSelect(Prediction prediction) async {
    if (prediction.description != null) {
      try {
        final details = await places.getDetailsByPlaceId(prediction.placeId!);
        if (details.result.geometry?.location != null) {
          final position = Position(
            latitude: details.result.geometry!.location.lat,
            longitude: details.result.geometry!.location.lng,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );

          if (mounted) {
            if (ttsController.isTtsEnabled.value) {
              ttsController.speak('Selected location: ${prediction.description}');
            }
            Get.back(result: {
              'address': prediction.description!,
              'position': position,
            });
          }
        }
      } catch (e) {
        print('Error getting place details: $e');
        if (mounted) {
          UIUtils.showError('Error', 'Failed to get location details');
        }
      }
    }
  }

  // When click common location
  void _handleLocationSelect(String name, String region) {
    final location = _commonLocations.firstWhere(
      (loc) => loc['name'] == name && loc['region'] == region,
    );
    
    final address = '$name, $region';
    final position = Position(
      latitude: location['latitude'],
      longitude: location['longitude'],
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

    if (ttsController.isTtsEnabled.value) {
      ttsController.speak('Selected location: $name in $region');
    }
    
    Get.back(result: {
      'address': address,
      'position': position,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TrenordAppBar(
        showBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Box
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF1B8E3D), width: 2),
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: GooglePlaceAutoCompleteTextField(
                textEditingController: _searchController,
                googleAPIKey: kGoogleApiKey,
                boxDecoration: const BoxDecoration(
                  border: Border.fromBorderSide(BorderSide.none),
                ),
                inputDecoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: Color(0xFF1B8E3D),
                    size: 24,
                  ),
                  hintText: 'Address, city, station...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  fillColor: Colors.white,
                  filled: true,
                ),
                debounceTime: 800, // Set a delay time to avoid frequent requests
                countries: const ['IT'], // Limit search to Italy
                isLatLngRequired: true,
                getPlaceDetailWithLatLng: (Prediction prediction) {
                  _handlePlaceSelect(prediction);
                },
                itemClick: (Prediction prediction) {
                  _handlePlaceSelect(prediction);
                },
                seperatedBuilder: const Divider(
                  height: 1,
                ),
                itemBuilder: (context, index, Prediction prediction) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF1B8E3D),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prediction.description ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                isCrossBtnShown: true,
              ),
            ),
          ),
          // Get current location
          InkWell(
            onTap: _getCurrentLocation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B8E3D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.near_me,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My current location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 12,
                            ),
                          )
                        else if (_currentAddress != null)
                          Text(
                            _currentAddress!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Common Locations',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // List
          Expanded(
            child: ListView.builder(
              itemCount: _commonLocations.length,
              itemBuilder: (context, index) {
                final location = _commonLocations[index];
                return InkWell(
                  onTap: () => _handleLocationSelect(
                    location['name']!,
                    location['region']!,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFF1B8E3D),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location['name']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                location['region']!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    if (ttsController.isTtsEnabled.value) {
      ttsController.speak('Getting your current location');
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if location services are enabled.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Please enable location service';
          _isLoading = false;
        });
        return;
      }

      // Check APP location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Please grant the app location permission';
            _isLoading = false;
          });
          return;
        }
      }

      // If the permission is permanent rejected
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Please grant location permission for the app in settings';
          _isLoading = false;
        });
        return;
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition();
      
      // Convert latitude and longitude to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.locality ?? ''}, ${place.country ?? ''}';
        
        setState(() {
          _currentAddress = address;
          _isLoading = false;
          _errorMessage = null;
        });

        if (mounted) {
          if (ttsController.isTtsEnabled.value) {
            ttsController.speak('Current location set to: $address');
          }
          Get.back(result: {
            'address': address,
            'position': position,
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to obtain current location.';
        _isLoading = false;
      });
    }
  }
} 