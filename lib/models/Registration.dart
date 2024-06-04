import 'package:cloud_firestore/cloud_firestore.dart';

class EventRegistration {
  final String id;
  final String eventId;
  final String eventName;
  final DateTime eventDate;
  final String eventDescription;
  final String eventLocation;
  final double eventPrice;
  final bool eventIsFree;
  final List<String> eventImageUrls;

  EventRegistration({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.eventDescription,
    required this.eventLocation,
    required this.eventPrice,
    required this.eventIsFree,
    required this.eventImageUrls,
  });

  factory EventRegistration.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EventRegistration(
      id: doc.id,
      eventId: data['eventId'],
      eventName: data['eventName'],
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      eventDescription: data['eventDescription'],
      eventLocation: data['eventLocation'] ?? 'Não especificado',
      eventPrice: (data['eventPrice'] ?? 0).toDouble(),
      eventIsFree: data['eventIsFree'],
      eventImageUrls: List<String>.from(data['eventImageUrls'] ?? []),
    );
  }
}
