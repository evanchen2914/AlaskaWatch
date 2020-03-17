import 'package:alaskawatch/dialogs/alerts_dialog.dart';
import 'package:alaskawatch/models/current_weather.dart';
import 'package:alaskawatch/models/forecast.dart';
import 'package:alaskawatch/models/forecast_daily.dart';
import 'package:alaskawatch/models/screen_size.dart';
import 'package:alaskawatch/models/user.dart';
import 'package:alaskawatch/models/weather_alerts.dart';
import 'package:alaskawatch/utils/constants.dart';
import 'package:alaskawatch/utils/functions.dart';
import 'package:alaskawatch/utils/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_icons/weather_icons.dart';

class AlertDetails extends StatefulWidget {
  AlertDetails({Key key}) : super(key: key);

  @override
  _AlertDetailsState createState() => _AlertDetailsState();
}

class _AlertDetailsState extends State<AlertDetails> {
  ScreenSize screenSize;
  bool showLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[600],
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            tooltip: 'Share',
            onPressed: () {
              Share.share('Severe thunderstorm warning!', subject: 'Alert');
            },
            icon: Icon(Icons.share),
          ),
        ],
        title: Text(
          'Weather Alert',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: ScrollConfiguration(
        behavior: RemoveScrollGlow(),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.horizontalPadding,
          ),
          children: <Widget>[
            headerText('San Angelo, TX'),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.red[600],
                  width: 2.5,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(kAppBorderRadius),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    color: Colors.red[600],
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Severe Thunderstorm Watch from TUE 4:41 PM CDT until WED 12:00 AM CDT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            subheaderText('Action Recommended'),
            bodyText(
                'Attend to information sources as described in the instructions'),
            subheaderText('Issued By'),
            bodyText('San Angelo - TX, US, National Weather Service'),
            subheaderText('Affected Area'),
            bodyText('Tom Green County'),
            subheaderText('Description'),
            bodyText(
                'THE NATIONAL WEATHER SERVICE HAS ISSUED SEVERE THUNDERSTORM WATCH 53 IN EFFECT UNTIL MIDNIGHT CDT TONIGHT FOR THE FOLLOWING AREAS\n\nIN TEXAS THIS WATCH INCLUDES 17 COUNTIES IN WEST CENTRAL TEXAS\n\nCALLAHAN\nCOKE\nCOLEMAN\nCONCHO\nCROCKETT\nFISHER\nIRION\nJONES\nMENARD\nNOLAN\nRUNNELS\nSCHLEICHER\nSHACKELFORD\nSTERLING\nSUTTON\nTAYLOR\nTOM GREEN'),
            SizedBox(height: screenSize.verticalPadding),
          ],
        ),
      ),
    );
  }
}

Widget subheaderText(String text) {
  return Container(
    height: 52,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

Widget bodyText(String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
    ),
  );
}
