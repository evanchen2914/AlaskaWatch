import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class CurrentWeather extends Model {
  static CurrentWeather getModel(BuildContext context) =>
      ScopedModel.of<CurrentWeather>(context);
}
