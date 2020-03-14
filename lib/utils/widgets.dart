import 'package:alaskawatch/models/screen_size.dart';
import 'package:alaskawatch/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'functions.dart';

class RemoveScrollGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

Widget splashScreen() {
  return Scaffold(
    body: Stack(
      children: <Widget>[
        SizedBox.expand(
          child: Image.asset(
            'assets/splash.jpg',
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),
        ),
        Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  kAppName,
                  style: TextStyle(
                    fontSize: 42,
                    color: kAppSecondaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 20),
                SpinKitThreeBounce(
                  size: 35,
                  color: kAppSecondaryColor,
                )
              ],
            )),
      ],
    ),
  );
}

Widget loadingScreen() {
  return Scaffold(
    backgroundColor: kAppPrimaryColor,
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

Widget customBox({BuildContext context, Widget child}) {
  ScreenSize screenSize = ScreenSize(context);

  return Container(
    padding: EdgeInsets.symmetric(horizontal: screenSize.horizontalPadding),
    child: Container(
      height: kAppButtonHeight,
      width: screenSize.contentWidth,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.0, color: Colors.grey[200]),
          borderRadius: BorderRadius.all(
            Radius.circular(kAppBorderRadius),
          ),
        ),
        color: Colors.white,
        shadows: [
          BoxShadow(
            color: Colors.grey[200],
            spreadRadius: 6,
            blurRadius: 5,
          ),
        ],
      ),
      child: child,
    ),
  );
}
