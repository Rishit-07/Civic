import 'package:flutter/material.dart';

/// Design tokens: Corner radii & pill contours
class AppRadii {
  AppRadii._();

  static const double sm = 8.0;
  static const double defaultRadius = 16.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double pill = 9999.0;

  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius defaultBorder = BorderRadius.all(Radius.circular(defaultRadius));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillBorder = BorderRadius.all(Radius.circular(pill));
}
