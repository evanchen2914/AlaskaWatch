import 'package:weather_icons/weather_icons.dart';
import 'package:alaskawatch/models/current_weather.dart';
import 'package:alaskawatch/models/forecast.dart';
import 'package:alaskawatch/models/forecast_daily.dart';
import 'package:alaskawatch/models/screen_size.dart';
import 'package:alaskawatch/models/user.dart';
import 'package:alaskawatch/utils/constants.dart';
import 'package:alaskawatch/utils/functions.dart';
import 'package:alaskawatch/utils/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

final forecastBorderColor = Colors.grey[350];
final forecastBorderWidth = 2.5;

class WeatherDetails extends StatefulWidget {
  final String zip;

  WeatherDetails({Key key, this.zip}) : super(key: key);

  @override
  _WeatherDetailsState createState() => _WeatherDetailsState();
}

class _WeatherDetailsState extends State<WeatherDetails> {
  SharedPreferences sharedPrefs;
  ScreenSize screenSize;
  CurrentWeather currentWeather;
  Forecast forecast;
  User user;
  bool showLoading = true;

  @override
  void initState() {
    super.initState();

    setUp();
  }

  void setUp() async {
    user = User.getModel(context);
    currentWeather = CurrentWeather.getModel(context);
    sharedPrefs = await SharedPreferences.getInstance();

    var weather = await getDataFromWeatherbit(
            zip: widget.zip, weatherType: WeatherType.forecast)
        .catchError((e) {});

    if (weather != null) {
      forecast = weather;
    }

    setState(() {
      showLoading = false;
    });
  }

  Future<void> refresh() async {
    var curr = await getDataFromWeatherbit(
            zip: widget.zip, weatherType: WeatherType.current)
        .catchError((e) {
      showToast(e.toString());
    });

    if (curr != null) {
      setState(() {
        currentWeather = curr;
      });
    } else {
      showToast(kWeatherDataError);
    }

    var fore = await getDataFromWeatherbit(
            zip: widget.zip, weatherType: WeatherType.forecast)
        .catchError((e) {
      showToast(e.toString());
    });

    if (fore != null) {
      setState(() {
        forecast = fore;
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

    if (forecast?.forecastDailyList != null &&
        forecast.forecastDailyList.isNotEmpty) {
      for (var day in forecast?.forecastDailyList) {
        widgets.add(ExpandableWeatherCard(forecastDaily: day));
      }
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: kAppSecondaryColor,
        ),
        title: Text(
          widget.zip,
          style: TextStyle(
            color: kAppSecondaryColor,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          showLoading
              ? Container()
              : PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'fav') {
                      if (user.favorites.contains(widget.zip)) {
                        showToast('Location is already in favorites');
                      } else {
                        user.addFavorite(widget.zip);
                        user.addFavoriteCurrentWeather(currentWeather);
                        await sharedPrefs.setStringList(
                            kPrefsFavorites, user.favorites);
                        showToast('Added to favorites');
                      }
                    } else if (value == 'share') {
                      Share.share(
                          'Here\'s the forecast! '
                          'https://weather.com/weather/tenday/l/${widget.zip}:4:US',
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
                currentWeather: currentWeather,
                context: context,
              ),
              headerText('Forecast'),
              showLoading
                  ? Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(kAppPrimaryColor),
                        ),
                      ),
                    )
                  : Column(
                      children: <Widget>[
                        Column(
                          children: widgets,
                        ),
                        SizedBox(height: kAppVerticalPadding),
                      ],
                    ),
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
    bool showWarning =
        getFormattedWeatherAlerts(forecastDaily: forecastDaily).isNotEmpty;

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
              margin: EdgeInsets.only(left: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 17,
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
            Container(
              child: Icon(
                showWarning ? Icons.warning : Icons.keyboard_arrow_down,
                color: showWarning ? Colors.red : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget expanded({toggle}) {
    String description = '${forecastDaily?.weatherDescription}. '
        'High around ${celsiusToFahrenheit(forecastDaily?.highTemp)} F. '
        'Winds ${parseWindDirection(forecastDaily?.windDirAbbr)} at '
        '${windSpeedToMph(forecastDaily?.windSpeed)}. '
        'Chance of rain ${forecastDaily?.chancePrecip}%.';

    String alerts = getFormattedWeatherAlerts(forecastDaily: forecastDaily);
    bool showWarning = alerts.isNotEmpty;

    Widget divider() {
      return Container(
        height: forecastBorderWidth,
        width: double.maxFinite,
        color: kAppPrimaryColor,
      );
    }

    Widget category(
        {String text, String value, IconData weatherIcon, Color iconColor}) {
      return Flexible(
        flex: 1,
        child: Container(
          height: 75,
          width: double.maxFinite,
          padding: EdgeInsets.only(top: 10),
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: BoxedIcon(
                    weatherIcon,
                    color: iconColor,
                    size: 27,
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        collapsed(toggle: () => toggle()),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: forecastBorderColor,
                width: forecastBorderWidth,
              ),
            ),
          ),
          child: Column(
            children: <Widget>[
              !showWarning
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.red[600],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(kAppBorderRadius),
                                topRight: Radius.circular(kAppBorderRadius),
                              ),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.warning,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 7),
                                  Text(
                                    'Weather Alerts',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 15,
                            ),
                            alignment: Alignment.topLeft,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.red[600],
                                width: 2.5,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    showWarning ? 0 : kAppBorderRadius),
                                topRight: Radius.circular(
                                    showWarning ? 0 : kAppBorderRadius),
                                bottomLeft: Radius.circular(kAppBorderRadius),
                                bottomRight: Radius.circular(kAppBorderRadius),
                              ),
                            ),
                            child: Text(
                              alerts,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              Text(
                description,
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: kAppPrimaryColor,
                    width: forecastBorderWidth,
                  ),
                  borderRadius: BorderRadius.circular(kAppBorderRadius),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          category(
                            text: 'Rainfall',
                            value:
                                '${parsePrecipFall(forecastDaily?.rainfall)}',
                            weatherIcon: WeatherIcons.raindrop,
                            iconColor: Colors.blue,
                          ),
                          category(
                            text: 'Snowfall',
                            value:
                                '${parsePrecipFall(forecastDaily?.snowfall)}',
                            weatherIcon: WeatherIcons.snowflake_cold,
                            iconColor: Colors.lightBlueAccent,
                          ),
                        ],
                      ),
                      divider(),
                      Row(
                        children: <Widget>[
                          category(
                            text: 'Humidity',
                            value: '${forecastDaily?.humidity}%',
                            weatherIcon: WeatherIcons.humidity,
                            iconColor: Colors.lightBlue,
                          ),
                          category(
                            text: 'UV Index',
                            value: '${parseUVIndex(forecastDaily?.uvIndex)}',
                            weatherIcon: WeatherIcons.day_sunny,
                            iconColor: Colors.yellow[800],
                          ),
                        ],
                      ),
                      divider(),
                      Row(
                        children: <Widget>[
                          category(
                            text: 'Visibility',
                            value:
                                '${parseVisibility(forecastDaily?.visibility)}',
                            weatherIcon: WeatherIcons.dust,
                            iconColor: Colors.grey[400],
                          ),
                          category(
                            text: 'Wind',
                            value:
                                '${windSpeedToMph(forecastDaily?.windSpeed)}',
                            weatherIcon: WeatherIcons.strong_wind,
                            iconColor: Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
