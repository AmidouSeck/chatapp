import 'package:flutter/material.dart';

//Largeur de l'écran
double mediaWidth(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return size.width;
}

//Longueur de l'écran
double mediaHeight(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return size.height;
}
class Constants{
  Constants._();
  static const double padding =20;
  static const double avatarRadius =85;
}