import 'package:alaskawatch/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
