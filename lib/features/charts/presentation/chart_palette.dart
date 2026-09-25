import 'package:flutter/material.dart';

abstract final class ChartPalette {
  static const colors = <Color>[
    Color(0xFF0B7D6B),
    Color(0xFF38A3A5),
    Color(0xFFFFB703),
    Color(0xFFEF6F6C),
    Color(0xFF6C63FF),
    Color(0xFF2D6A4F),
    Color(0xFFF4A261),
  ];

  static Color at(int index) => colors[index % colors.length];
}
