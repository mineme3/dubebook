import 'package:flutter/material.dart';

class AppBreakpoints {
  // SaaS layout grid breakpoints based on viewport width
  static const double mobile = 600.0;
  static const double tablet = 1024.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;

  static T selectValue<T>({
    required BuildContext context,
    required T mobileVal,
    required T tabletVal,
    required T desktopVal,
  }) {
    final w = MediaQuery.of(context).size.width;
    if (w < mobile) return mobileVal;
    if (w < tablet) return tabletVal;
    return desktopVal;
  }
}
