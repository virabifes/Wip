import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:wip/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({Key? key}) : super(key: key);

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  bool isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _maxAttendeesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _allowedUsersController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Novo campo
  final TextEditingController _phoneController = TextEditingController(); // Novo campo
  final List<XFile> _selectedImages = [];
  bool _isFree = true;
  bool _isPrivate = false;

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<List<String>> uploadEventImages(String eventId, List<XFile> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      String filePath = 'events/$eventId/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      File file = File(image.path);
      try {
        final ref = FirebaseStorage.instance.ref().child(filePath);
        final result = await ref.putFile(file);
        final imageUrl = await result.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
    return imageUrls;
  }

  void createEvent() async {
    final user = Provider.of<UserProvider>(context, listen: false).getUser;
    if (user == null) {
      showSnackBar(context, "User not logged in");
      return;
    }

    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _locationController.text.isEmpty ||
        (_isFree == false && _priceController.text.isEmpty)) {
      showSnackBar(context, "Please fill in all fields");
      return;
    }

    setState(() {
      isLoading = true;
    });

    CollectionReference events = FirebaseFirestore.instance.collection('events');

    try {
      DocumentReference eventRef = await events.add({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'date': _dateController.text,
        'location': _locationController.text,
        'maxAttendees': int.parse(_maxAttendeesController.text),
        'price': _isFree ? 0 : double.parse(_priceController.text),
        'isFree': _isFree,
        'isPrivate': _isPrivate,
        'allowedUsers': _isPrivate ? _allowedUsersController.text.split(',') : null,
        'creatorId': user.uid,
        'creatorName': user.username,
        'timestamp': FieldValue.serverTimestamp(),
        'email': _emailController.text, // Novo campo
        'phone': _phoneController.text, // Novo campo
      });

      if (_selectedImages.isNotEmpty) {
        List<String> imageUrls = await uploadEventImages(eventRef.id, _selectedImages);
        await eventRef.update({'imageUrls': imageUrls});
      }

      showSnackBar(context, 'Evento Criado');
    } catch (err) {
      showSnackBar(context, err.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _selectedImages.add(pickedImage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Evento', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF310E3E),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nome do Evento'),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Descrição do Evento'),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _dateController,
                        decoration: const InputDecoration(labelText: 'Data do Evento'),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _maxAttendeesController,
                        decoration: const InputDecoration(labelText: 'Máximo de Participantes'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16.0),
                      SwitchListTile(
                        title: const Text('Gratuito'),
                        value: _isFree,
                        onChanged: (bool value) {
                          setState(() {
                            _isFree = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Evento Privado'),
                        value: _isPrivate,
                        onChanged: (bool value) {
                          setState(() {
                            _isPrivate = value;
                          });
                        },
                      ),
                      if (!_isFree)
                        TextField(
                          controller: _priceController,
                          decoration: const InputDecoration(labelText: 'Preço'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      if (_isPrivate)
                        TextField(
                          controller: _allowedUsersController,
                          decoration: const InputDecoration(labelText: 'Nomes de usuários permitidos a visualizar (separados por vírgula)'),
                        ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(labelText: 'Localização do Evento'),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email de Contato'),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Número de Telefone'),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: createEvent,
                        child: const Text("Criar Evento"),
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Imagens de Capa do Evento:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.photo),
                            onPressed: () => _pickImage(ImageSource.gallery),
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () => _pickImage(ImageSource.camera),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      _selectedImages.isNotEmpty
                          ? Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _selectedImages.map((image) {
                                return Stack(
                                  children: [
                                    Image.file(
                                      File(image.path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _selectedImages.remove(image);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _maxAttendeesController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _allowedUsersController.dispose();
    _emailController.dispose(); // Novo campo
    _phoneController.dispose(); // Novo campo
    super.dispose();
  }
}
