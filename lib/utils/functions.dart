import 'dart:convert';

import 'package:alaskawatch/models/current_weather.dart';
import 'package:alaskawatch/models/forecast.dart';
import 'package:alaskawatch/models/weather_data.dart';
import 'package:alaskawatch/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

// testing purposes only
void qq(String message) {
  debugPrint('========== $message');
}

void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIos: 1,
    fontSize: 15.5,
    backgroundColor: Colors.grey[800],
  );
}

List getScreenSize(BuildContext context) {
  double statusBarHeight = MediaQuery.of(context).padding.top;
  double pageHeight = MediaQuery.of(context).size.height - statusBarHeight;
  double pageWidth = MediaQuery.of(context).size.width;

  return [statusBarHeight, pageHeight, pageWidth];
}

isNumeric(string) => num.tryParse(string) != null;

Future<dynamic> getDataFromWeatherbit(
    {String zip, WeatherType weatherType}) async {
  if (!isNumeric(zip)) {
    throw 'Invalid zip code';
  }

  String type;

  if (weatherType == WeatherType.current) {
    type = 'current';
  } else if (weatherType == WeatherType.forecast) {
    type = 'forecast/daily';
  }

  String url = 'https://api.weatherbit.io/v2.0/$type?'
      'postal_code=$zip'
      '&country=US'
      '&key=$kWeatherKey';

  print('Getting data from url: $url');

  http.Response response = await http.get(url);
  String value = response.body;

  try {
    Map<String, dynamic> decodedJson = json.decode(value);

    if (decodedJson == null || decodedJson.isEmpty) {
      throw kWeatherDataError;
    }

    if (weatherType == WeatherType.current) {
      Map data = decodedJson['data'][0];

      if (data == null || data.isEmpty) {
        throw kWeatherDataError;
      }

      return CurrentWeather(data);
    } else if (weatherType == WeatherType.forecast) {
      List data = decodedJson['data'];

      if (data == null || data.isEmpty) {
        throw kWeatherDataError;
      }

      return Forecast(decodedJson);
    }

    throw kWeatherDataError;
  } catch (e) {
    throw kWeatherDataError;
  }
}

//Future<dynamic> getWeatherData({String zip}) async {
//  try {
//    var current =
//        await getDataFromWeatherbit(zip: zip, weatherType: WeatherType.current)
//            .catchError((e) {
//      throw kWeatherDataError;
//    });
//
//    var forecast =
//        await getDataFromWeatherbit(zip: zip, weatherType: WeatherType.forecast)
//            .catchError((e) {
//      throw kWeatherDataError;
//    });
//
//    if (current != null && forecast != null) {
//      return WeatherData(zip: zip, currentWeather: current, forecast: forecast);
//    } else {
//      throw kWeatherDataError;
//    }
//  } catch (e) {
//    throw kWeatherDataError;
//  }
//}

String getWeatherIconUrl(String iconCode) {
  return 'https://www.weatherbit.io/static/img/icons/$iconCode.png';
}

String celsiusToFahrenheit(var temp) {
  if (temp == null) {
    return null;
  }

  double celsiusTemp;

  if (temp is String) {
    celsiusTemp = double.parse(temp);
  } else if (temp is int) {
    celsiusTemp = temp.toDouble();
  } else if (temp is double) {
    celsiusTemp = temp;
  }

  double tempFahrenheit = celsiusTemp * (9.0 / 5.0) + 32;

  return '${tempFahrenheit?.round()}°';
}

Future<Position> getUserLocation({bool testMode}) async {
  Position currentLocation;

  GeolocationStatus geolocationStatus =
      await Geolocator().checkGeolocationPermissionStatus();

  Future<Position> onTimeout() {
    return null;
  }

  Future<Position> getLoc() async {
    int duration = testMode ? 0 : 5;

    return await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .timeout(Duration(seconds: duration), onTimeout: onTimeout);
  }

  if (geolocationStatus != null) {
    if (geolocationStatus == GeolocationStatus.granted) {
      currentLocation = await getLoc();
    } else {
      if (geolocationStatus != GeolocationStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.location]);

        if (permissions[PermissionGroup.location] == PermissionStatus.granted) {
          currentLocation = await getLoc();
        }
      }
    }

    return currentLocation ?? null;
  }

  return currentLocation;
}

Future<String> getZipFromPosition(Position position) async {
  final coordinates = Coordinates(position.latitude, position.longitude);

  try {
    var addresses = await Geocoder.local
        .findAddressesFromCoordinates(coordinates)
        .catchError((e) {
      throw kCurrentLocationError;
    });
    var first = addresses.first;

    return first.postalCode;
  } catch (e) {
    throw kCurrentLocationError;
  }
}

String windSpeedToMph(var speed) {
  if (speed == null) {
    return null;
  }

  double windSpeedMs;

  if (speed is String) {
    windSpeedMs = double.parse(speed);
  } else if (speed is int) {
    windSpeedMs = speed.toDouble();
  } else if (speed is double) {
    windSpeedMs = speed;
  }

  double windSpeedMph = windSpeedMs * 2.237;

  return '${windSpeedMph?.round()} mph';
}

String parseWindDirection(var direction) {
  if (direction == null) {
    return null;
  }

  if (direction is String) {
    if (direction.length > 2) {
      return direction.substring(1);
    } else {
      return direction;
    }
  } else {
    return null;
  }
}
