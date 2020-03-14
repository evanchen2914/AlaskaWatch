import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ForecastDaily extends Model {
  static ForecastDaily getModel(BuildContext context) =>
      ScopedModel.of<ForecastDaily>(context);

  var validDate;
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

    notifyListeners();
  }
}
