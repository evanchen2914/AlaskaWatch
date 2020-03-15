import 'package:alaskawatch/models/current_weather.dart';
import 'package:alaskawatch/models/weather_data.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class User extends Model {
  static User getModel(BuildContext context) => ScopedModel.of<User>(context);

  List<String> recentSearches = [];
  List<String> favorites = [];
  List<CurrentWeather> favoritesCurrentWeather = [];
  String currentZip = '';
  String homeZip = '';
  String workZip = '';
  CurrentWeather currentWeather;
  CurrentWeather homeWeather;
  CurrentWeather workWeather;

  User();

  void updateData(
      {List<String> recentSearches,
      List<String> favorites,
      String current,
      String home,
      String work,
      CurrentWeather currentWeather,
      CurrentWeather homeWeather,
      CurrentWeather workWeather}) {
    this.recentSearches = []..addAll(recentSearches ?? this.recentSearches);
    this.favorites = []..addAll(favorites ?? this.favorites);
    this.currentZip = current ?? this.currentZip;
    this.homeZip = home ?? this.homeZip;
    this.workZip = work ?? this.workZip;
    this.currentWeather = currentWeather ?? this.currentWeather;
    this.homeWeather = homeWeather ?? this.homeWeather;
    this.workWeather = workWeather ?? this.workWeather;

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

  void addFavorite(String zip) {
    if (!favorites.contains(zip)) {
      favorites.add(zip);

      notifyListeners();
    }
  }

  void addFavoriteCurrentWeather(CurrentWeather currentWeather) {
    favoritesCurrentWeather.add(currentWeather);

    notifyListeners();
  }

  void removeFavorite(String zip) {
    if (favorites.contains(zip)) {
      favorites.remove(zip);

      notifyListeners();
    }
  }
}
