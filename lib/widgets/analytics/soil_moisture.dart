import 'package:flutter/material.dart';

class SoilMoisture extends StatefulWidget {
  const SoilMoisture({super.key});

  @override
  State<SoilMoisture> createState() => _SoilMoistureState();
}

class _SoilMoistureState extends State<SoilMoisture> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Soil Moisture'),
    );
  }
}