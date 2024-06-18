import 'package:cloud_firestore/cloud_firestore.dart';

class EventRegistration {
  final String id;
  final String eventId;
  final String userName;
  final String userEmail;
  final String userPhotoUrl;

  EventRegistration({
    required this.id,
    required this.eventId,
    required this.userName,
    required this.userEmail,
    required this.userPhotoUrl,
  });

  factory EventRegistration.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EventRegistration(
      id: doc.id,
      eventId: data['eventId'],
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
    );
  }
}
