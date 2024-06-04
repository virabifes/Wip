import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wip/models/post_event.dart';
import 'package:wip/screens/EventDetailsPagemy.dart';
import 'package:wip/screens/RegisteredEventsPage.dart';

class MyEventsPage extends StatefulWidget {
  final String currentUserId;

  MyEventsPage({required this.currentUserId});

  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Pesquisar eventos...',
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Color(0xFF310E3E),
          hintStyle: TextStyle(color: Colors.white70),
        ),
        style: TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            _searchTerm = value.toLowerCase();
          });
        },
      ),
    );
  }

  Stream<QuerySnapshot> _eventStream() {
    return FirebaseFirestore.instance
        .collection('events')
        .where('creatorId', isEqualTo: widget.currentUserId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB921C9),
        title: Text(
          'Meus Eventos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisteredEventsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: StreamBuilder(
                stream: _eventStream(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final events = snapshot.data!.docs.map((doc) => Event.fromFirestore(doc)).where((event) {
                    return event.name.toLowerCase().contains(_searchTerm);
                  }).toList();

                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      Event event = events[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailsPage(event: event),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          margin: EdgeInsets.all(8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            title: Text(event.name, style: TextStyle(color: Color(0xFF3DFFA2), fontWeight: FontWeight.bold)),
                            subtitle: Text('${event.date} - ${event.location}', style: TextStyle(color: Color(0xFF3DFFA2))),
                            leading: CircleAvatar(
                              backgroundColor: Color(0xFFB921C9),
                              child: Icon(Icons.event, color: Colors.white),
                            ),
                            trailing: Icon(Icons.arrow_forward, color: Color(0xFF3DFFA2)),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
