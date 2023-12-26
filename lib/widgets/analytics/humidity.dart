import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Humidity extends StatefulWidget {
  final Function(bool) isHideBottomNavBar;

  const Humidity({super.key, required this.isHideBottomNavBar});

  @override
  State<Humidity> createState() => _HumidityState();
}

class _HumidityState extends State<Humidity> with AutomaticKeepAliveClientMixin<Humidity> {

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            widget.isHideBottomNavBar(true);
            break;
          case ScrollDirection.reverse:
            widget.isHideBottomNavBar(false);
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: const Scaffold(
        body: Center(
          child: Center(
            child: Text('Humidity'),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}