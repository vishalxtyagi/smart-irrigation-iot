import 'package:flutter/material.dart';

class SprinklerPage extends StatefulWidget {
  const SprinklerPage({super.key});

  @override
  State<SprinklerPage> createState() => _SprinklerPageState();
}

class _SprinklerPageState extends State<SprinklerPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Sprinkler'),
    );
  }
}