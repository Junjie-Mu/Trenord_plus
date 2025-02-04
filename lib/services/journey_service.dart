import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trenord/models/journey.dart';

class JourneyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add ticket
  Future<void> addJourney(Journey journey) async {
    try {
      await _firestore.collection('journeys').add(journey.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  // Get all tickets (including expired ones for the "My Tickets").
  Stream<List<Journey>> getAllUserJourneys(String userId) {
    try {
      return _firestore
          .collection('journeys')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final journeys = snapshot.docs
            .map((doc) => Journey.fromFirestore(doc.data(), doc.id))
            .toList()
          ..sort((a, b) => a.departureTime.compareTo(b.departureTime));
        return journeys;
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get user's unused tickets.
  Stream<List<Journey>> getFutureJourneys(String userId) {
    try {
      return _firestore
          .collection('journeys')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final now = DateTime.now();
        final journeys = snapshot.docs
            .map((doc) => Journey.fromFirestore(doc.data(), doc.id))
            // after now
            .where((journey) => journey.departureTime.isAfter(now))
            .toList()
          ..sort((a, b) => a.departureTime.compareTo(b.departureTime));
        return journeys;
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get user newest ticket
  Stream<Journey?> getLatestJourney(String userId) {
    try {
      return _firestore
          .collection('journeys')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        
        final now = DateTime.now();
        final journeys = snapshot.docs
            .map((doc) => Journey.fromFirestore(doc.data(), doc.id))
            .where((journey) => journey.departureTime.isAfter(now))
            .toList()
          ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

        return journeys.isEmpty ? null : journeys.first;
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete ticket
  Future<void> deleteJourney(String journeyId) async {
    try {
      await _firestore.collection('journeys').doc(journeyId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Update ticket
  // Future<void> updateJourney(String journeyId, Journey journey) async {
  //   try {
  //     await _firestore
  //         .collection('journeys')
  //         .doc(journeyId)
  //         .update(journey.toFirestore());
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
} 