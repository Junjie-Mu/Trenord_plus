import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:trenord/controllers/location_controller.dart';
import 'package:trenord/controllers/home_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trenord/utils/ui_utils.dart';
class NearbyPlacesList extends StatefulWidget {
  const NearbyPlacesList({super.key});

  @override
  State<NearbyPlacesList> createState() => _NearbyPlacesListState();
}

class _NearbyPlacesListState extends State<NearbyPlacesList> {
  final homeController = Get.find<HomeController>();
  final List<String> _types = ['All', 'Attractions', 'Restaurant', 'Lodging', 'Shopping'];

  // Open Google Maps
  Future<void> _openInGoogleMaps(PlacesSearchResult place) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${place.name}&query_place_id=${place.placeId}'
    );
    
    try {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Navigation Failed';
      }
    } catch (e) {
      UIUtils.showError('Error', 'Navigation Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Type label
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _types.length,
            itemBuilder: (context, index) {
              final type = _types[index];
              return Obx(() {
                final isSelected = type == homeController.selectedType.value || 
                    (type == 'All' && homeController.selectedType.value == null);
                
                return Padding(
                  padding: EdgeInsets.only(
                    right: 8,
                    left: index == 0 ? 0 : 0,
                  ),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(type),
                    onSelected: (selected) {
                      homeController.updateSelectedType(
                        selected ? (type == 'All' ? null : type) : null
                      );
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF1B8E3D).withOpacity(0.1),
                    checkmarkColor: const Color(0xFF1B8E3D),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF1B8E3D) : Colors.grey[700],
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF1B8E3D) : Colors.grey[300]!,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                );
              });
            },
          ),
        ),
        // loading style
        const SizedBox(height: 16),
        Obx(() {
          if (homeController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1B8E3D),
              ),
            );
          }
          // default style
          if (homeController.nearbyPlaces.isEmpty) {
            return Center(
              child: Text(
                'Please choose location...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            );
          }
          // Render place lists
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: homeController.nearbyPlaces.length,
            itemBuilder: (context, index) {
              final place = homeController.nearbyPlaces[index];
              // Click to open MAP
              return InkWell(
                onTap: () => _openInGoogleMaps(place),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (place.photos?.isNotEmpty ?? false)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: AspectRatio(
                            aspectRatio: 2,
                            child: Image.network(
                              'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${place.photos!.first.photoReference}&key=',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                    size: 48,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B8E3D).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getDisplayType(place.types.first),
                                    style: const TextStyle(
                                      color: Color(0xFF1B8E3D),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (place.rating != null) ...[
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.yellow[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    place.rating.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              place.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (place.vicinity != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                place.vicinity!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  String _getDisplayType(String type) {
    switch (type) {
      case 'tourist_attraction':
        return 'Attractions';
      case 'restaurant':
        return 'Restaurant';
      case 'lodging':
        return 'Lodging';
      case 'shopping_mall':
        return 'Shopping';
      default:
        return type;
    }
  }
} 