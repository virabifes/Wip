import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wip/screens/comments_screen.dart';
import 'package:wip/widgets/like_animation.dart';
import 'package:wip/resources/firestore_methods.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Map<String, dynamic> _post;
  bool _isLiked = false;
  bool _isLikeAnimating = false;
  int _commentLen = 0;

  Future<void> _likePost(String userId) async {
    try {
      if (!_isLiked) {
        await FireStoreMethods().likePost(widget.postId, userId, _post['likes']);
        setState(() {
          _isLiked = true;
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  void _sharePost() {
    // Implement your share functionality here
    print('Shared post: ${widget.postId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Detail'),
      ),
      body: _post != null
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(_post['profImage']),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _post['username'],
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
                              // Delete post
                            } else if (value == 'share') {
                              _sharePost();
                            } else if (value == 'save') {
                              // Save post
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
                            PopupMenuItem(
                              value: 'save',
                              child: Text('Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Image and Like Animation
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLiked = !_isLiked;
                        _isLikeAnimating = true;
                      });
                      _likePost(_post['userId']);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            image: DecorationImage(
                              image: NetworkImage(_post['postUrl']),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(20),
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: _isLikeAnimating ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 400),
                          child: LikeAnimation(
                            isAnimating: _isLikeAnimating,
                            duration: Duration(milliseconds: 600),
                            onEnd: () {
                              setState(() {
                                _isLikeAnimating = false;
                              });
                            },
                            child: Icon(
                              Icons.favorite,
                              color: _isLiked ? Colors.red : Colors.grey.shade700,
                              size: 50,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Post Details
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_post['likes'].length} likes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFb921c9),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _post['description'],
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
                                postId: widget.postId,
                              ),
                            ));
                          },
                          child: Text(
                            'View all $_commentLen comments',
                            style: TextStyle(
                              color: Color(0xFF3DFFA2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          DateFormat.yMMMd().format(
                            _post['datePublished'].toDate(),
                          ),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
