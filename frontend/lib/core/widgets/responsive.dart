
import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  // Screen width breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  // Screen size detection
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return width >= mobileBreakpoint &&
        width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >=
        tabletBreakpoint;
  }

  // Maximum content width for larger screens
  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 1440) {
      return 1200;
    }

    if (width >= tabletBreakpoint) {
      return 1100;
    }

    return width;
  }
}
