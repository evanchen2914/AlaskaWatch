import 'package:alaskawatch/models/current_weather.dart';
import 'package:share/share.dart';
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

  Future<void> refresh() async {
    var updated = await getWeatherData(zip: weatherData.zip).catchError((e) {
      showToast(e.toString());
    });

    if (updated != null) {
      setState(() {
        weatherData = updated;
      });
    } else {
      showToast(kWeatherDataError);
    }
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
          weatherData.zip,
          style: TextStyle(
            color: kAppSecondaryColor,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            tooltip: 'Share forecast',
            onPressed: () {
              Share.share(
                  'Here\'s the forecast! '
                  'https://weather.com/weather/tenday/l/${weatherData.zip}:4:US',
                  subject: 'forecast');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: kAppPrimaryColor,
        onRefresh: refresh,
        child: ScrollConfiguration(
          behavior: RemoveScrollGlow(),
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: kAppVerticalPadding),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenSize.horizontalPadding),
                child: currentWeatherCard(
                  currentWeather: weatherData.currentWeather,
                  context: context,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
