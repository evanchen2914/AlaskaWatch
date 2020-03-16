import 'package:alaskawatch/models/current_weather.dart';
import 'package:alaskawatch/models/user.dart';
import 'package:alaskawatch/utils/reorderable_favorites_list.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class FavoritesEdit extends Model {
  static FavoritesEdit getModel(BuildContext context) =>
      ScopedModel.of<FavoritesEdit>(context);

  List<String> favorites = [];
  Map<String, CurrentWeather> favoritesCurrentWeather = {};
  List<FavoritesItemData> favoritesItems = [];

  FavoritesEdit({User user}) {
    favorites = []..addAll(user.favorites);
    favoritesCurrentWeather = {}..addAll(user.favoritesCurrentWeather);

    favoritesItems = []..addAll(favorites
        .map((String zip) => FavoritesItemData(
            zip: zip,
            location: favoritesCurrentWeather[zip].cityName?.toString(),
            key: ValueKey(DateTime.now().microsecondsSinceEpoch)))
        .toList());
  }
}
