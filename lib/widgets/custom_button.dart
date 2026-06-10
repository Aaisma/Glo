import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  const CustomButton({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pinkAccent,
        minimumSize: Size(double.infinity, 50),
      ),
      onPressed: () {},
      child: Text(label, style: TextStyle(fontSize: 16)),
    );
  }
}
