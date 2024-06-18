import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:wip/models/post.dart';
import 'package:wip/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para postar um post
  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage) async {
    String res = "Algum erro ocorreu";
    try {
      // Faz upload da imagem para o Firebase Storage e obtém o URL da foto
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      // Cria um ID único para o post baseado no tempo
      String postId = const Uuid().v1();
      // Cria um objeto Post
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
      );
      // Adiciona o post ao Firestore
      await _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "sucesso";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Método para curtir um post
  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Algum erro ocorreu";
    try {
      if (likes.contains(uid)) {
        // Se a lista de curtidas contém o uid do usuário, remove o uid da lista
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // Caso contrário, adiciona o uid à lista de curtidas
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'sucesso';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Método para postar comentários
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = "Algum erro ocorreu";
    try {
      if (text.isNotEmpty) {
        // Se o texto não estiver vazio, cria um ID único para o comentário
        String commentId = const Uuid().v1();
        // Adiciona o comentário ao Firestore
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'sucesso';
      } else {
        res = "Por favor, insira um texto";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Método para apagar um post
  Future<String> deletePost(String postId) async {
    String res = "Algum erro ocorreu";
    try {
      // Apaga o post do Firestore
      await _firestore.collection('posts').doc(postId).delete();
      res = 'sucesso';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Método para seguir/deixar de seguir um usuário
  Future<void> followUser(String uid, String followId) async {
    try {
      // Obtém o documento do usuário atual
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      // Obtém a lista de seguindo do usuário
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        // Se a lista de seguindo contém o followId, remove o followId dos seguidores e do seguindo
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        // Caso contrário, adiciona o followId aos seguidores e ao seguindo
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }
}

