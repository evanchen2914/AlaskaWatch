import 'package:alaskawatch/dialogs/custom_dialog.dart' as customDialog;
import 'package:alaskawatch/models/screen_size.dart';
import 'package:alaskawatch/models/weather_alerts.dart';
import 'package:alaskawatch/utils/constants.dart';
import 'package:alaskawatch/utils/widgets.dart';
import 'package:flutter/material.dart';

class AlertsDialog extends StatefulWidget {
  final BuildContext context;

  AlertsDialog({
    @required this.context,
  });

  @override
  AlertsDialogState createState() => AlertsDialogState();
}

class AlertsDialogState extends State<AlertsDialog> {
  ScreenSize screenSize;
  WeatherAlerts weatherAlerts;
  WeatherAlerts copy;
  double fontSize = 16.0;

  @override
  void initState() {
    super.initState();

    screenSize = ScreenSize(widget.context);
    weatherAlerts = WeatherAlerts.getModel(context);
    copy = WeatherAlerts();
    copy.alerts = {}..addAll(weatherAlerts.alerts);
  }

  @override
  Widget build(BuildContext context) {
    return customDialog.AlertDialog(
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      titlePadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      content: Container(
        width: screenSize.pageWidth * 0.85,
        child: ScrollConfiguration(
          behavior: RemoveScrollGlow(),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Set Alerts',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          copy.toggleAllEvents();
                        });
                      },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'All Events',
                              style: TextStyle(),
                            ),
                            SizedBox(width: 6),
                            Icon(copy.getAllEventsIconData()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: copy.alerts.keys.map((String key) {
                          return CheckboxListTile(
                            dense: true,
                            secondary: Icon(copy.icons[key]),
                            title: Text(
                              key,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            activeColor: kAppPrimaryColor,
                            value: copy.alerts[key],
                            onChanged: (bool value) {
                              setState(() {
                                copy.alerts[key] = value;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 23),
                      height: 47.0,
                      width: screenSize.pageWidth * 0.63,
                      child: RaisedButton(
                        elevation: 0.0,
                        onPressed: () {
                          Navigator.of(context).pop(copy);
                        },
                        color: kAppPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kAppBorderRadius),
                        ),
                        child: Text(
                          'save'.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
