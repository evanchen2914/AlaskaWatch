import 'package:alaskawatch/models/current_weather.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class WeatherAlerts extends Model {
  static WeatherAlerts getModel(BuildContext context) =>
      ScopedModel.of<WeatherAlerts>(context);

  CurrentWeather currentWeather;

  WeatherAlerts({CurrentWeather currentWeather}) {
    this.currentWeather = currentWeather;
  }
}
