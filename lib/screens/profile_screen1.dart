import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wip/screens/FollowerListScreen1.dart';
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
  bool isFollowing = false;

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
          .where('uid', isEqualTo: widget.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()! as Map<String, dynamic>;
      followers = userData['followers'].length;
      following = userData['following'].length;

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
          IconButton(
            icon: Icon(isFollowing ? Icons.person_remove : Icons.person_add),
            onPressed: () async {
              setState(() {
                isFollowing = !isFollowing;
                if (isFollowing) {
                  followers++;
                } else {
                  followers--;
                }
              });

              if (isFollowing) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.uid)
                    .update({'followers': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])});

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({'following': FieldValue.arrayUnion([widget.uid])});
              } else {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.uid)
                    .update({'followers': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])});

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
                FutureBuilder<QuerySnapshot>(
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
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    final data = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: data.docs.length,
                      itemBuilder: (context, index) {
                        final snap = data.docs[index].data() as Map<String, dynamic>;
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
        builder: (context) => FollowerListScreen1(uid: widget.uid),
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
