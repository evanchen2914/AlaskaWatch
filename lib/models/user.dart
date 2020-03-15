import 'package:alaskawatch/models/weather_data.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class User extends Model {
  static User getModel(BuildContext context) => ScopedModel.of<User>(context);

  List<String> recentSearches = [];
  String currentZip = '';
  String homeZip = '';
  String workZip = '';
  WeatherData currentWeatherData;
  WeatherData homeWeatherData;
  WeatherData workWeatherData;

  User();

  void updateData(
      {List<String> recentSearches,
      String current,
      String home,
      String work,
      WeatherData currentWeatherData,
      WeatherData homeWeatherData,
      WeatherData workWeatherData}) {
    this.recentSearches = []..addAll(recentSearches ?? this.recentSearches);
    this.currentZip = current ?? this.currentZip;
    this.homeZip = home ?? this.homeZip;
    this.workZip = work ?? this.workZip;
    this.currentWeatherData = currentWeatherData ?? this.currentWeatherData;
    this.homeWeatherData = homeWeatherData ?? this.homeWeatherData;
    this.workWeatherData = workWeatherData ?? this.workWeatherData;

    notifyListeners();
  }

  void addRecentSearch(String zip) {
    if (!recentSearches.contains(zip)) {
      recentSearches.add(zip);

      notifyListeners();
    }
  }

  void removeRecentSearch(String zip) {
    if (recentSearches.contains(zip)) {
      recentSearches.remove(zip);

      notifyListeners();
    }
  }
}
