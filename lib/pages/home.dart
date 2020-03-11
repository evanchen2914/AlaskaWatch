import 'package:alaskawatch/utils/constants.dart';
import 'package:alaskawatch/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences prefs;
  bool isLoading = true;

  int currentTabIndex = 0;
  List bottomNavBarTiles = [];
  List bottomTabPages = [];

  @override
  void initState() {
    super.initState();

    setUp();
  }

  void setUp() {
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
  }

  @override
  Widget build(BuildContext context) {
    bottomTabPages = <Widget>[
      homeTabPage(),
      favoritesTabPage(),
      profileTabPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AlaskaWatch',
          style: TextStyle(
            color: kSecondaryColor,
          ),
        ),
        actions: <Widget>[
          currentTabIndex == 0
              ? IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: kSecondaryColor,
                  ),
                  tooltip: 'Refresh',
                  onPressed: () {
                    showToast('Button pressed');
                  },
                )
              : Container(),
        ],
      ),
      body: IndexedStack(
        index: currentTabIndex,
        children: bottomTabPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: kSecondaryColor,
        unselectedItemColor: Colors.grey[300],
        backgroundColor: kPrimaryColor,
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

  Widget homeTabPage() {
    return Text('home');
  }

  Widget favoritesTabPage() {
    return Text('favorites');
  }

  Widget profileTabPage() {
    return Text('profile');
  }
}
