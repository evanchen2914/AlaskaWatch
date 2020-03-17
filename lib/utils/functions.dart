import 'dart:convert';

import 'package:alaskawatch/models/current_weather.dart';
import 'package:alaskawatch/models/forecast.dart';
import 'package:alaskawatch/models/forecast_daily.dart';
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

      return CurrentWeather(data, zip);
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

String parsePrecipFall(var fall) {
  if (fall == null) {
    return null;
  }

  double precip;

  if (fall is String) {
    precip = double.parse(fall);
  } else if (fall is int) {
    precip = fall.toDouble();
  } else if (fall is double) {
    precip = fall;
  }

  precip /= 25.4;

  String parsed = '';

  if (precip == 0) {
    parsed = '0';
  } else {
    parsed = precip?.toStringAsFixed(2);
  }

  return '$parsed in.';
}

String parseUVIndex(var index) {
  if (index == null) {
    return null;
  }

  double uvIndex;

  if (index is String) {
    uvIndex = double.parse(index);
  } else if (index is int) {
    uvIndex = index.toDouble();
  } else if (index is double) {
    uvIndex = index;
  }

  int intIndex = uvIndex.round();
  String parsed = '';

  if (intIndex >= 1 && intIndex <= 2) {
    parsed = 'Low';
  } else if (intIndex >= 3 && intIndex <= 5) {
    parsed = 'Moderate';
  } else if (intIndex >= 6 && intIndex <= 7) {
    parsed = 'High';
  } else if (intIndex >= 8 && intIndex <= 10) {
    parsed = 'Very high';
  } else if (intIndex >= 11) {
    parsed = 'Extreme';
  }

  return parsed;
}

String parseEpoch(var epoch) {
  if (epoch == null) {
    return null;
  }

  int unix;

  if (epoch is String) {
    unix = int.parse(epoch);
  } else if (epoch is int) {
    unix = epoch;
  } else if (epoch is double) {
    unix = epoch.toInt();
  }

  DateTime time = DateTime.fromMillisecondsSinceEpoch(1584702641 * 1000);

  return time?.toString();
}

String parseVisibility(var vis) {
  if (vis == null) {
    return null;
  }

  double visibility;

  if (vis is String) {
    visibility = double.parse(vis);
  } else if (vis is int) {
    visibility = vis.toDouble();
  } else if (vis is double) {
    visibility = vis;
  }

  double visFinal = visibility * 2.237;

  return '${visFinal?.round()} mi.';
}

double parseToDouble(var value) {
  if (value == null) {
    return null;
  }

  double output;

  if (value is String) {
    output = double.parse(value);
  } else if (value is int) {
    output = value.toDouble();
  } else if (value is double) {
    output = value;
  }

  return output;
}

List<String> _generateWeatherAlerts(
    {CurrentWeather currentWeather, ForecastDaily forecastDaily}) {
  List<String> warnings = [];

  if (currentWeather == null && forecastDaily == null) {
    return warnings;
  }

  var wind;
  var uv;
  var snow;

  if (currentWeather != null && forecastDaily == null) {
    wind = currentWeather?.windSpeed;
    uv = currentWeather?.uvIndex;
    snow = currentWeather?.snowfall;
  } else if (currentWeather == null && forecastDaily != null) {
    wind = forecastDaily?.windSpeed;
    uv = forecastDaily?.uvIndex;
    snow = forecastDaily?.snowfall;
  }

  double windSpeed = parseToDouble(wind);
  double uvIndex = parseToDouble(uv);
  double snowfall = parseToDouble(snow);

  if (windSpeed != null) {
    int windSpeedMph = (windSpeed * 2.237).round();

    if (windSpeedMph >= 16) {
      warnings.add('wind');
    }
  }

  if (uvIndex != null) {
    if (uvIndex >= 6) {
      warnings.add('uv');
    }
  }

  if (snowfall != null) {
    if (snowfall > 0) {
      warnings.add('snow');
    }
  }

  return warnings;
}

String getFormattedWeatherAlerts(
    {CurrentWeather currentWeather, ForecastDaily forecastDaily}) {
  List<String> warnings = _generateWeatherAlerts(
      currentWeather: currentWeather ?? null,
      forecastDaily: forecastDaily ?? null);
  bool showWarning = warnings.isNotEmpty;
  String alerts = '';

  if (showWarning) {
    for (var str in warnings) {
      if (str == 'wind') {
        alerts += '- High Wind\n';
      } else if (str == 'uv') {
        alerts += '- High UV Index\n';
      } else if (str == 'snow') {
        alerts += '- Snow today\n';
      }
    }
  }

  return alerts.trimRight();
}
