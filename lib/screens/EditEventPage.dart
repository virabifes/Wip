import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wip/models/post_event.dart'; // Assume este caminho como correto
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
  late TextEditingController _emailController; // New controller
  late TextEditingController _phoneController; // New controller
  late bool _isFree;
  late bool _isPublic; // New boolean
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event.name);
    _descriptionController = TextEditingController(text: widget.event.description);
    _locationController = TextEditingController(text: widget.event.location);
    _priceController = TextEditingController(text: widget.event.isFree ? '0' : widget.event.price.toString());
    _emailController = TextEditingController(text: widget.event.email ?? ''); // Initialize with event email
    _phoneController = TextEditingController(text: widget.event.phone ?? ''); // Initialize with event phone
    _isFree = widget.event.isFree;
    _isPublic = widget.event.isPublic; // Initialize with event isPublic
    _selectedDate = widget.event.date;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _emailController.dispose(); // Dispose controller
    _phoneController.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Evento'),
        backgroundColor: Color(0xFF310E3E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Evento',
                  labelStyle: TextStyle(color: Color(0xFF3DFFA2)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB921C9)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: TextStyle(fontSize: 18.0),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome para o evento.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              // Description field
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
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              // Location field
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
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              // Date picker
              Row(
                children: [
                  Text(
                    'Data do Evento:',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(width: 10.0),
                  TextButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _selectedDate = selectedDate;
                        });
                      }
                    },
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: TextStyle(fontSize: 18.0, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              // Email field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email de Contato',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB921C9)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              // Phone field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Número de Telefone',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB921C9)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              // Is Free switch
              SwitchListTile(
                title: Text('Evento Gratuito', style: TextStyle(fontSize: 18.0)),
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
                  style: TextStyle(fontSize: 18.0),
                ),
              SizedBox(height: 16.0),
              // Save button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveEvent();
                  }
                },
                child: Text('Guardare Alterações', style: TextStyle(fontSize: 18.0)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB921C9),
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
        date: _selectedDate,
        imageUrls: widget.event.imageUrls,
        maxAttendees: widget.event.maxAttendees,
        creatorId: widget.event.creatorId,
        creatorName: widget.event.creatorName,
        timestamp: DateTime.now(),
        email: _emailController.text, // New email field
        phone: _phoneController.text, // New phone field
        isPublic: _isPublic, // New isPublic field
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
