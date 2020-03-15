import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ForecastDaily extends Model {
  static ForecastDaily getModel(BuildContext context) =>
      ScopedModel.of<ForecastDaily>(context);

  var validDate;
  DateTime dateTime;
  var temp;
  var highTemp;
  var lowTemp;
  var chancePrecip;
  var weatherIconCode;
  var weatherCode;
  var weatherDescription;
  var clouds;
  var visibility;
  var uvIndex;
  var sunrise;
  var sunset;

  ForecastDaily(Map data) {
    updateData(data);
  }

  void updateData(Map data) {
    validDate = data['valid_date'];
    temp = data['temp'];
    highTemp = data['high_temp'];
    lowTemp = data['low_temp'];
    chancePrecip = data['pop'];
    Map weather = data['weather'];
    weatherIconCode = weather['icon'];
    weatherCode = weather['code'];
    weatherDescription = weather['description'];
    clouds = data['clouds'];
    visibility = data['vis'];
    uvIndex = data['uv'];
    sunrise = data['sunrise_ts'];
    sunset = data['sunset_ts'];

    // parse valid date
    String origDate = validDate.toString();
    List split = origDate.split('-');
    int year = int.parse(split[0]);
    int month = int.parse(split[1]);
    int day = int.parse(split[2]);

    dateTime = DateTime(year, month, day);

    notifyListeners();
  }
}
