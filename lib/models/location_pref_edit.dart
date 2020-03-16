import 'package:alaskawatch/models/user.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class LocationPrefEdit extends Model {
  static LocationPrefEdit getModel(BuildContext context) =>
      ScopedModel.of<LocationPrefEdit>(context);

  String home;
  String work;

  LocationPrefEdit({User user}) {
    home = user.homeZip;
    work = user.workZip;
  }
}
