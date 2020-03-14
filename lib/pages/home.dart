import 'package:alaskawatch/models/user.dart';
import 'package:flutter/cupertino.dart';
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

enum LocationPref {
  home,
  work,
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User user;
  ScreenSize screenSize;
  SharedPreferences prefs;
  bool showSplash = true;
  bool showLoading = false;

  int currentTabIndex = 0;
  List bottomNavBarTiles = [];
  List bottomTabPages = [];

  TextEditingController searchController = TextEditingController();
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

    prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(kPrefsRecentSearches)) {
      var recentSearches = prefs.getStringList(kPrefsRecentSearches);
      user.updateData(recentSearches: recentSearches);
    }

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() {
          keyboardVisible = visible;
        });
      },
    );

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
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenSize.horizontalPadding),
                  child: headerText('Current Location'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenSize.horizontalPadding),
                  child: headerText('Saved Locations'),
                ),
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
    Widget locationPrefEditTile({LocationPref pref, String text}) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200],
              spreadRadius: 4,
              blurRadius: 5,
            ),
          ],
          border: Border.all(color: kAppPrimaryColor, width: 2.5),
          borderRadius: BorderRadius.circular(kAppBorderRadius),
        ),
        child: Center(
          child: Text(
            '$text',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.horizontalPadding,
        ),
        child: ScrollConfiguration(
          behavior: RemoveScrollGlow(),
          child: ListView(
            children: <Widget>[
              headerText('Settings'),
              locationPrefEditTile(
                text: 'Home',
                pref: LocationPref.home,
              ),
              SizedBox(height: 30),
              locationPrefEditTile(
                text: 'Work',
                pref: LocationPref.home,
              ),
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

            navToSearchResults(value);
          },
          decoration: InputDecoration(
            hintText: 'Search by Zip',
            hintStyle: TextStyle(
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(Icons.search),
            suffixIcon: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                setState(() {
                  searchController.clear();
//                  FocusScope.of(context).requestFocus(FocusNode());
                });
              },
              child: Icon(Icons.close),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kAppBorderRadius),
              borderSide: BorderSide(
                color: Colors.grey[400],
                width: 2.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kAppBorderRadius),
              borderSide: BorderSide(
                color: kAppPrimaryColor,
                width: 2.5,
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
              navToSearchResults(zip);
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

  void navToSearchResults(String zip) async {
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
    } else {
      setState(() {
        showLoading = false;
      });
    }
  }
}
