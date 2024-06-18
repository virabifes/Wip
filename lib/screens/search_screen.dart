import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wip/screens/profile_screen1.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  bool isShowUsers = false;
  late Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (searchController.text.isNotEmpty) {
        setState(() {
          isShowUsers = true;
          _usersStream = FirebaseFirestore.instance
              .collection('users')
              .where('username', isGreaterThanOrEqualTo: searchController.text)
              .snapshots();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF310E3E),
        title: TextFormField(
          controller: searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Procure pelo users...',
            labelStyle: TextStyle(color: Colors.white),
            prefixIcon: Icon(Icons.search, color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ),
      body: isShowUsers ? _buildUserList() : _buildPlaceholderText(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Não encontrado usuários.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No users found.'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var user = snapshot.data!.docs[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildUserItem(user),
            );
          },
        );
      },
    );
  }

  Widget _buildUserItem(DocumentSnapshot user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user['photoUrl']),
        radius: 16,
      ),
      title: Text(
        user['username'],
        style: TextStyle(color: Color(0xFF3DFFA2)),
      ),
      trailing: _buildFollowButton(user),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileScreen(uid: user['uid']),
        ),
      ),
    );
  }

  Widget _buildFollowButton(DocumentSnapshot user) {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final isFollowing = (user['followers'] as List<dynamic>).contains(currentUserUid);

    return IconButton(
      icon: Icon(
        isFollowing ? Icons.person_remove : Icons.person_add,
        color: Colors.white,
      ),
      onPressed: () async {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user['uid']);
        final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUserUid);

        if (isFollowing) {
          await userRef.update({
            'followers': FieldValue.arrayRemove([currentUserUid]),
          });
          await currentUserRef.update({
            'following': FieldValue.arrayRemove([user['uid']]),
          });
        } else {
          await userRef.update({
            'followers': FieldValue.arrayUnion([currentUserUid]),
          });
          await currentUserRef.update({
            'following': FieldValue.arrayUnion([user['uid']]),
          });
        }
      },
    );
  }

  Widget _buildPlaceholderText() {
    return Center(child: Text('Digite um nome de usuário para pesquisar user.'));
  }
}
