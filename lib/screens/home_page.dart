import 'package:flutter/material.dart';
import 'package:irrigation/screens/analytics_page.dart';
import 'package:irrigation/screens/sprinkler_page.dart';
import 'package:irrigation/screens/weather_page.dart';
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

  Color? _bottomNavBarColor = Styles.greyColor;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _updateBottomNavBarColor();
    });
  }

  void _updateBottomNavBarColor() {
    _bottomNavBarColor = _selectedIndex == 0 ? Colors.blue[400] : Styles.greyColor;
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
      const LicensePage(),
      const SprinklerPage(),
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
    _updateBottomNavBarColor();

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _bottomNavBarColor,
        selectedLabelStyle: TextStyle(color: Styles.primaryColor),
        selectedItemColor: Styles.primaryColor,
        unselectedItemColor: Colors.grey.withOpacity(0.7),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_rounded),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_rounded),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop_rounded),
            label: 'Sprinkler',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      // SizeTransition(
      //   sizeFactor: animationController,
      //   axisAlignment: -1.0,
      //   child:
      // ),
    );
  }
}