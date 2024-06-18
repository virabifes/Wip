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
  final String? location;
  final DateTime timestamp;
  final String? email; // Novo campo
  final String? phone; // Novo campo
  final bool isPublic; // Novo campo

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
    this.email, // Novo campo
    this.phone, // Novo campo
    required this.isPublic, // Novo campo
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      // Caso não haja dados, retorne um objeto Event com valores padrão
      return Event(
        id: doc.id,
        name: 'Unknown',
        description: '',
        date: DateTime.now(),
        isFree: false,
        price: 0,
        maxAttendees: 0,
        imageUrls: [],
        creatorId: '',
        creatorName: 'N/A',
        timestamp: DateTime.now(),
        isPublic: false, // Valor padrão
      );
    }

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
      date: parseDate(data['date'] ?? DateTime.now()),
      isFree: data['isFree'] ?? false,
      price: (data['price'] ?? 0).toDouble(),
      maxAttendees: data['maxAttendees'] ?? 0,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? 'N/A',
      location: data['location'],
      timestamp: parseDate(data['timestamp'] ?? DateTime.now()),
      email: data['email'],
      phone: data['phone'],
      isPublic: data['isPublic'] ?? false, // Novo campo
    );
  }

  String get title => name;

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
      'location': location ?? 'Not specified',
      'timestamp': Timestamp.fromDate(timestamp),
      'email': email, // Novo campo
      'phone': phone, // Novo campo
      'isPublic': isPublic, // Novo campo
    };
  }
}
