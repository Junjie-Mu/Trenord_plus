import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trenord/controllers/journey_controller.dart';
import 'package:trenord/models/journey.dart';
import 'package:trenord/widgets/trenord_app_bar.dart';
import 'package:intl/intl.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journeyController = Get.find<JourneyController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F7),
      appBar: const TrenordAppBar(
        showBackButton: true,
        title: 'My tickets',
      ),
      body: Obx(() {
        final journeys = journeyController.userJourneys;

        if (journeys.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No ticket',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: journeys.length,
          itemBuilder: (context, index) {
            final journey = journeys[index];
            final isPast = journey.departureTime.isBefore(DateTime.now());
            // Swipe to delete
            return Dismissible(
              key: Key(journey.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                journeyController.deleteJourney(journey.id);
              },
              background: Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.red,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                  ),
                ),
              ),
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Container(
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
                              color: isPast
                                  ? Colors.grey[200]
                                  : const Color(0xFF1B8E3D).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              journey.trainNumber,
                              style: TextStyle(
                                color: isPast
                                    ? Colors.grey[600]
                                    : const Color(0xFF1B8E3D),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('dd/MM/yyyy').format(journey.date),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('HH:mm').format(journey.departureTime),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  journey.departureStation,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.grey[400],
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('HH:mm').format(journey.arrivalTime),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  journey.arrivalStation,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // For used tickets
                      if (isPast)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Used',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
} 