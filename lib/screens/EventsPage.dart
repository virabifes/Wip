import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wip/screens/EventDetailsScreen.dart';
import 'package:provider/provider.dart';
import 'package:wip/providers/user_provider.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({Key? key}) : super(key: key);

  @override
  _EventsListScreenState createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _filterController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _filterController.addListener(() {
      setState(() {
        _searchText = _filterController.text;
      });
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> deletePastEvents() async {
    DateTime now = DateTime.now();

    QuerySnapshot querySnapshot = await _firestore.collection('events')
      .where('date', isLessThan: Timestamp.fromDate(now.subtract(Duration(days: 1))))
      .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
      print("Evento com id ${doc.id} foi apagado.");
    }

    print("Todos os eventos passados foram apagados.");
  }

  Widget _buildEventList() {
    final user = Provider.of<UserProvider>(context).getUser;

    return Padding(
      padding: EdgeInsets.all(8.0), // Adicionando margem ao redor da lista de eventos
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('events').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> publicEvents = [];
          List<DocumentSnapshot> privateEvents = [];

          for (var doc in snapshot.data!.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            bool isPrivate = data['isPrivate'] ?? false;
            if (isPrivate) {
              List<dynamic> allowedUsers = data['allowedUsers'] ?? [];
              if (allowedUsers.contains(user?.username)) {
                privateEvents.add(doc);
              }
            } else {
              publicEvents.add(doc);
            }
          }

          List<DocumentSnapshot> filteredDocs = _searchText.isEmpty
              ? privateEvents + publicEvents
              : (privateEvents + publicEvents).where((doc) {
                  Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                  String name = data['name'].toLowerCase();
                  return name.contains(_searchText.toLowerCase());
                }).toList();

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = filteredDocs[index];
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Ajustando o espaçamento entre os cartões
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(eventId: document.id),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.black, width: 1),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Color.fromARGB(255, 157, 33, 201),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  data['imageUrls'] != null && data['imageUrls'].isNotEmpty
                                      ? data['imageUrls'][0]
                                      : 'placeholder_image_url',
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'] ?? 'No Name',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    data['description'] ?? 'No Description',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white), // Adicionando espaço entre o ícone e o campo de texto
          SizedBox(width: 8), // Adicionando espaço entre o ícone e o campo de texto
          Expanded(
            child: TextField(
              controller: _filterController,
              decoration: InputDecoration(
                labelText: 'Procurar',
                hintText: 'Entre com um nome',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                hintStyle: TextStyle(color: Color.fromRGBO(73, 0, 99, 1)),
              ),
              style: TextStyle(color: Color.fromRGBO(73, 0, 99, 1)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos criados', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              await deletePastEvents();
              setState(() {}); // Atualiza a tela
            },
          ),
        ],
        backgroundColor: Color.fromARGB(255, 157, 33, 201),
      ),
      body: Container(
        color: Color.fromARGB(255, 157, 33, 201),
        child: Column(
          children: <Widget>[
            _buildSearchBar(),
            Expanded(child: _buildEventList()),
          ],
        ),
      ),
    );
  }
}
