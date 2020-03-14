import 'package:alaskawatch/models/current_weather.dart';
import 'package:alaskawatch/models/forecast.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class WeatherData extends Model {
  static WeatherData getModel(BuildContext context) =>
      ScopedModel.of<WeatherData>(context);
  CurrentWeather currentWeather;
  Forecast forecast;

  WeatherData({CurrentWeather currentWeather, Forecast forecast}) {
    this.currentWeather = currentWeather;
    this.forecast = forecast;
  }
}
