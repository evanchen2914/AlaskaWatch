import 'dart:ui';

import 'package:alaskawatch/models/settings_edit.dart';
import 'package:alaskawatch/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:alaskawatch/models/current_weather.dart';
import 'package:alaskawatch/models/screen_size.dart';
import 'package:alaskawatch/models/weather_data.dart';
import 'package:alaskawatch/pages/search_results.dart';
import 'package:alaskawatch/utils/constants.dart';
import 'package:alaskawatch/utils/functions.dart';
import 'package:alaskawatch/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
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
  SharedPreferences prefs;

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

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() {
          keyboardVisible = visible;
        });
      },
    );

    user = User();

    prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(kPrefsRecentSearches)) {
      var recentSearches = prefs.getStringList(kPrefsRecentSearches);
      user.updateData(recentSearches: recentSearches);
    }

    if (prefs.containsKey(kPrefsCurrent)) {
      var current = prefs.getString(kPrefsCurrent);
      user.updateData(current: current);
      var weatherData = await getWeatherData(zip: current).catchError((e) {});

      if (weatherData != null) {
        user.updateData(currentWeatherData: weatherData);
      }
    }

    if (prefs.containsKey(kPrefsHome)) {
      var home = prefs.getString(kPrefsHome);
      user.updateData(home: home);
      var weatherData = await getWeatherData(zip: home).catchError((e) {});

      if (weatherData != null) {
        user.updateData(homeWeatherData: weatherData);
      }
    }

    if (prefs.containsKey(kPrefsWork)) {
      var work = prefs.getString(kPrefsWork);
      user.updateData(work: work);
      var weatherData = await getWeatherData(zip: work).catchError((e) {});

      if (weatherData != null) {
        user.updateData(workWeatherData: weatherData);
      }
    }

    /// set to true to skip location
//    bool testMode = true;
    bool testMode = false;

    Position position = await getUserLocation(testMode: testMode);

    String zip = await getZipFromPosition(position).catchError((e) {
      showToast(kCurrentLocationError);
    });

    if (zip != null) {
      prefs.setString(kPrefsCurrent, zip);
      user.updateData(current: zip);
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

  Future<void> refresh() async {
    setState(() {
      showLoading = true;
    });

    await Future.delayed(Duration(seconds: 2));

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
          onRefresh: refresh,
          child: ScrollConfiguration(
            behavior: RemoveScrollGlow(),
            child: ListView(
              children: <Widget>[
                searchBar(),
                user.currentWeatherData == null
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.horizontalPadding),
                        child: Column(
                          children: <Widget>[
                            headerText('Current Location'),
                            InkWell(
                              onTap: () {
                                navToSearchResults(
                                    weatherData: user.currentWeatherData);
                              },
                              child: currentWeatherCard(
                                  context: context,
                                  currentWeather:
                                      user.currentWeatherData.currentWeather),
                            ),
                          ],
                        ),
                      ),
                user.homeWeatherData == null
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.horizontalPadding),
                        child: Column(
                          children: <Widget>[
                            headerText('Home'),
                            InkWell(
                              onTap: () {
                                navToSearchResults(
                                    weatherData: user.homeWeatherData);
                              },
                              child: currentWeatherCard(
                                  context: context,
                                  currentWeather:
                                      user.homeWeatherData.currentWeather),
                            ),
                          ],
                        ),
                      ),
                user.workWeatherData == null
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.horizontalPadding),
                        child: Column(
                          children: <Widget>[
                            headerText('Work'),
                            InkWell(
                              onTap: () {
                                navToSearchResults(
                                    weatherData: user.workWeatherData);
                              },
                              child: currentWeatherCard(
                                  context: context,
                                  currentWeather:
                                      user.workWeatherData.currentWeather),
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
    return Scaffold(
      body: ScrollConfiguration(
        behavior: RemoveScrollGlow(),
        child: ListView(
          children: <Widget>[],
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
          Text(
            type,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 12),
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

      return Container(
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            Text(
              type,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 12),
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
                        zip: '${(user.homeZip) ?? 'Not set'}',
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
                        zip: '${(user.workZip) ?? 'Not set'}',
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

  Widget headerText(String text) {
    return Container(
      height: 59,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
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
                    onTap: () {
                      setState(() {
                        user.removeRecentSearch(zip);
                        prefs.setStringList(
                            kPrefsRecentSearches, user.recentSearches);
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
    setState(() {
      showLoading = true;
    });

    var weatherData = await getWeatherData(zip: zip).catchError((e) {
      setState(() {
        showLoading = false;
        showToast(e.toString());
      });
    });

    if (weatherData != null) {
      user.addRecentSearch(zip);
      prefs.setStringList(kPrefsRecentSearches, user.recentSearches);

      setState(() {
        showLoading = false;
      });

      navToSearchResults(weatherData: weatherData);
    } else {
      setState(() {
        showLoading = false;
      });
    }
  }

  void navToSearchResults({WeatherData weatherData}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ScopedModel<WeatherData>(
            model: weatherData,
            child: SearchResults(),
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
    var homeWeatherData;
    var workWeatherData;

    if (home != null && home.isNotEmpty) {
      homeWeatherData = await getWeatherData(zip: home).catchError((e) {
        setState(() {
          showLoading = false;
          showToast(kInvalidZipCode);
        });

        return;
      });
    }

    if (work != null && work.isNotEmpty) {
      workWeatherData = await getWeatherData(zip: work).catchError((e) {
        setState(() {
          showLoading = false;
          showToast(kInvalidZipCode);
        });

        return;
      });
    }

    if (home != null && home.isNotEmpty && homeWeatherData != null) {
      user.updateData(home: home);
      prefs.setString(kPrefsHome, home);
    } else {
      user.updateData(home: null);
      prefs.remove(kPrefsHome);
    }

    if (work != null && work.isNotEmpty && workWeatherData != null) {
      user.updateData(work: work);
      prefs.setString(kPrefsWork, work);
    } else {
      user.updateData(work: null);
      prefs.remove(kPrefsWork);
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
