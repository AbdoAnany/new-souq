import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double screenPaddingTop;
  static late double screenPaddingBottom;
  static late double screenPaddingLeft;
  static late double screenPaddingRight;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;

    screenPaddingTop = _mediaQueryData.padding.top;
    screenPaddingBottom = _mediaQueryData.padding.bottom;
    screenPaddingLeft = _mediaQueryData.padding.left;
    screenPaddingRight = _mediaQueryData.padding.right;
  }

  static double getProportionateScreenWidth(double inputWidth) {
    return blockSizeHorizontal * inputWidth;
  }

  static double getProportionateScreenHeight(double inputHeight) {
    return blockSizeVertical * inputHeight;
  }
}
