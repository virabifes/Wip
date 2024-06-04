import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:wip/models/post_event.dart'; // Importar o modelo de evento
import 'package:share/share.dart';
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
      )
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
              child: Image.network(imageUrls[index], fit: BoxFit.cover, width: 300),
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
          Text(event.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF3DFFA2))),
          const SizedBox(height: 8),
          Text(DateFormat('EEEE, MMMM d, y').format(event.date), style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 10),
          Text(event.description, style: TextStyle(fontSize: 16, color: Colors.white)),
          const SizedBox(height: 10),
          Text("Localização: ${event.location ?? 'Não especificado'}", style: TextStyle(fontSize: 16, color: Colors.white)),
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
        Text(event.isFree ? 'Grátis' : 'Preço: R\$${event.price.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16, color: event.isFree ? Colors.green : Colors.white)),
        Text('Máximo de inscrições: ${event.maxAttendees}', style: TextStyle(fontSize: 16, color: Colors.white)),
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
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('events').doc(eventId).collection('registrations').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}', style: TextStyle(color: Colors.red[300]));
        } else {
          return Text('Pessoas inscritas: ${snapshot.data?.docs.length ?? 0}', style: TextStyle(fontSize: 16, color: Colors.white));
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

    try {
      String registrationId = _generateRegistrationId();
      
      // Registrar o usuário para o evento
      await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .collection('registrations')
          .doc(registrationId)
          .set({
            'registrationId': registrationId,
            'timestamp': FieldValue.serverTimestamp(),
            'userId': user.uid, // Aqui armazenamos o UID do usuário
            'email': user.email,
            'eventId': event.id, // Adicionando o ID do evento
            'eventName': event.name, // Adicionando o nome do evento
            'eventDate': event.date, // Adicionando a data do evento
            'eventDescription': event.description, // Adicionando a descrição do evento
            'eventLocation': event.location, // Adicionando a localização do evento
            'eventPrice': event.price, // Adicionando o preço do evento
            'eventIsFree': event.isFree, // Adicionando se o evento é gratuito ou não
            'eventMaxAttendees': event.maxAttendees, // Adicionando o número máximo de inscrições do evento
            'eventImageUrls': event.imageUrls, // Adicionando os URLs das imagens do evento
          });

      // Adicionando o evento à lista de eventos registrados do usuário
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
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

 
  String _generateRegistrationId() {
    final Random random = Random();
    return random.nextInt(999999).toString().padLeft(6, '0');
  }
}
