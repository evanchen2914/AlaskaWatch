import 'package:alaskawatch/utils/constants.dart';
import 'package:alaskawatch/utils/functions.dart';
import 'package:flutter/cupertino.dart';

class ScreenSize {
  double statusBarHeight;
  double pageHeight;
  double pageWidth;
  double horizontalPadding;
  double contentWidth;

  ScreenSize(BuildContext context) {
    List screenSizes = getScreenSize(context);
    statusBarHeight = screenSizes[0];
    pageHeight = screenSizes[1];
    pageWidth = screenSizes[2];
    horizontalPadding = pageWidth * kAppHorizontalPaddingFactor;
    contentWidth = pageWidth - (horizontalPadding * 2);
  }
}
