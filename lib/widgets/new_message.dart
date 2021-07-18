import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  final Function sendNotification;
  final Function sendMessage;
  const NewMessage(this.sendNotification, this.sendMessage);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  TextEditingController _controller = TextEditingController();
  String message = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Send a message...'),
              onChanged: (value) {
                setState(() {
                  message = value;
                });
              },
            ),
          ),
          IconButton(
            onPressed: message.trim().isEmpty
                ? null
                : () {
                    widget.sendNotification(message);
                    widget.sendMessage(message);

                    _controller.clear();
                    setState(() {
                      message = '';
                    });
                  },
            icon: Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
