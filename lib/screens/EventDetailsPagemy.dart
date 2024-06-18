import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wip/models/post_event.dart';
import 'package:wip/screens/EditEventPage.dart';

// Cores personalizadas
const Color primaryColor = Color(0xFF310E3E); // Roxo escuro
const Color backgroundColor = Colors.white; // Fundo branco
const Color accentColor = Color(0xFFB921C9); // Rosa forte
const Color eventNameColor = Color(0xFF3DFFA2); // Verde neon

class EventDetailsPage extends StatefulWidget {
  final Event event;

  EventDetailsPage({required this.event});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late Event event;
  List<EventRegistration> eventRegistrations = [];

  @override
  void initState() {
    super.initState();
    event = widget.event;
    _loadEventRegistrations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(event.name, style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEventPage(event: event),
                ),
              ).then((_) {
                setState(() {});  // Reload data to reflect any changes
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: deleteEvent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: eventNameColor),
            ),
            SizedBox(height: 10),
            Text(
              'Data: ${event.date.toString()}',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text(
              'Descrição: ${event.description}',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text(
              'Localização: ${event.location ?? 'Not specified'}',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text(
              'Preço: ${event.isFree ? 'Free' : ' ${event.price.toStringAsFixed(2)}'}',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${event.email}',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text(
              'Telefone: ${event.phone}',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 20),
            Text(
              'Imagens:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: event.imageUrls.length,
                itemBuilder: (context, index) {
                  final imageUrl = event.imageUrls[index];
                  if (imageUrl.isEmpty) {
                    return Container(
                      width: 200,
                      color: Colors.grey,
                      child: Icon(Icons.broken_image, color: Colors.white),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return Container(
                            color: Colors.grey,
                            width: 200,
                            child: Icon(Icons.broken_image, color: Colors.white),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Registados:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: eventRegistrations.length,
                  itemBuilder: (context, index) {
                    EventRegistration registration = eventRegistrations[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(registration.userPhotoUrl),
                        onBackgroundImageError: (error, stackTrace) {
                          print('Error loading user photo: $error');
                        },
                      ),
                      title: Text(registration.userName),
                      subtitle: Text(registration.userEmail),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Número de Pessoas Registradas: ${eventRegistrations.length}',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _loadEventRegistrations() async {
    EventRegistrationService _eventRegistrationService = EventRegistrationService();
    try {
      List<EventRegistration> registrations = await _eventRegistrationService.fetchEventRegistrations(event.id);
      setState(() {
        eventRegistrations = registrations;
      });
    } catch (e) {
      print('Error loading event registrations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar registros do evento: $e')),
      );
    }
  }

  void deleteEvent() async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .delete();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar evento: $e')),
      );
    }
  }
}

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

class EventRegistrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<EventRegistration>> fetchEventRegistrations(String eventId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('registrations')
          .get();
      return querySnapshot.docs
          .map((doc) => EventRegistration.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching event registrations: $e');
      throw e;
    }
  }
}
