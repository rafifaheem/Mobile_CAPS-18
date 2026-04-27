import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 650;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static EdgeInsets padding(BuildContext context) =>
      MediaQuery.of(context).padding;

  static double screenWidth(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.width * (percentage / 100);

  static double screenHeight(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.height * (percentage / 100);
      
  static EdgeInsets getPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: isMobile(context) ? 16.0 : 32.0,
      vertical: 16.0,
    );
  }
}