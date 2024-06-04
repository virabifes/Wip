import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wip/providers/user_provider.dart';
import 'package:wip/resources/firestore_methods.dart';
import 'package:wip/utils/colors.dart';
import 'package:wip/utils/utils.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _selectImage(BuildContext context) async {
    var source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {},
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar uma foto'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      try {
        Uint8List file = await pickImage(source);
        setState(() {
          _file = file;
        });
      } catch (e) {
        showSnackBar(context, "Falha ao selecionar imagem: ${e.toString()}");
      }
    }
  }

  Future<void> postImage(String? uid, String? username, String? profImage) async {
    if (uid == null || username == null || profImage == null) {
      showSnackBar(context, "Dados de usuário incompletos. Não é possível publicar.");
      return;
    }

    if (_file == null) {
      showSnackBar(context, "Por favor, selecione uma imagem primeiro.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
      );
      if (res == "success") {
        FirebaseFirestore.instance.collection('registrations').doc(uid).set({
          'timestamp': FieldValue.serverTimestamp(),
          'userId': uid,
        });
        showSnackBar(context, 'Post publicado com sucesso!');
        clearImage();
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      showSnackBar(context, err.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF310E3E),
        title: Text('Criar Postagem', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _file != null ? () => postImage(user?.uid, user?.username, user?.photoUrl) : null,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_file != null)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.memory(
                            _file!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Escreva uma Descrição...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Color(0xFF310E3E),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _selectImage(context),
                  icon: Icon(Icons.image),
                  label: Text('Selecionar Imagem'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB921C9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
