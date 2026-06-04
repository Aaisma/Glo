import 'package:flutter/material.dart';

class MoodModel {
  final String name;
  final String image;
  final IconData icon;
  final Color color;
  bool selected;

  MoodModel({
    required this.name,
    required this.image,
    required this.icon,
    required this.color,
    this.selected = false,
  });
}