import 'package:alaskawatch/models/current_weather.dart';
import 'package:alaskawatch/models/user.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class FavoritesEdit extends Model {
  static FavoritesEdit getModel(BuildContext context) =>
      ScopedModel.of<FavoritesEdit>(context);

  List<String> favorites = [];
  Map<String, CurrentWeather> favoritesCurrentWeather = {};

  FavoritesEdit({User user}) {
    favorites = []..addAll(user.favorites);
    favoritesCurrentWeather = {}..addAll(user.favoritesCurrentWeather);
  }
}
