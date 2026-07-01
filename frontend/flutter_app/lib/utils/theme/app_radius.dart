import 'package:flutter/material.dart';

class AppRadius {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double max = 9999.0;

  // BorderRadius objects
  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderS = BorderRadius.all(Radius.circular(s));
  static const BorderRadius borderM = BorderRadius.all(Radius.circular(m));
  static const BorderRadius borderL = BorderRadius.all(Radius.circular(l));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius borderMax = BorderRadius.all(Radius.circular(max));
}
