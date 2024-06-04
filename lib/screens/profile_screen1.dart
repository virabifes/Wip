import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wip/screens/FollowerListScreen.dart';
import 'package:wip/utils/colors.dart';
import 'package:wip/utils/utils.dart';
import 'package:wip/widgets/post_card.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isLoading = false;
  bool isFollowing = false; // Definindo isFollowing como uma variável de estado

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      final postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()! as Map<String, dynamic>;
      followers = userData['followers'].length;
      following = userData['following'].length;

      // Defina isFollowing com base nos dados do usuário
      final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      setState(() {
        isFollowing = userData['followers'].contains(currentUserUid);
      });
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        elevation: 0,
        actions: [
          // Botão de seguir/deixar de seguir
          IconButton(
            icon: Icon(isFollowing ? Icons.person_remove : Icons.person_add),
            onPressed: () async {
              setState(() {
                isFollowing = !isFollowing; // Alternar o estado de seguir/não seguir
                if (isFollowing) {
                  followers++; // Incrementar o número de seguidores se começarmos a seguir
                } else {
                  followers--; // Decrementar o número de seguidores se pararmos de seguir
                }
              });

              // Lógica para adicionar/remover o usuário da lista de seguidores
              if (isFollowing) {
                // Adicionar o usuário à lista de seguidores
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.uid)
                    .update({'followers': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])});

                // Atualizar o número de seguidores no perfil do usuário atual
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({'following': FieldValue.arrayUnion([widget.uid])});
              } else {
                // Remover o usuário da lista de seguidores
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.uid)
                    .update({'followers': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])});

                // Atualizar o número de seguidores no perfil do usuário atual
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({'following': FieldValue.arrayRemove([widget.uid])});
              }
            },
            color: Color.fromRGBO(51, 1, 58, 1),
          ),
        ],
      ),
       body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                        userData['photoUrl'] ?? '',
                      ),
                      radius: 40,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['username'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            userData['bio'] ?? '',
                            style: TextStyle(
                              color: const Color.fromRGBO(51, 1, 58, 1),
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildStatColumn(postLen, "posts"),
                              buildClickableStatColumn(followers, "followers"),
                              buildClickableStatColumn(following, "following"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                      itemBuilder: (context, index) {
                        final snap = (snapshot.data! as QuerySnapshot).docs[index].data() as Map<String, dynamic>;
                        return PostCard(
                          snap: snap,
                          borderRadius: BorderRadius.circular(15),
                        );
                      },
                    );
                  },
                )
              ],
            ),
    );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          num.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Color.fromRGBO(51, 1, 58, 1),
          ),
        ),
      ],
    );
  }

  GestureDetector buildClickableStatColumn(int num, String label) {
    return GestureDetector(
      onTap: () {
        if (label == "followers") {
          navigateToFollowerList();
        } else if (label == "following") {
          navigateToFollowingList();
        }
      },
      child: buildStatColumn(num, label),
    );
  }

  void navigateToFollowerList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowerListScreen(uid: widget.uid),
      ),
    );
  }

  void navigateToFollowingList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowingListScreen(uid: widget.uid),
      ),
    );
  }
}
