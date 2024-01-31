import 'package:flutter/material.dart';
import 'package:irrigation/screens/analytics_page.dart';
import 'package:irrigation/screens/prediction_page.dart';
import 'package:irrigation/screens/settings_page.dart';
import 'package:irrigation/screens/sprinkler_page.dart';
import 'package:irrigation/screens/weather_page.dart';
import 'package:irrigation/utils/colors.dart';
import 'package:irrigation/utils/styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  int _selectedIndex = 0;
  late AnimationController animationController;
  late List<Widget> _pages;

  Color? _bottomNavBarColor;
  Color? _bottomNavItemColor;
  Color? _bottomNavSelectedColor;

  void updateBottomNavBarColor(bool isSprinklerOn) {
    setState(() {
      _bottomNavBarColor = isSprinklerOn ? Colors.blue[400] : Colors.white;
      _bottomNavItemColor = isSprinklerOn ? Colors.white : Colors.black;
      _bottomNavSelectedColor = isSprinklerOn ? Colors.white : AppColors.primaryColor;

      print('Bottom nav bar color: $_bottomNavBarColor');
      print('Bottom nav item color: $_bottomNavItemColor');
      print('Bottom nav selected color: $_bottomNavSelectedColor');
    });
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _pages = <Widget>[
      AnalyticsPage(
        isHideBottomNavBar: (isHideBottomNavBar) {
          isHideBottomNavBar
              ? animationController.forward()
              : animationController.reverse();
        },
      ),
      const PredictionPage(),
      const WeatherPage(),
      SprinklerPage(
        updateBottomNavBarColor: updateBottomNavBarColor,
      ),
      const SettingsPage(),
      // const WeatherPage(),
    ];
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Home page build: $_bottomNavBarColor');
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.0, color: Colors.white),
          ),
        ),
        child: BottomNavigationBar(
          selectedLabelStyle: TextStyle(color: Styles.primaryColor),
          selectedItemColor: _bottomNavSelectedColor,
          unselectedItemColor: _bottomNavItemColor?.withOpacity(0.7),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart_rounded),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stars_rounded),
              label: 'Prediction',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud_rounded),
              label: 'Weather',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.water_drop_rounded),
              label: 'Motor',
              backgroundColor: _bottomNavBarColor,
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: 'Settings'
            )
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
      // SizeTransition(
      //   sizeFactor: animationController,
      //   axisAlignment: -1.0,
      //   child:
      // ),
    );
  }
}