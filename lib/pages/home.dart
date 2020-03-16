import 'dart:ui';

import 'package:alaskawatch/models/current_weather.dart';
import 'package:alaskawatch/models/screen_size.dart';
import 'package:alaskawatch/models/settings_edit.dart';
import 'package:alaskawatch/models/user.dart';
import 'package:alaskawatch/pages/weather_details.dart';
import 'package:alaskawatch/utils/constants.dart';
import 'package:alaskawatch/utils/functions.dart';
import 'package:alaskawatch/utils/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScreenSize screenSize;
  User user;
  SettingsEdit settingsEdit;
  SharedPreferences sharedPrefs;

  bool showSplash = true;
  bool showLoading = false;
  bool showEdit = false;

  int currentTabIndex = 0;
  List bottomNavBarTiles = [];
  List bottomTabPages = [];

  TextEditingController searchController = TextEditingController();
  TextEditingController homeController = TextEditingController();
  TextEditingController workController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool keyboardVisible = false;

  @override
  void initState() {
    super.initState();

    setUp();
  }

  @override
  void dispose() {
    super.dispose();

    searchController?.dispose();
    homeController?.dispose();
    workController?.dispose();
  }

  void setUp() async {
    bottomNavBarTiles = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        title: Text('Home'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.favorite),
        title: Text('Favorites'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        title: Text('Profile'),
      ),
    ];

    user = User();

    sharedPrefs = await SharedPreferences.getInstance();

    /// set to true to skip location
//    bool testMode = true;
    bool testMode = false;

    Position position = await getUserLocation(testMode: testMode);

    if (position != null) {
      String zip = await getZipFromPosition(position).catchError((e) {
        showToast(kCurrentLocationError);
      });

      if (zip != null) {
        await sharedPrefs.setString(kPrefsCurrent, zip);
        user.updateData(currentZip: zip);
      }
    }

    if (sharedPrefs.containsKey(kPrefsRecentSearches)) {
      var recentSearches = sharedPrefs.getStringList(kPrefsRecentSearches);
      user.updateData(recentSearches: recentSearches);
    }

    if (sharedPrefs.containsKey(kPrefsFavorites)) {
      var favorites = sharedPrefs.getStringList(kPrefsFavorites);
      user.updateData(favorites: favorites);

      if (user.favorites != null && user.favorites.isNotEmpty) {
        for (var zip in user.favorites) {
          var currentWeather = user.getCachedCurrentWeather(zip);

          if (currentWeather == null) {
            currentWeather = await getDataFromWeatherbit(
                    zip: zip, weatherType: WeatherType.current)
                .catchError((e) {});
          }

          if (currentWeather != null) {
            user.addFavoriteCurrentWeather(currentWeather);
          } else {
            user.removeFavoriteCurrentWeather(zip);
            user.removeFavorite(zip);
            await sharedPrefs.setStringList(kPrefsFavorites, user.favorites);
          }
        }
      }
    }

    if (sharedPrefs.containsKey(kPrefsCurrent)) {
      user.updateData(currentZip: sharedPrefs.getString(kPrefsCurrent));
      var currentWeather = user.getCachedCurrentWeather(user.currentZip);

      if (currentWeather == null) {
        currentWeather = await getDataFromWeatherbit(
                zip: user.currentZip, weatherType: WeatherType.current)
            .catchError((e) {});
      }

      if (currentWeather != null) {
        user.updateData(currentWeather: currentWeather);
      } else {
        user.updateData(currentZip: '', currentWeather: null);
        await sharedPrefs.remove(kPrefsCurrent);
      }
    }

    if (sharedPrefs.containsKey(kPrefsHome)) {
      var home = sharedPrefs.getString(kPrefsHome);
      user.updateData(homeZip: home);
      var homeWeather = user.getCachedCurrentWeather(home);

      if (homeWeather == null) {
        homeWeather = await getDataFromWeatherbit(
                zip: home, weatherType: WeatherType.current)
            .catchError((e) {});
      }

      if (homeWeather != null) {
        user.updateData(homeWeather: homeWeather);
      } else {
        user.updateData(homeZip: '', homeWeather: null);
        await sharedPrefs.remove(kPrefsHome);
      }
    }

    if (sharedPrefs.containsKey(kPrefsWork)) {
      var work = sharedPrefs.getString(kPrefsWork);
      user.updateData(workZip: work);
      var workWeather = user.getCachedCurrentWeather(work);

      if (workWeather == null) {
        workWeather = await getDataFromWeatherbit(
                zip: work, weatherType: WeatherType.current)
            .catchError((e) {});
      }

      if (workWeather != null) {
        user.updateData(workWeather: workWeather);
      } else {
        user.updateData(workZip: '', workWeather: null);
        await sharedPrefs.remove(kPrefsWork);
      }
    }

    setState(() {
      showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSplash) {
      return splashScreen();
    }

    if (showLoading) {
      return loadingScreen();
    }

    screenSize = ScreenSize(context);

    if (MediaQuery.of(context).viewInsets.bottom == 0) {
      keyboardVisible = false;
    } else {
      keyboardVisible = true;
    }

    bottomTabPages = <Widget>[
      homeTabPage(),
      favoritesTabPage(),
      profileTabPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentTabIndex,
        children: bottomTabPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: kAppSecondaryColor,
        unselectedItemColor: kAppTertiaryColor,
        backgroundColor: kAppPrimaryColor,
        items: bottomNavBarTiles,
        currentIndex: currentTabIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
          });
        },
      ),
    );
  }

  Future<void> refreshHome() async {
    setState(() {
      showLoading = true;
    });

    if (user.currentZip != null && user.currentZip.isNotEmpty) {
      var currentWeather = await getDataFromWeatherbit(
              zip: user.currentZip, weatherType: WeatherType.current)
          .catchError((e) {});

      if (currentWeather != null) {
        user.updateData(currentWeather: currentWeather);
      }
    }

    if (user.homeZip != null && user.homeZip.isNotEmpty) {
      var homeWeather = await getDataFromWeatherbit(
              zip: user.homeZip, weatherType: WeatherType.current)
          .catchError((e) {});

      if (homeWeather != null) {
        user.updateData(homeWeather: homeWeather);
      }
    }

    if (user.workZip != null && user.workZip.isNotEmpty) {
      var workWeather = await getDataFromWeatherbit(
              zip: user.workZip, weatherType: WeatherType.current)
          .catchError((e) {});

      if (workWeather != null) {
        user.updateData(workWeather: workWeather);
      }
    }

    setState(() {
      showLoading = false;
    });
  }

  Widget homeTabPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          kAppName,
          style: TextStyle(
            color: kAppSecondaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: kAppVerticalPadding),
        child: RefreshIndicator(
          color: kAppPrimaryColor,
          onRefresh: refreshHome,
          child: ScrollConfiguration(
            behavior: RemoveScrollGlow(),
            child: ListView(
              children: <Widget>[
                searchBar(),
                user.currentZip == null ||
                        user.currentZip.isEmpty ||
                        user.currentWeather == null
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.horizontalPadding),
                        child: Column(
                          children: <Widget>[
                            headerText('Current Location'),
                            InkWell(
                              onTap: () {
                                navToWeatherDetails(
                                    currentWeather: user.currentWeather);
                              },
                              child: currentWeatherCard(
                                  context: context,
                                  currentWeather: user.currentWeather),
                            ),
                          ],
                        ),
                      ),
                user.homeZip == null ||
                        user.homeZip.isEmpty ||
                        user.homeWeather == null
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.horizontalPadding),
                        child: Column(
                          children: <Widget>[
                            headerText('Home'),
                            InkWell(
                              onTap: () {
                                navToWeatherDetails(
                                    currentWeather: user.homeWeather);
                              },
                              child: currentWeatherCard(
                                  context: context,
                                  currentWeather: user.homeWeather),
                            ),
                          ],
                        ),
                      ),
                user.workZip == null ||
                        user.workZip.isEmpty ||
                        user.workWeather == null
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.horizontalPadding),
                        child: Column(
                          children: <Widget>[
                            headerText('Work'),
                            InkWell(
                              onTap: () {
                                navToWeatherDetails(
                                    currentWeather: user.workWeather);
                              },
                              child: currentWeatherCard(
                                  context: context,
                                  currentWeather: user.workWeather),
                            ),
                          ],
                        ),
                      ),
                SizedBox(height: screenSize.verticalPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget favoritesTabPage() {
    List<Widget> widgets = [];

    if (user.favoritesCurrentWeather.isNotEmpty) {
      for (String zip in user.favoritesCurrentWeather.keys) {
        CurrentWeather currentWeather = user.favoritesCurrentWeather[zip];

        widgets.add(
          InkWell(
            onTap: () {
              navToWeatherDetails(currentWeather: currentWeather);
            },
            child: currentWeatherCard(
                context: context, currentWeather: currentWeather),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: TextStyle(
            color: kAppSecondaryColor,
          ),
        ),
//        leading: showEdit
//            ? IconButton(
//          icon: Icon(
//            Icons.close,
//            color: kAppSecondaryColor,
//          ),
//          onPressed: cancelEdit,
//        )
//            : null,
//        actions: <Widget>[
//          IconButton(
//            onPressed: () {
//              if (showEdit) {
//                saveEdit();
//              } else {
//                startEdit();
//              }
//            },
//            icon: Icon(
//              showEdit ? Icons.done : Icons.edit,
//              color: kAppSecondaryColor,
//            ),
//          ),
//        ],
        centerTitle: true,
      ),
      body: ScrollConfiguration(
        behavior: RemoveScrollGlow(),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.horizontalPadding,
                vertical: screenSize.verticalPadding,
              ),
              child: Column(
                children: widgets,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileTabPage() {
    Widget locationPrefBox({Widget child}) {
      return Container(
        height: 55,
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200],
              spreadRadius: 4,
              blurRadius: 5,
            ),
          ],
          border: Border.all(
            color: showEdit ? Colors.grey[300] : kAppPrimaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(kAppBorderRadius),
        ),
        child: child,
      );
    }

    Widget locationPrefTextField(
        {TextEditingController controller, String type}) {
      double fontSize = 18.0;

      return Row(
        children: <Widget>[
          Container(
            width: 65,
            child: Text(
              type,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w300,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(5),
              ],
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.left,
              cursorColor: kAppPrimaryColor,
              decoration: InputDecoration(
                hintText: 'Zip code',
                hintStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      );
    }

    Widget locationPrefInfo({String zip, String type}) {
      double fontSize = 18.0;

      return InkWell(
        onTap: () {
          startEdit();
        },
        child: Container(
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Container(
                width: 65,
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  zip,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: kAppSecondaryColor,
          ),
        ),
        leading: showEdit
            ? IconButton(
                icon: Icon(
                  Icons.close,
                  color: kAppSecondaryColor,
                ),
                onPressed: cancelEdit,
              )
            : null,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              if (showEdit) {
                saveEdit();
              } else {
                startEdit();
              }
            },
            icon: Icon(
              showEdit ? Icons.done : Icons.edit,
              color: kAppSecondaryColor,
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.horizontalPadding,
        ),
        child: ScrollConfiguration(
          behavior: RemoveScrollGlow(),
          child: ListView(
            children: <Widget>[
              headerText('Location Preferences'),
              locationPrefBox(
                child: showEdit
                    ? locationPrefTextField(
                        controller: homeController,
                        type: 'Home',
                      )
                    : locationPrefInfo(
                        zip:
                            '${user.homeZip != null && user.homeZip.isNotEmpty ? user.homeZip : 'Not set'}',
                        type: 'Home',
                      ),
              ),
              SizedBox(height: screenSize.verticalPadding),
              locationPrefBox(
                child: showEdit
                    ? locationPrefTextField(
                        controller: workController,
                        type: 'Work',
                      )
                    : locationPrefInfo(
                        zip:
                            '${user.workZip != null && user.workZip.isNotEmpty ? user.workZip : 'Not set'}',
                        type: 'Work',
                      ),
              ),
              SizedBox(height: screenSize.verticalPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget logo() {
    return Container(
      height: 58,
      child: Center(
        child: Text(
          kAppName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: kAppPrimaryColor,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget searchBar() {
    double rowHeight = 50;
    Color iconColor = Colors.grey[500];

    List<Widget> widgets = [
      Container(
        height: rowHeight,
        child: TextField(
          controller: searchController,
          inputFormatters: [
            LengthLimitingTextInputFormatter(5),
          ],
          textInputAction: TextInputAction.search,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.left,
          cursorColor: kAppPrimaryColor,
          focusNode: focusNode,
          onSubmitted: (value) async {
            if (value.length != 5) {
              FocusScope.of(context).requestFocus(focusNode);
              return showToast('Zip must be 5 digits');
            }

            handleZipCodeOnPress(value);
          },
          decoration: InputDecoration(
            hintText: 'Search by Zip',
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(Icons.search),
            suffixIcon: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                setState(() {
                  searchController.clear();
                  FocusScope.of(context).requestFocus(FocusNode());
                });
              },
              child: Icon(Icons.close),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kAppBorderRadius),
              borderSide: BorderSide(
                color: Colors.grey[400],
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kAppBorderRadius),
              borderSide: BorderSide(
                color: kAppPrimaryColor,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.all(0),
          ),
        ),
      ),
    ];

    if (user.recentSearches.isNotEmpty && keyboardVisible) {
      for (var zip in user.recentSearches) {
        widgets.add(
          InkWell(
            onTap: () {
              handleZipCodeOnPress(zip);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: rowHeight,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.restore,
                    color: iconColor,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      zip,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await sharedPrefs.setStringList(
                          kPrefsRecentSearches, user.recentSearches);

                      setState(() {
                        user.removeRecentSearch(zip);
                      });
                    },
                    child: Icon(
                      Icons.delete,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return Container(
      height: keyboardVisible
          ? rowHeight + rowHeight * user.recentSearches.length
          : rowHeight,
      margin: EdgeInsets.symmetric(horizontal: screenSize.horizontalPadding),
      child: Column(
        children: widgets,
      ),
    );
  }

  void handleZipCodeOnPress(String zip) async {
    var currentWeather =
        await getDataFromWeatherbit(zip: zip, weatherType: WeatherType.current)
            .catchError((e) {
      showToast(e.toString());
    });

    if (currentWeather != null) {
      user.addRecentSearch(zip);
      await sharedPrefs.setStringList(
          kPrefsRecentSearches, user.recentSearches);

      navToWeatherDetails(currentWeather: currentWeather);
    }
  }

  void navToWeatherDetails({CurrentWeather currentWeather}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ScopedModel<CurrentWeather>(
            model: currentWeather,
            child: ScopedModel<User>(
              model: user,
              child: WeatherDetails(zip: currentWeather.zip),
            ),
          );
        },
      ),
    );
  }

  void startEdit() {
    if (showEdit) {
      return;
    }

    showEdit = true;

    settingsEdit = SettingsEdit(user: user);

    if (settingsEdit.home != null && settingsEdit.home.isNotEmpty) {
      homeController = TextEditingController(text: settingsEdit.home);
    }

    if (settingsEdit.work != null && settingsEdit.work.isNotEmpty) {
      workController = TextEditingController(text: settingsEdit.work);
    }

    setState(() {});
  }

  void saveEdit() async {
    if (!showEdit) {
      return;
    }

    setState(() {
      showLoading = true;
    });

    String home = homeController.text;
    String work = workController.text;
    var homeWeather;
    var workWeather;

    if (home != null && home.isNotEmpty) {
      homeWeather = user.getCachedCurrentWeather(home);

      if (homeWeather == null) {
        homeWeather = await getDataFromWeatherbit(
                zip: home, weatherType: WeatherType.current)
            .catchError((e) {
          setState(() {
            showLoading = false;
            showToast(kInvalidZipCode);
          });

          return;
        });
      }
    }

    if (work != null && work.isNotEmpty) {
      workWeather = user.getCachedCurrentWeather(work);

      if (workWeather == null) {
        workWeather = await getDataFromWeatherbit(
                zip: work, weatherType: WeatherType.current)
            .catchError((e) {
          setState(() {
            showLoading = false;
            showToast(kInvalidZipCode);
          });

          return;
        });
      }
    }

    if (home != null && home.isNotEmpty && homeWeather != null) {
      user.updateData(homeZip: home, homeWeather: homeWeather);
      await sharedPrefs.setString(kPrefsHome, home);
    } else if (home != user.homeZip) {
      user.updateData(homeZip: '', homeWeather: null);
      sharedPrefs.remove(kPrefsHome);
    }

    if (work != null && work.isNotEmpty && workWeather != null) {
      user.updateData(workZip: work, workWeather: workWeather);
      await sharedPrefs.setString(kPrefsWork, work);
    } else if (work != user.workZip) {
      user.updateData(workZip: '', workWeather: null);
      sharedPrefs.remove(kPrefsWork);
    }

    showToast('Settings saved');
    FocusScope.of(context).requestFocus(FocusNode());
    showLoading = false;
    showEdit = false;

    setState(() {});
  }

  void cancelEdit() {
    if (!showEdit) {
      return;
    }

    FocusScope.of(context).requestFocus(FocusNode());
    showEdit = false;
    homeController.clear();
    workController.clear();
    setState(() {});
  }
}
