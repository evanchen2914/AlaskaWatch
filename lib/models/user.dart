import 'package:alaskawatch/models/current_weather.dart';
import 'package:alaskawatch/models/weather_data.dart';
import 'package:alaskawatch/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class User extends Model {
  static User getModel(BuildContext context) => ScopedModel.of<User>(context);

  List<String> recentSearches = [];
  List<String> favorites = [];
  Map<String, CurrentWeather> favoritesCurrentWeather = {};
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
      String currentZip,
      String homeZip,
      String workZip,
      CurrentWeather currentWeather,
      CurrentWeather homeWeather,
      CurrentWeather workWeather}) {
    this.recentSearches = []..addAll(recentSearches ?? this.recentSearches);
    this.favorites = []..addAll(favorites ?? this.favorites);
    this.currentZip = currentZip ?? this.currentZip;
    this.homeZip = homeZip ?? this.homeZip;
    this.workZip = workZip ?? this.workZip;
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
    favoritesCurrentWeather[currentWeather.zip] = currentWeather;

    notifyListeners();
  }

  void removeFavoriteCurrentWeather(String zip) {
    favoritesCurrentWeather.remove(currentWeather.zip);

    notifyListeners();
  }

  void removeFavorite(String zip) {
    if (favorites.contains(zip)) {
      favorites.remove(zip);

      notifyListeners();
    }
  }

  CurrentWeather getCachedCurrentWeather(String zip) {
    if (currentWeather?.zip == zip) {
      return currentWeather;
    } else if (homeWeather?.zip == zip) {
      return homeWeather;
    } else if (workWeather?.zip == zip) {
      return workWeather;
    } else {
      if (favoritesCurrentWeather != null &&
          favoritesCurrentWeather.containsKey(zip)) {
        return favoritesCurrentWeather[zip];
      } else {
        return null;
      }
    }
  }
}
