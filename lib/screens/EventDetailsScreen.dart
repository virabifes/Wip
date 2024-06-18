import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class EventDetailsScreen extends StatelessWidget {
  final String eventId;

  const EventDetailsScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Evento'),
        backgroundColor: const Color(0xFF310e3e),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('events').doc(eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Erro: ${snapshot.error}", style: TextStyle(color: Colors.red[300]));
          } else if (snapshot.data == null) {
            return const Center(child: Text("Nenhum dado disponível"));
          }

          Event event = Event.fromFirestore(snapshot.data!);
          if (event.date.isBefore(DateTime.now())) {
            return const Center(child: Text("Este evento já aconteceu."));
          }
          return SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  _buildImageGallery(event.imageUrls, context),
                  const SizedBox(height: 20),
                  _buildEventDetailsCard(event, context),
                ],
              ),
            ),
          );
        },
      ),
    );
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
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                width: 300,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    width: 300,
                    child: Icon(Icons.broken_image, color: Colors.white),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventDetailsCard(Event event, BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF310e3e),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3DFFA2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, MMMM d, y').format(event.date),
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            event.description,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            "Localização: ${event.location ?? 'Não especificado'}",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            "Email: ${event.email ?? 'Não especificado'}",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            "Telefone: ${event.phone ?? 'Não especificado'}",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 10),
          _buildPriceAndAttendance(event),
          const SizedBox(height: 20),
          _buildRegisterButton(event, context),
          const SizedBox(height: 10),
          _buildAttendeesCount(context, event.id),
          const SizedBox(height: 20),
          _buildCancelButton(context, event.id),
        ],
      ),
    );
  }

  Widget _buildPriceAndAttendance(Event event) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          event.isFree ? 'Grátis' : 'Preço: ${event.price.toStringAsFixed(2)} ',
          style: TextStyle(
            fontSize: 16,
            color: event.isFree ? Colors.green : Colors.white,
          ),
        ),
        Text(
          'Máximo de inscrições: ${event.maxAttendees}',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(Event event, BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: () => _registerForEvent(context, event),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFb921c9),
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          shadowColor: Colors.black,
          elevation: 5,
        ),
        icon: Icon(Icons.event_available, size: 24),
        label: Text('Registrar', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, String eventId) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20),
      child: ElevatedButton.icon(
        onPressed: () => _cancelRegistration(context, eventId),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          shadowColor: Colors.black,
          elevation: 5,
        ),
        icon: Icon(Icons.cancel, size: 24),
        label: Text('Cancelar Inscrição', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildAttendeesCount(BuildContext context, String eventId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').doc(eventId).collection('registrations').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}', style: TextStyle(color: Colors.red[300]));
        } else {
          return Text(
            'Pessoas inscritas: ${snapshot.data?.docs.length ?? 0}',
            style: TextStyle(fontSize: 16, color: Colors.white),
          );
        }
      },
    );
  }

  Future<void> _registerForEvent(BuildContext context, Event event) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para se registrar.')),
      );
      return;
    }

    // Verificar se a data do evento já passou
    if (event.date.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não é possível registrar para um evento que já passou.')),
      );
      return;
    }

    try {
      // Verificar se o usuário já está registrado para o evento
      DocumentSnapshot registrationSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .collection('registrations')
          .doc(user.uid)
          .get();

      if (registrationSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Você já está registrado para este evento.')),
        );
        return;
      }

      // Recuperar informações adicionais do usuário
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      var userData = userSnapshot.data() as Map<String, dynamic>;

      String registrationId = _generateRegistrationId();

      // Registrar o usuário para o evento
      await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .collection('registrations')
          .doc(user.uid)
          .set({
        'registrationId': registrationId,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'username': userData['username'],
        'email': user.email,
        'photoUrl': userData['photoUrl'],
        'eventId': event.id,
        'eventName': event.name,
        'eventDate': event.date,
        'eventDescription': event.description,
        'eventLocation': event.location,
        'eventPrice': event.price,
        'eventIsFree': event.isFree,
        'eventMaxAttendees': event.maxAttendees,
        'eventImageUrls': event.imageUrls,
      });

      // Adicionando o evento à lista de eventos registrados do usuário
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'registeredEvents': FieldValue.arrayUnion([event.id]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro bem-sucedido!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao registrar: $e')),
      );
    }
  }

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

      // Remover o evento cancelado da lista de eventos inscritos do usuário
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
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

  String _generateRegistrationId() {
    final Random random = Random();
    return random.nextInt(999999).toString().padLeft(6, '0');
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
      email: data['email'], // Novo campo
      phone: data['phone'], // Novo campo
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
    };
  }
}
