import 'package:alaskawatch/models/current_weather.dart';
import 'package:alaskawatch/models/screen_size.dart';
import 'package:alaskawatch/models/weather_data.dart';
import 'package:alaskawatch/utils/constants.dart';
import 'package:alaskawatch/utils/functions.dart';
import 'package:alaskawatch/utils/widgets.dart';
import 'package:flutter/material.dart';

class SearchResults extends StatefulWidget {
  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  ScreenSize screenSize;
  WeatherData weatherData;

  @override
  void initState() {
    super.initState();

    weatherData = WeatherData.getModel(context);
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: kAppSecondaryColor,
        ),
        title: Text(
          kAppName,
          style: TextStyle(
            color: kAppSecondaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: ScrollConfiguration(
        behavior: RemoveScrollGlow(),
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: kAppVerticalPadding),
          children: <Widget>[
            Text(weatherData.forecast.timezone),
          ],
        ),
      ),
    );
  }
}
