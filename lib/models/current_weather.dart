import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class CurrentWeather extends Model {
  static CurrentWeather getModel(BuildContext context) =>
      ScopedModel.of<CurrentWeather>(context);

  var cityName;
  var stateCode;
  var tempCelsius;
  var feelsLikeTemp;
  var weatherIconCode;
  var weatherCode;
  var weatherDescription;
  var windDirAbbr;
  var windSpeed;
  var humidity;

  CurrentWeather(Map data) {
    updateData(data);
  }

  void updateData(Map data) {
    cityName = data['city_name'];
    stateCode = data['state_code'];
    tempCelsius = data['temp'];
    feelsLikeTemp = data['app_temp'];
    Map weather = data['weather'];
    weatherIconCode = weather['icon'];
    weatherCode = weather['code'];
    weatherDescription = weather['description'];
    windDirAbbr = data['wind_cdir'];
    windSpeed = data['wind_spd'];
    humidity = data['rh'];

    notifyListeners();
  }
}
