import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  final screenId = 'testScreen';
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Screen'),
      ),
    );
  }
}
