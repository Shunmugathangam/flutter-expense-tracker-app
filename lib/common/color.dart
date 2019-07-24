import 'package:flutter/material.dart';

Color getCategoryColor(int colorCode) {
    if(colorCode == null) {
      colorCode = Colors.blueGrey.value;
    } 
    return Color(colorCode);
}

int defaultColorCode() {
    return Colors.blueGrey.value;
}