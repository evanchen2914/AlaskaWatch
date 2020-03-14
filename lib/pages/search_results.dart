import 'package:alaskawatch/models/current_weather.dart';
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
  WeatherData weatherData;

  double statusBarHeight;
  double pageHeight;
  double pageWidth;

  @override
  void initState() {
    super.initState();

    weatherData = WeatherData.getModel(context);
  }

  @override
  Widget build(BuildContext context) {
    List screenSizes = getScreenSize(context);
    statusBarHeight = screenSizes[0];
    pageHeight = screenSizes[1];
    pageWidth = screenSizes[2];

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
          children: <Widget>[
            Text(weatherData.forecast.timezone),
          ],
        ),
      ),
    );
  }
}
