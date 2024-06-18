import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wip/models/post_event.dart';
import 'package:wip/screens/EventDetailsPagemy.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  EventDetailsScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Evento', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF310e3e),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Data: ${event.date.toString()}',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Descrição: ${event.description}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Localização: ${event.location ?? 'Not specified'}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Preço: ${event.isFree ? 'Free' : ' ${event.price.toStringAsFixed(2)}'}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${event.email}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Telefone: ${event.phone}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 10),
            FutureBuilder<EventRegistration>(
              future: _fetchEventRegistration(event.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar número do bilhete', style: TextStyle(color: Colors.red));
                } else {
                  return Text(
                    'Número do bilhete: ${snapshot.data!.id}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            _buildImageGallery(event.imageUrls ?? [], context),
          ],
        ),
      ),
    );
  }

  Future<EventRegistration> _fetchEventRegistration(String eventId) async {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot registrationDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .doc(user!.uid)
        .get();

    return EventRegistration.fromFirestore(registrationDoc);
  }
}

class RegisteredEventsScreen extends StatelessWidget {
  Future<void> _cancelRegistration(BuildContext context, String eventId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para cancelar a inscrição.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('registrations')
          .doc(user.uid)
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'registeredEvents': FieldValue.arrayRemove([eventId]),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscrição cancelada com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao cancelar a inscrição: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos Registrados', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF310e3e),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          } else {
            var data = snapshot.data?.data() as Map<String, dynamic>;
            List<String>? registeredEvents = List<String>.from(data['registeredEvents'] ?? []);
            if (registeredEvents.isEmpty) {
              return Center(child: Text('Você não está registrado em nenhum evento.', style: TextStyle(color: Colors.white)));
            } else {
              return ListView.builder(
                itemCount: registeredEvents.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('events').doc(registeredEvents[index]).get(),
                    builder: (context, eventSnapshot) {
                      if (eventSnapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox();
                      } else if (eventSnapshot.hasError) {
                        return Text('Erro: ${eventSnapshot.error}', style: TextStyle(color: Colors.white));
                      } else {
                        var event = Event.fromFirestore(eventSnapshot.data!);
                        return Card(
                          margin: EdgeInsets.all(10.0),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text(
                              event.name ?? 'Nome do Evento Indisponível',
                              style: TextStyle(color: Color(0xFF3DFFA2)),
                            ),
                            subtitle: Text(
                              event.description ?? 'Descrição Indisponível',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: Icon(Icons.arrow_forward, color: Color(0xFF3DFFA2)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailsScreen(event: event),
                                ),
                              );
                            },
                            onLongPress: () {
                              _cancelRegistration(context, event.id);
                            },
                          ),
                        );
                      }
                    },
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}

Widget _buildImageGallery(List<String> imageUrls, BuildContext context) {
  return SizedBox(
    height: 250,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrls[index], fit: BoxFit.cover, width: 300),
          ),
        );
      },
    ),
  );
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

