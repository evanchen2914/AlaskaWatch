import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class DailyWeather extends Model {
  static DailyWeather getModel(BuildContext context) =>
      ScopedModel.of<DailyWeather>(context);
}
