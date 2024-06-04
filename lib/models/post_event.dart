import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final bool isFree;
  final double price;
  final int maxAttendees;
  final List<String> imageUrls;
  final String creatorId;
  final String creatorName;
  final String? location; // Defined as optional
  final DateTime timestamp;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.isFree,
    required this.price,
    required this.maxAttendees,
    required this.imageUrls,
    required this.creatorId,
    required this.creatorName,
    this.location,
    required this.timestamp,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else {
        throw FormatException("Cannot parse date");
      }
    }

    return Event(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      description: data['description'] ?? '',
      date: parseDate(data['date']),
      isFree: data['isFree'] ?? false,
      price: (data['price'] ?? 0).toDouble(),
      maxAttendees: data['maxAttendees'] ?? 0,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? 'N/A',
      location: data['location'],
      timestamp: parseDate(data['timestamp']),
    );
  }

  String get title => name; // Corrected the getter to return the name instead of null

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'date': Timestamp.fromDate(date),
      'isFree': isFree,
      'price': price,
      'maxAttendees': maxAttendees,
      'imageUrls': imageUrls,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'location': location ?? 'Not specified', // Optional usage with a default value if null
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
