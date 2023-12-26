import 'package:flutter/material.dart';
import 'package:irrigation/screens/analytics_page.dart';
import 'package:irrigation/screens/network_detection.dart';
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
      const SprinklerPage(),
      AnalyticsPage(
        isHideBottomNavBar: (isHideBottomNavBar) {
          isHideBottomNavBar
              ? animationController.forward()
              : animationController.reverse();
        },
      ),
      const WeatherPage(),
    ];
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: SizeTransition(
        sizeFactor: animationController,
        axisAlignment: -1.0,
        child: BottomNavigationBar(
          backgroundColor: Styles.greyColor,
          selectedLabelStyle: TextStyle(color: Styles.primaryColor),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Styles.primaryColor,
          unselectedItemColor: Colors.grey.withOpacity(0.7),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.water_drop_rounded),
              label: 'Sprinkler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart_rounded),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud_rounded),
              label: 'Weather',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}