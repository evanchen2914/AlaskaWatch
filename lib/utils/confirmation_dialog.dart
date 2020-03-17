import 'package:alaskawatch/models/screen_size.dart';
import 'package:alaskawatch/utils/constants.dart';
import 'package:alaskawatch/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:alaskawatch/utils/custom_dialog.dart' as customDialog;

class ConfirmationDialog extends StatefulWidget {
  final BuildContext context;
  final String title;
  final String body;

  ConfirmationDialog({
    @required this.context,
    @required this.title,
    this.body,
  });

  @override
  _ConfirmationDialogState createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  ScreenSize screenSize;
  double fontSize = 16.0;

  @override
  void initState() {
    super.initState();

    screenSize = ScreenSize(widget.context);
  }

  @override
  Widget build(BuildContext context) {
    return customDialog.AlertDialog(
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      titlePadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      content: Container(
        width: screenSize.pageWidth * 0.85,
        child: Container(
          padding:
              EdgeInsets.symmetric(horizontal: screenSize.pageWidth * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: screenSize.horizontalPadding),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              widget.body == null || widget.body.isEmpty
                  ? Container()
                  : Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenSize.pageWidth * 0.02),
                      child: Column(
                        children: <Widget>[
                          Container(height: 16),
                          Text(
                            widget.body,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
              Container(
                margin: EdgeInsets.symmetric(
                    vertical: screenSize.horizontalPadding),
                height: 47.0,
                width: screenSize.pageWidth * 0.665,
                child: RaisedButton(
                  elevation: 0.0,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  color: kAppPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kAppBorderRadius),
                  ),
                  child: Text(
                    'ok'.toUpperCase(),
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
      ),
    );
  }
}
