import 'package:flutter/material.dart';

class Responsive{
  Responsive._();

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;

  static bool isMobile(BuildContext context){
    return MediaQuery.sizeOf(context).width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context){
    final width = MediaQuery.sizeOf(context).width;

    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context){
    return MediaQuery.sizeOf(context).width >= tabletBreakpoint;
  }

  static double screenWidth(BuildContext context){
    return MediaQuery.sizeOf(context).width;
  }

  static double screenHeight(BuildContext context){
    return MediaQuery.sizeOf(context).height;
  }

  static int productGridCount(BuildContext context){
    final width = screenWidth(context);

    if(width >= 1200) return 5;
    if(width >= 900) return 4;
    if(width >= 600) return 3;

    return 2;
  }
}

