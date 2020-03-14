import 'dart:convert';

import 'package:alaskawatch/models/current_weather.dart';
import 'package:alaskawatch/models/forecast.dart';
import 'package:alaskawatch/models/weather_data.dart';
import 'package:alaskawatch/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

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

  debugPrint('Getting data from url: $url');

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

Future<dynamic> getWeatherData({String zip}) async {
  try {
    var current =
        await getDataFromWeatherbit(zip: zip, weatherType: WeatherType.current)
            .catchError((e) {
      throw kWeatherDataError;
    });

    var forecast =
        await getDataFromWeatherbit(zip: zip, weatherType: WeatherType.forecast)
            .catchError((e) {
      throw kWeatherDataError;
    });

    if (current != null && forecast != null) {
      return WeatherData(currentWeather: current, forecast: forecast);
    } else {
      throw kWeatherDataError;
    }
  } catch (e) {
    throw kWeatherDataError;
  }
}
