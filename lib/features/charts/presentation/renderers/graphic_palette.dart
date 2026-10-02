import 'package:flutter/material.dart';

abstract final class GraphicPalette {
  static const colors = [
    Color(0xFF007E87),
    Color(0xFF8D49AB),
    Color(0xFFD66600),
    Color(0xFF315AC1),
  ];
  static Color at(int i) => colors[i % colors.length];
}
