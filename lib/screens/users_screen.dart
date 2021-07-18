import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'chat_screen.dart';

class UsersScreen extends StatefulWidget {
  final String screenid = 'usersScreen';
  const UsersScreen({Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                // get the device token to push notifications
                final deviceToken = await FirebaseMessaging.instance.getToken();
                final tokenId = await _firestore
                    .collection('tokens')
                    .where('devicesToken', isEqualTo: deviceToken.toString())
                    .get();

                // to delete the token
                await _firestore
                    .collection('tokens')
                    .doc(tokenId.docs[0].id)
                    .delete();
                // to sign out
                _auth.signOut();
              }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            StreamBuilder<dynamic>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Color(0xff125589),
                    ),
                  );
                }
                final users = snapshot.data.docs;
                List<MessageBubble> userWidgets = [];
                for (var user in users) {
                  final username = user.id;
                  if (_auth.currentUser!.email != user.id) {
                    final messageWidget = MessageBubble(
                      user: username,
                      userName: user['username'],
                      userImage: user['profileImage'],
                    );
                    userWidgets.add(messageWidget);
                  }
                }
                return Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    children: userWidgets,
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  // final _auth = FirebaseAuth.instance;
  MessageBubble({required this.user, this.userName, this.userImage});
  final String user;
  final userName;
  final userImage;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Material(
              borderRadius: BorderRadius.circular(50),
              color: Color(0xff125589),
              elevation: 5,
              child: FlatButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return ChatScreen(
                          destination: user,
                        );
                      }),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        backgroundImage: userImage.isNotEmpty
                            ? NetworkImage(userImage)
                            : null,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
