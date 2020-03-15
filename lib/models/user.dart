import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class User extends Model {
  static User getModel(BuildContext context) => ScopedModel.of<User>(context);

  List<String> recentSearches = [];
  String current;
  String home;
  String work;

  User();

  void updateData(
      {List<String> recentSearches, String current, String home, String work}) {
    this.recentSearches = []..addAll(recentSearches ?? this.recentSearches);
    this.current = current ?? this.current;
    this.home = home ?? this.home;
    this.work = work ?? this.work;

    notifyListeners();
  }

  void addRecentSearch(String zip) {
    if (!recentSearches.contains(zip)) {
      recentSearches.add(zip);

      notifyListeners();
    }
  }

  void removeRecentSearch(String zip) {
    if (recentSearches.contains(zip)) {
      recentSearches.remove(zip);

      notifyListeners();
    }
  }
}
