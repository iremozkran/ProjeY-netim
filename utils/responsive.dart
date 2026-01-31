import 'package:flutter/material.dart';

class Responsive {
  Responsive._();
  static const double _pageSize = 900;
  static EdgeInsets pagePadding(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    double horizontal =
        (screenWidth > _pageSize) ? ((screenWidth - _pageSize) / 2) + 32 : 32;
    double vertical =
        screenHeight > _pageSize ? ((screenHeight - _pageSize) / 2) + 32 : 32;

    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }
}
