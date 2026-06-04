import 'package:flutter/material.dart';

class SymptomModel {
  final String title;
  final IconData icon;
  bool selected;

  SymptomModel({
    required this.title,
    required this.icon,
    this.selected = false,
  });
}