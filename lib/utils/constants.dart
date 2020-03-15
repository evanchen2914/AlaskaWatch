import 'package:flutter/material.dart';

final kWeatherKey = 'cbcea78cd1534b1795022fcc6596b89c';
final kAppName = 'AlaskaWatch';
final kAppPrimaryColor = Color(0xff0F204B);
final kAppSecondaryColor = Color(0xffFFB612);
final kAppTertiaryColor = Color(0xffDBDDE4);
final kAppBorderRadius = 5.0;
final kAppButtonHeight = 47.0;
final kAppBackButtonSize = 32.0;
final kAppVerticalPadding = 20.0;
final kAppHorizontalPaddingFactor = 0.07;
final kGenericErrorMessage = 'An error occurred';
final kWeatherDataError = 'Error getting weather data';
final kCurrentLocationError = 'Error getting current location';
final kInvalidZipCode = 'Invalid zip code';

// Shared Preferences keys
final kPrefsRecentSearches = 'recent_searches';
final kPrefsCurrent = 'current';
final kPrefsHome = 'home';
final kPrefsWork = 'work';

enum WeatherType {
  current,
  forecast,
}
