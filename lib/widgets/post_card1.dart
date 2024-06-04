import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wip/models/user.dart' as model;
import 'package:wip/providers/user_provider.dart';
import 'package:wip/resources/firestore_methods.dart';
import 'package:wip/screens/comments_screen.dart';
import 'package:wip/widgets/like_animation.dart';

class PostCard1 extends StatefulWidget {
  final Map<String, dynamic> snap;
  final BorderRadius borderRadius;

  const PostCard1({Key? key, required this.snap, required this.borderRadius})
      : super(key: key);

  @override
  State<PostCard1> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard1> {
  late StreamSubscription<QuerySnapshot> _commentSubscription;
  bool isLiked = false;
  bool isLikeAnimating = false;
  int commentLen = 0;
  int shareCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
  }

  @override
  void dispose() {
    _commentSubscription.cancel();
    super.dispose();
  }

  Future<void> fetchCommentLen() async {
    try {
      _commentSubscription = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .snapshots()
          .listen((snapshot) {
        setState(() {
          commentLen = snapshot.docs.length;
        });
      });
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      await FireStoreMethods().likePost(postId, userId, widget.snap['likes']);
      setState(() {
        isLiked = true;
      });
    } catch (err) {
      print(err.toString());
    }
  }

  void sharePost() {
    setState(() {
      shareCount++;
    });
    print('Shared post: ${widget.snap['postId']}');
  }

  Future<void> deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Post deleted successfully'),
      ));
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User? user = Provider.of<UserProvider>(context).getUser;
    if (user == null) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: widget.borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.snap['profImage']),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.snap['username'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'delete') {
                        deletePost(widget.snap['postId']);
                      } else if (value == 'share') {
                        sharePost();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                      PopupMenuItem(
                        value: 'share',
                        child: Text('Share'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isLiked = !isLiked;
                  isLikeAnimating = true;
                });
                likePost(widget.snap['postId'], user.uid);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      image: DecorationImage(
                        image: NetworkImage(widget.snap['postUrl']),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: isLikeAnimating ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 400),
                    child: LikeAnimation(
                      isAnimating: isLikeAnimating,
                      duration: Duration(milliseconds: 600),
                      onEnd: () {
                        setState(() {
                          isLikeAnimating = false;
                        });
                      },
                      child: Icon(
                        Icons.favorite,
                        color: isLiked ? Colors.red : Colors.grey.shade700,
                        size: 50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.snap['likes'].length} likes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFb921c9),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.snap['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CommentsScreen(
                          postId: widget.snap['postId'],
                        ),
                      ));
                    },
                    child: Text(
                      'View all $commentLen comments',
                      style: TextStyle(
                        color: Color(0xFF3DFFA2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$shareCount shares',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        DateFormat.yMMMd().format(
                          widget.snap['datePublished'].toDate(),
                        ),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
