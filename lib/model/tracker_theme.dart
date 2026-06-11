import 'package:flutter/material.dart';

class ThemeColors {
  final Color background;
  final Color headerText;
  final Color toggleActiveBg;
  final Color border;
  final Color lightCircle;
  final Color darkCircle;
  final Color buttonBg;

  ThemeColors({
    required this.background,
    required this.headerText,
    required this.toggleActiveBg,
    required this.border,
    required this.lightCircle,
    required this.darkCircle,
    required this.buttonBg,
  });
}

final periodTheme = ThemeColors(
  background: Colors.white,
  headerText: const Color(0xFFD64A62),
  toggleActiveBg: const Color(0xFFDC4158),
  border: const Color(0xFFE5B4BE),
  lightCircle: const Color(0xFFFBD5DC),
  darkCircle: const Color(0xFFEF4C63),
  buttonBg: const Color(0xFFD34860),
);

final ovulationTheme = ThemeColors(
  background: Colors.white,
  headerText: const Color(0xFF5A8E4C),
  toggleActiveBg: const Color(0xFF549A46),
  border: const Color(0xFFBEDEB8),
  lightCircle: const Color(0xFFBAE5A8),
  darkCircle: const Color(0xFF5BAA49),
  buttonBg: const Color(0xFF5AA547),
);
