import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wip/models/post_event.dart'; // Certifique-se de importar o modelo Event, se necessário
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name ?? 'Nome do Evento Indisponível',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3DFFA2)),
            ),
            SizedBox(height: 16),
            Text(
              event.description ?? 'Descrição do Evento Indisponível',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Data: ${event.date ?? 'Data Indisponível'}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Local: ${event.location ?? 'Local Indisponível'}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 16),
            _buildImageGallery(event.imageUrls ?? [], context), // Adicionando a galeria de imagens
            // Adicione mais informações do evento conforme necessário
          ],
        ),
      ),
    );
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
            var data = snapshot.data?.data() as Map<String, dynamic>; // Definindo o tipo do mapa
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
                        return SizedBox(); // Pode ser substituído por um indicador de carregamento
                      } else if (eventSnapshot.hasError) {
                        return Text('Erro: ${eventSnapshot.error}', style: TextStyle(color: Colors.white));
                      } else {
                        var event = Event.fromFirestore(eventSnapshot.data!); // Supondo que Event.fromFirestore é um método que converte um DocumentSnapshot em um objeto Event
                        return Card(
                          color: Color(0xFFB921C9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text(event.name ?? 'Nome do Evento Indisponível', style: TextStyle(color: Color(0xFF3DFFA2))),
                            subtitle: Text(
                              event.description ?? 'Descrição Indisponível',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailsScreen(event: event),
                                ),
                              );
                            },
                            onLongPress: () {
                              _cancelRegistration(context, event.id); // Chamando a função de cancelamento de inscrição
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