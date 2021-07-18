import 'dart:convert';
import 'dart:developer';

import 'package:chat_app2/screens/test_screen.dart';
import 'package:chat_app2/widgets/messages.dart';
import 'package:chat_app2/widgets/new_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'auth_screen.dart';

class ChatScreen extends StatefulWidget {
  final String screenid = 'chatscreen';
  ChatScreen({required this.destination});
  final String destination;
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //create instance from firestore
  final _firestore = FirebaseFirestore.instance;
  final fbm = FirebaseMessaging.instance;

  String userName = '';
  String userImageUri = '';
  String email = '';

  void getUserDestinationData() async {
    final DocumentSnapshot user =
        await _firestore.collection('users').doc(widget.destination).get();
    setState(() {
      userName = user['username'];
      email = user['email'];
      userImageUri = user['profileImage'];
    });
  }

  final serverToken =
      'AAAAOXz9QiU:APA91bEPCvayWClsAPPiSwAZQTIdBcAHIk1wPQv77NVY639-SeODu-ZUl5YevlCo2QJ7O-kcQ9e0rNqdVTVQ259DEsQEOH4fcszyvWtizP5xmfrgn18T5RowuFLzluSMEyJjXh9JLIJA';
  void sendNotification(String message) async {
    //get id for the destination user to get the tokens by the id
    final user = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    // get user tokens to send notification to every device
    final userTokens = await _firestore
        .collection('tokens')
        .where('userId', isEqualTo: user.docs[0].id)
        .get();

    //send notification
    userTokens.docs.forEach((token) {
      // log(message);
      // log(token['devicesToken']);
      sender(message, token['devicesToken']);
    });
  }

  void sender(String msg, String token) async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': msg, 'title': userName},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'type': 'chat',
          },
          'to': token,
        },
      ),
    );
  }

  void sendMessage(message) {
    FirebaseFirestore.instance.collection('chats').add({
      'text': message,
      'createdAt': Timestamp.now(),
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'chatId': FirebaseAuth.instance.currentUser!.uid + widget.destination
    });
  }

  @override
  void initState() {
    getUserDestinationData();
    permissions();

    FirebaseMessaging.onMessage.listen((event) {
      log('******************onMessage*****************');
      log(event.notification!.body.toString());
    });

    // if tapped on the notification when the application is running in the background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TestScreen(),
      ));
    });

    // if tapped on the notification when the application is terminated
    initMessage();

    super.initState();
  }

  // if tapped on the notification when the application is terminated
  initMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();

    // var message = await FirebaseMessaging.instance.getInitialMessage();
    if (message?.data['type'] == 'chat') {
      Navigator.of(context).pushNamed(TestScreen().screenId);
    }
    log('message is Empty');
  }

  permissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  final auth = FirebaseAuth.instance;
  var myId;

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    setState(() {
      myId = auth.currentUser!.uid;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: null,
        builder: (context, streamSnapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    backgroundImage: userImageUri.isNotEmpty
                        ? NetworkImage(userImageUri)
                        : null,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(userName),
                ],
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Messages(widget.destination),
                ),
                NewMessage(sendNotification, sendMessage),
              ],
            ),
          );
        });
  }
}
