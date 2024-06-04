import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wip/models/post_event.dart'; // Assume this é o caminho correto

class EditEventPage extends StatefulWidget {
  final Event event;

  EditEventPage({required this.event});

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late bool _isFree;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event.name);
    _descriptionController = TextEditingController(text: widget.event.description);
    _locationController = TextEditingController(text: widget.event.location);
    _priceController = TextEditingController(text: widget.event.isFree ? '0' : widget.event.price.toString());
    _isFree = widget.event.isFree;
    _selectedDate = widget.event.date; // Inicializa com a data atual do evento
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Evento'),
        backgroundColor: Color(0xFF310E3E), // Cor de fundo da app bar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Evento',
                  labelStyle: TextStyle(color: Color(0xFF3DFFA2)), // Cor do texto do label
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB921C9)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: TextStyle(fontSize: 18.0), // Melhora a fonte
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome para o evento.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB921C9)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                maxLines: 3,
                style: TextStyle(fontSize: 18.0), // Melhora a fonte
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Local',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB921C9)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: TextStyle(fontSize: 18.0), // Melhora a fonte
              ),
              SizedBox(height: 16.0),
              SwitchListTile(
                title: Text('Evento Gratuito', style: TextStyle(fontSize: 18.0)), // Melhora a fonte
                value: _isFree,
                activeColor: Color(0xFFB921C9),
                onChanged: (bool value) {
                  setState(() {
                    _isFree = value;
                  });
                },
              ),
              if (!_isFree)
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Preço',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFB921C9)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18.0), // Melhora a fonte
                ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveEvent();
                  }
                },
                child: Text('Salvar Alterações', style: TextStyle(fontSize: 18.0)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB921C9), // Cor do botão
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveEvent() async {
    try {
      double price = _isFree ? 0 : double.parse(_priceController.text);
      Event updatedEvent = Event(
        id: widget.event.id,
        name: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        isFree: _isFree,
        price: price,
        date: _selectedDate, // Usa a data selecionada
        imageUrls: widget.event.imageUrls,
        maxAttendees: widget.event.maxAttendees,
        creatorId: widget.event.creatorId,
        creatorName: widget.event.creatorName,
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('events')
          .doc(updatedEvent.id)
          .set(updatedEvent.toMap(), SetOptions(merge: true));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar evento: $e')),
      );
    }
  }
}

