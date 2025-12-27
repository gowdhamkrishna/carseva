import 'package:flutter/material.dart';

class ScreenSize {
  static Size size(BuildContext context){
    return MediaQuery.of(context).size;
  }
}