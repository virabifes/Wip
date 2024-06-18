import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wip/models/user.dart' as model;
import 'package:wip/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Verificar se o nome de usuário já está em uso
  Future<bool> isUsernameTaken(String username) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.isNotEmpty;
  }

  // Obter detalhes do usuário
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  // Registrar usuário
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Ocorreu algum erro";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        // Verificar se o nome de usuário já está em uso
        bool usernameExists = await isUsernameTaken(username);
        if (usernameExists) {
          return 'Nome de usuário já está em uso';
        }

        // Registrar usuário no Firebase Auth
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Fazer upload da imagem e obter a URL da imagem
        String photoUrl = await StorageMethods().uploadImageToStorage('profilePics', file, false);

        // Criar objeto User
        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          email: email,
          bio: bio,
          followers: [],
          following: [],
        );

        // Adicionar usuário ao Firestore
        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(user.toJson());

        res = "success";
      } else {
        res = "Por favor, preencha todos os campos";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // Método para login do usuário
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Ocorreu algum erro";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // Login do usuário com email e senha
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Por favor, preencha todos os campos";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // Método para logout do usuário
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
