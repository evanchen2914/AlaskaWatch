import 'package:alaskawatch/models/forecast_daily.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class Forecast extends Model {
  static Forecast getModel(BuildContext context) =>
      ScopedModel.of<Forecast>(context);

  var cityName;
  var countryCode;
  var stateCode;
  var timezone;
  List<ForecastDaily> forecastDailyList;

  Forecast(Map data) {
    updateData(data);
  }

  void updateData(Map data) {
    cityName = data['city_name'];
    countryCode = data['country_code'];
    stateCode = data['state_code'];
    timezone = data['timezone'];
    List days = data['data'];

    if (days != null && days.isNotEmpty) {
      forecastDailyList = [];

      if (days.length > 0) {
        for (var i = 0; i < 7; i++) {
          forecastDailyList.add(ForecastDaily(days[i]));
        }
      }
    }

    notifyListeners();
  }
}
