import 'package:cloud_firestore/cloud_firestore.dart';

class Journey {
  final String id;
  final String userId;
  final String trainNumber;
  final String departureStation;
  final String arrivalStation;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final DateTime date;

  Journey({
    required this.id,
    required this.userId,
    required this.trainNumber,
    required this.departureStation,
    required this.arrivalStation,
    required this.departureTime,
    required this.arrivalTime,
    required this.date,
  });

  // Converting from Firestore documents to Journey objects
  factory Journey.fromFirestore(Map<String, dynamic> data, String id) {
    return Journey(
      id: id,
      userId: data['userId'] as String,
      trainNumber: data['trainNumber'] as String,
      departureStation: data['departureStation'] as String,
      arrivalStation: data['arrivalStation'] as String,
      departureTime: (data['departureTime'] as Timestamp).toDate(),
      arrivalTime: (data['arrivalTime'] as Timestamp).toDate(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore Document Data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'trainNumber': trainNumber,
      'departureStation': departureStation,
      'arrivalStation': arrivalStation,
      'departureTime': Timestamp.fromDate(departureTime),
      'arrivalTime': Timestamp.fromDate(arrivalTime),
      'date': Timestamp.fromDate(date),
    };
  }
} 