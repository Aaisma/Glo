import 'package:flutter/material.dart';

class ThoughtsInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: 200,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "What's on your mind? (optional)",
      ),
    );
  }
}
