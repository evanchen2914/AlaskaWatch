import 'package:alaskawatch/models/current_weather.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:weather_icons/weather_icons.dart';

final kWeatherAlertUv = 'High UV Index';
final kWeatherAlertGale = 'Gale Warning';
final kWeatherAlertFlood = 'Flood Watch';
final kWeatherAlertStorm = 'Thunderstorm';
final kWeatherAlertSnow = 'Snowstorm';

class WeatherAlerts extends Model {
  static WeatherAlerts getModel(BuildContext context) =>
      ScopedModel.of<WeatherAlerts>(context);

  Map<String, bool> alerts = {
    kWeatherAlertUv: false,
    kWeatherAlertGale: false,
    kWeatherAlertFlood: false,
    kWeatherAlertStorm: false,
    kWeatherAlertSnow: false,
  };

  Map<String, IconData> icons = {
    kWeatherAlertUv: WeatherIcons.day_sunny,
    kWeatherAlertGale: WeatherIcons.gale_warning,
    kWeatherAlertFlood: WeatherIcons.flood,
    kWeatherAlertStorm: WeatherIcons.lightning,
    kWeatherAlertSnow: WeatherIcons.snowflake_cold,
  };

  WeatherAlerts();

  bool isEmpty() {
    return !alerts.containsValue(true);
  }

  void toggleAllEvents() {
    // if all values true, mark all values as unchecked
    if (!alerts.containsValue(false)) {
      for (final key in alerts.keys) {
        alerts[key] = false;
      }

      return;
    }

    // else, mark all as checked
    for (final key in alerts.keys) {
      alerts[key] = true;
    }
  }

  IconData getAllEventsIconData() {
    // if all values true, show full check box
    if (!alerts.containsValue(false)) {
      return Icons.check_box;
    }

    // if all values false, show empty box
    if (!alerts.containsValue(true)) {
      return Icons.check_box_outline_blank;
    }

    // else, some items are checked
    return Icons.indeterminate_check_box;
  }
}
