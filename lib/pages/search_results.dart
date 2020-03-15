import 'package:alaskawatch/models/forecast_daily.dart';
import 'package:alaskawatch/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:alaskawatch/models/current_weather.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:alaskawatch/models/screen_size.dart';
import 'package:alaskawatch/models/weather_data.dart';
import 'package:alaskawatch/utils/constants.dart';
import 'package:alaskawatch/utils/functions.dart';
import 'package:alaskawatch/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final forecastBorderColor = Colors.grey[350];
final forecastBorderWidth = 2.0;

class SearchResults extends StatefulWidget {
  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  SharedPreferences sharedPrefs;
  ScreenSize screenSize;
  WeatherData weatherData;
  User user;

  @override
  void initState() {
    super.initState();

    setUp();
  }

  void setUp() async {
    user = User.getModel(context);
    weatherData = WeatherData.getModel(context);
    sharedPrefs = await SharedPreferences.getInstance();
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

    List<Widget> widgets = [
      Container(
        color: forecastBorderColor,
        height: forecastBorderWidth,
      ),
    ];

    for (var day in weatherData.forecast.forecastDailyList) {
      widgets.add(ExpandableWeatherCard(forecastDaily: day));
    }

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
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'fav') {
                if (user.favorites.contains(weatherData.zip)) {
                  showToast('Location is already in favorites');
                } else {
                  user.addFavorite(weatherData.zip);
                  user.addFavoriteWeatherData(weatherData);
                  await sharedPrefs.setStringList(
                      kPrefsFavorites, user.favorites);
                  showToast('Added to favorites');
                }
              } else if (value == 'share') {
                Share.share(
                    'Here\'s the forecast! '
                    'https://weather.com/weather/tenday/l/${weatherData.zip}:4:US',
                    subject: 'forecast');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'fav',
                  child: Text('Add to favorites'),
                ),
                PopupMenuItem<String>(
                  value: 'share',
                  child: Text('Share'),
                ),
              ];
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
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.horizontalPadding,
            ),
            children: <Widget>[
              headerText('Current'),
              currentWeatherCard(
                currentWeather: weatherData.currentWeather,
                context: context,
              ),
              headerText('Forecast'),
              Column(
                children: widgets,
              ),
              SizedBox(height: kAppVerticalPadding),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandableWeatherCard extends StatelessWidget {
  final ForecastDaily forecastDaily;

  ExpandableWeatherCard({this.forecastDaily, Key key}) : super(key: key);

  final rowHeight = 50.0;
  final fontSize = 16.0;

  Widget collapsed({toggle}) {
    return InkWell(
      onTap: () => toggle(),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: forecastBorderColor,
              width: forecastBorderWidth,
            ),
          ),
        ),
        height: rowHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 70,
              child: Text(
                DateFormat('E d').format(forecastDaily.dateTime),
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
            ),
            Container(
              width: 65,
              child: Text(
                '${celsiusToFahrenheit(forecastDaily?.highTemp)}/${celsiusToFahrenheit(forecastDaily?.lowTemp)}',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
            ),
            Container(
              height: rowHeight,
              width: 52,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: getWeatherIconUrl(forecastDaily?.weatherIconCode),
                ),
              ),
            ),
            Container(
              width: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 16,
                    child: Center(
                      child: Image.asset(
                        'assets/droplet.png',
                      ),
                    ),
                  ),
                  SizedBox(width: 2),
                  Text(
                    '${forecastDaily.chancePrecip}%',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget expanded({toggle}) {
    return Column(
      children: <Widget>[
        collapsed(toggle: () => toggle()),
        Text('expanded'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ExpandableNotifier(
        child: ScrollOnExpand(
          scrollOnExpand: false,
          scrollOnCollapse: false,
          child: Container(
            child: LayoutBuilder(
              builder: (context, size) {
                return Builder(
                  builder: (context) {
                    var controller = ExpandableController.of(context);

                    return Expandable(
                      collapsed: collapsed(toggle: () => controller.toggle()),
                      expanded: expanded(toggle: () => controller.toggle()),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
