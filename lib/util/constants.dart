import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

const String ARTICLES_BOX_NAME = "articles";

class TextStyles {
  TextStyles._();

  static const title = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const helper = TextStyle(fontSize: 14, color: Colors.black45);
}

class AppColors {
  AppColors._();

  static const accent = Color(0xFFE23644);
}

class AppAnimations {
  AppAnimations._();

  static Duration duration = 300.milliseconds;
  static Curve curve = Curves.easeInOutCubic;
}
