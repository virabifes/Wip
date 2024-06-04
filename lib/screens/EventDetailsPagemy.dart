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

  @override
  void initState() {
    super.initState();
    event = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              'Date: ${event.date.toString()}',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text(
              'Description: ${event.description}',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text(
              'Location: ${event.location ?? 'Not specified'}',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text(
              'Price: ${event.isFree ? 'Free' : 'R\$ ${event.price.toStringAsFixed(2)}'}',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 20),
            Text(
              'Images:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: event.imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        event.imageUrls[index],
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Adicionar lógica para adicionar o evento aos favoritos
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Event added to favorites')),
          );
        },
        backgroundColor: accentColor,
        child: Icon(Icons.favorite, color: Colors.white),
      ),
    );
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
        SnackBar(content: Text('Error deleting event: $e')),
      );
    }
  }
}

