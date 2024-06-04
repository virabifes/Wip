import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:wip/models/user.dart';
import 'package:wip/providers/user_provider.dart';
import 'package:wip/resources/firestore_methods.dart';
import 'package:wip/utils/utils.dart';
import 'package:wip/widgets/comment_card.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController commentEditingController = TextEditingController();
  Color inputTextColor = Colors.black; // Cor inicial do texto de entrada

  void postComment(String uid, String name, String profilePic) async {
    try {
      String res = await FireStoreMethods().postComment(
        widget.postId,
        commentEditingController.text,
        uid,
        name,
        profilePic,
      );

      if (res == 'success') {
        commentEditingController.clear(); // Limpa apenas em caso de sucesso
        setState(() {
          inputTextColor = Colors.black; // Restaura a cor do texto de entrada para preto após a limpeza
        });
      } else {
        if (mounted) showSnackBar(context, res); // Verifica se o contexto está montado antes de exibir o snackbar
      }
    } catch (err) {
      if (mounted) showSnackBar(context, err.toString()); // Verifica se o contexto está montado antes de exibir o snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF310E3E), // Cor principal
        title: Text(
          'Comments',
          style: TextStyle(
            fontFamily: 'Arial', // Fonte das letras melhorada
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => CommentCard(snap: snapshot.data!.docs[index]),
          );
        },
      ),
      bottomNavigationBar: buildInputArea(user),
    );
  }

  Widget buildInputArea(User? user) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Cor de fundo branco
          borderRadius: BorderRadius.circular(30), // Bordas arredondadas
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user?.photoUrl ?? ''),
              radius: 18,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: commentEditingController,
                  decoration: InputDecoration(
                    hintText: 'Comment as ${user?.username ?? 'Guest'}',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: inputTextColor, // Cor dinâmica da dica de texto
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Arial', // Fonte melhorada
                    fontSize: 16,
                    color: inputTextColor, // Cor dinâmica do texto digitado
                  ),
                  onChanged: (value) {
                    setState(() {
                      inputTextColor = value.isEmpty ? Colors.black : Color(0xFF3DFFA2); // Altera a cor do texto dinamicamente
                    });
                  },
                  onSubmitted: (_) => postComment(user?.uid ?? '', user?.username ?? 'Guest', user?.photoUrl ?? ''),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => postComment(user?.uid ?? '', user?.username ?? 'Guest', user?.photoUrl ?? ''),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFB921C9), // Cor para o botão "Post"
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Post',
                    style: TextStyle(
                      color: Color(0xFF3DFFA2), // Cor do texto do botão "Post"
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
