import 'package:alaskawatch/models/current_weather.dart';
import 'package:alaskawatch/models/screen_size.dart';
import 'package:alaskawatch/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

Widget currentWeatherCard(
    {BuildContext context, CurrentWeather currentWeather}) {
  return Container(
    height: 195,
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey[200],
          spreadRadius: 4,
          blurRadius: 5,
        ),
      ],
      border: Border.all(color: kAppPrimaryColor, width: 2),
      borderRadius: BorderRadius.circular(kAppBorderRadius),
    ),
    child: Column(
      children: <Widget>[
        Container(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${currentWeather?.cityName}, ${currentWeather?.stateCode}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              Text(
                currentWeather?.weatherDescription?.toString(),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: getWeatherIconUrl(currentWeather?.weatherIconCode),
                fit: BoxFit.cover,
              ),
              Container(
                margin: EdgeInsets.only(right: 15),
                child: Text(
                  celsiusToFahrenheit(currentWeather?.tempCelsius),
                  style: TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${parseWindDirection(currentWeather?.windDirAbbr)} ${windSpeedToMph(currentWeather?.windSpeed)}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'Feels like ${celsiusToFahrenheit(currentWeather?.feelsLikeTemp)}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
        ),
      ],
    ),
  );
}
