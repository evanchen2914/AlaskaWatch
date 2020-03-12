import 'package:alaskawatch/models/daily_weather.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class Forecast extends Model {
  static Forecast getModel(BuildContext context) =>
      ScopedModel.of<Forecast>(context);

  List<DailyWeather> dailyForecast = [];

  Forecast(Map data) {
    this.dailyForecast = []..addAll([]);
  }
}
