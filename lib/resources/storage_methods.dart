import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Método para adicionar imagem ao Firebase Storage
  Future<String> uploadImageToStorage(String childName, Uint8List file, bool isPost) async {
    // Criando localização no Firebase Storage
    
    // Referência ao local no Storage com base no nome do filho e ID do usuário atual
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);
    
    // Se for um post, gerar um ID único para a imagem
    if(isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    // Colocando no formato Uint8List -> Upload task é como um Future mas não é exatamente um Future
    UploadTask uploadTask = ref.putData(
      file
    );

    // Aguardar a conclusão do upload e obter o URL de download da imagem
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
