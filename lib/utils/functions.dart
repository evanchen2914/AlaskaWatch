import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIos: 1,
    fontSize: 15.5,
    backgroundColor: Colors.grey[800],
  );
}

// testing purposes only
void qq(String message) {
  debugPrint('========== $message');
}
