import 'package:cloud_firestore/cloud_firestore.dart';


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

  Future<void> updateUsername(String newUsername) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'username': newUsername});
      username = newUsername;
    } catch (error) {
      // Handle the error if any
      print("Error updating username: $error");
    }
  }

  Future<void> updateBio(String newBio) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'bio': newBio});
      bio = newBio;
    } catch (error) {
      // Handle the error if any
      print("Error updating bio: $error");
    }
  }

  Future<void> updatePassword(String newPassword) async {
    // Logic to update password
  }

  Future<void> deleteAccount() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      // Add here logic to delete other user data like posts, comments, etc.
    } catch (error) {
      // Handle the error if any
      print("Error deleting account: $error");
    }
  }
}
