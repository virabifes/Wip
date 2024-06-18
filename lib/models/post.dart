import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description; // Descrição do post
  final String uid; // ID do usuário que fez o post
  final String username; // Nome de usuário do autor do post
  final likes; // Número de curtidas do post
  final String postId; // ID do post
  final DateTime datePublished; // Data de publicação do post
  final String postUrl; // URL do post (por exemplo, se for uma imagem ou vídeo)
  final String profImage; // URL da imagem de perfil do autor do post

  const Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.likes,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
  });

  // Método estático para construir um objeto Post a partir de um DocumentSnapshot
  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      description: snapshot["description"],
      uid: snapshot["uid"],
      likes: snapshot["likes"],
      postId: snapshot["postId"],
      datePublished: snapshot["datePublished"].toDate(), // Convertendo para DateTime
      username: snapshot["username"],
      postUrl: snapshot['postUrl'],
      profImage: snapshot['profImage']
    );
  }

  // Método para converter o objeto Post em um formato JSON
  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "likes": likes,
        "username": username,
        "postId": postId,
        "datePublished": datePublished,
        'postUrl': postUrl,
        'profImage': profImage
      };
}
