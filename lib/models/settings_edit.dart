import 'package:alaskawatch/models/user.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class SettingsEdit extends Model {
  static SettingsEdit getModel(BuildContext context) =>
      ScopedModel.of<SettingsEdit>(context);

  String home;
  String work;

  SettingsEdit({User user}) {
    home = user.homeZip;
    work = user.workZip;
  }
}
