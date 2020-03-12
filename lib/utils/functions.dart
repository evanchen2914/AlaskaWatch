import 'dart:convert';

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

Future<dynamic> getWeatherJson(String zip) async {
  String forecastUrl = 'https://api.weatherbit.io/v2.0/forecast/daily?'
      'postal_code=$zip'
      '&country=US'
      '&key=$kWeatherKey';

  http.Response response = await http.get(forecastUrl);
  String value = response.body;

  try {
    Map<String, dynamic> decodedJson = json.decode(value);
    List<dynamic> subjects = decodedJson['data'];

    showToast(subjects.toString());

    return subjects;
  } catch (e) {
    showToast('Error getting weather data');
  }

//  Map<String, dynamic> decodedJson = json.decode(value);
//  List<dynamic> subjects = decodedJson['data'];
//
//  return subjects;
}
