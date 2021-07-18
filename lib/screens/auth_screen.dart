// import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../widgets/auth_form.dart';

class AuthScreen extends StatefulWidget {
  final String screenid = 'authscreen';
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  bool isLoading = false;

  void submitFn(
    dynamic authData,
    bool isLogin,
    BuildContext ctx,
  ) async {
    setState(() {
      isLoading = true;
    });
    try {
      if (isLogin) {
        final String email = authData['email'];
        final String password = authData['password'];

        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final deviceToken = await FirebaseMessaging.instance.getToken();
        await _firebaseFirestore.collection('tokens').add({
          'userId': auth.currentUser!.uid,
          'devicesToken': deviceToken,
        });
        setState(() {
          isLoading = false;
        });
      } else {
        // log(authData['email']);
        await auth.createUserWithEmailAndPassword(
          email: authData['email'],
          password: authData['password'],
        );

        // -------- START ---------- uploading user image profile to the firebase storage
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child(auth.currentUser!.uid + '.jpg');

        await ref
            .putFile(authData['imageFile'])
            .whenComplete(() => log('completed'));

        final imageURL = await ref.getDownloadURL();
        // -------- END ---------- uploading user image profile to the firebase storage

        final user = auth.currentUser;
        final uId = user!.uid;

        await _firebaseFirestore.collection('users').doc(uId).set({
          'username': authData['username'],
          'email': authData['email'],
          'profileImage': imageURL,
        });
        // get the device token to push notifications
        final deviceToken = await FirebaseMessaging.instance.getToken();
        await _firebaseFirestore.collection('tokens').add({
          'userId': auth.currentUser!.uid,
          'devicesToken': deviceToken,
        });
        setState(() {
          isLoading = false;
        });
        log('User added successfully!');
      }
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      setState(() {
        isLoading = false;
      });
      Scaffold.of(ctx)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      String error = 'An error occurred';
      Scaffold.of(ctx).showSnackBar(SnackBar(content: Text(error)));
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(submitFn, isLoading),
    );
  }
}
