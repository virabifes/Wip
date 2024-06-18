import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowerListScreen1 extends StatelessWidget {
  final String uid;

  const FollowerListScreen1({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Followers', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.purple,
        elevation: 2.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            var followers = snapshot.data!['followers'];
            return ListView.builder(
              itemCount: followers.length,
              itemBuilder: (context, index) {
                String followerId = followers[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(followerId).get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    var followerData = snapshot.data!.data() as Map<String, dynamic>;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1.0,
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(followerData['photoUrl']),
                          radius: 25,
                          backgroundColor: Colors.purple.shade100,
                        ),
                        title: Text(followerData['username'], style: TextStyle(color: Colors.purple)),
                      )  
                      );     
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }


}

class FollowingListScreen extends StatelessWidget {
  final String uid;

  const FollowingListScreen({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Following', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.purple,
        elevation: 2.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            var following = snapshot.data!['following'];
            return ListView.builder(
              itemCount: following.length,
              itemBuilder: (context, index) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(following[index]).get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    var followingData = snapshot.data!.data() as Map<String, dynamic>;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1.0,
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(followingData['photoUrl']),
                          radius: 25,
                          backgroundColor: Colors.purple.shade100,
                        ),
                        title: Text(followingData['username'], style: TextStyle(color: Colors.purple)),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.purple,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        color: Colors.purple,
      ),
    ),
    home: FollowerListScreen1(uid: 'user-id'),
  ));
}
