import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  String username;
  String bio;
  final List followers;
  final List following;

  User({
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following,
  });

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      photoUrl: snapshot["photoUrl"],
      bio: snapshot["bio"],
      followers: List.from(snapshot["followers"]),
      following: List.from(snapshot["following"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "followers": followers,
        "following": following,
      };

  Future<void> updatePassword(String newPassword, String oldPassword) async {
    try {
      await reauthenticateUser(email, oldPassword);
      await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
      print("Senha atualizada com sucesso");
    } catch (error) {
      print("Erro ao atualizar a senha: $error");
    }
  }

  Future<void> reauthenticateUser(String email, String password) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
      print("Re-autenticado com sucesso");
    } catch (error) {
      print("Erro ao re-autenticar: $error");
    }
  }

  Future<void> deleteAccount() async {
    try {
      await FirebaseFirestore.instance.collection('user').doc(uid).delete();
      // Adicione aqui lógica para deletar outros dados do usuário como posts, comentários, etc.
    } catch (error) {
      print("Erro ao deletar a conta: $error");
    }
  }
}
