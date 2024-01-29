import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:irrigation/screens/home_page.dart';
import 'package:irrigation/utils/colors.dart';
import 'package:irrigation/utils/prefs.dart';
import 'package:sklite/SVM/SVM.dart';
import 'package:sklite/utils/io.dart';

import 'network_detection.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  DatabaseReference _databaseReference = FirebaseDatabase.instance.ref('FirebaseIOT');
  Map<dynamic, dynamic>? firebaseData;
  List<String> units = [];
  String? selectedUnit;
  int? prediction;
  SVC? svc;

  @override
  void initState() {
    // checkSetup();
    super.initState();

    loadModel("assets/svm.json").then((x) {
      svc = SVC.fromMap(json.decode(x));
    });
  }


  Future<void> initFirebase() async {
    _databaseReference = FirebaseDatabase.instance.ref("FirebaseIOT");
    // Set up a listener for changes in the sprinkler state
  }

  Future<void> listenDb(String unit) async {
    _databaseReference.child(unit).keepSynced(true);
    _databaseReference.child(unit).onValue.listen((DatabaseEvent event) {
      final dynamic snapshotValue = event.snapshot.value;
      if (snapshotValue != null && snapshotValue is Map<dynamic, dynamic>) {
        firebaseData = snapshotValue; // Assign Firebase data to firebaseData

        // Fetch data when new data is received
        fetchData(unit);
      } else {
        print('Invalid snapshot value or null data received');
      }
    });
  }

  Future<void> loadAllUnits() async {
    String? savedUnit = await AppPrefs().getSelectedUnit();
    final devices = await AppPrefs().getDevices();
    setState(() {
      units = List.generate(devices.length, (index) => devices[index]['id']);
      selectedUnit = savedUnit ?? units[0];
      listenDb(selectedUnit!);
    });
  }

  Future<List<DropdownMenuItem<String>>> _buildDropdownItems() async {
    // show units as Unit 1, Unit 2, etc.
    return List.generate(units.length, (index) {
      return DropdownMenuItem<String>(
        value: units[index],
        child: Text('Unit ${index + 1}'),
      );
    });
  }

  List<double> getFeatures(double temperature, double humidity, double soilMoisture, int day, int crop) {
    List<double> cropFeatures = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    cropFeatures[crop] = 1;
    return [day.toDouble(), soilMoisture, temperature, humidity, ...cropFeatures];
  }

  Future<void> fetchData(unit) async {
    final startDay = await AppPrefs().getStartDay(unit);
    final crop = await AppPrefs().getCrop(unit);

    if (firebaseData != null) {
      final List<double> features = getFeatures(
        firebaseData!['temperature'].last['value'],
        firebaseData!['humidity'].last['value'],
        firebaseData!['soilMoisture'].last['value'],
        DateTime.now().difference(startDay).inDays,
        crop,
      );
      setState(() {
        prediction = svc!.predict(features);
        print(prediction);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Prediction',
        ),
        actions: [
          FutureBuilder(future: _buildDropdownItems(), builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              print(snapshot.data);
              return DropdownButtonHideUnderline(
                child: DropdownButton(
                  value: selectedUnit,
                  items: snapshot.data,
                  onChanged: (value) {
                    setState(() {
                      selectedUnit = value!;
                      AppPrefs().saveSelectedUnit(value);
                      listenDb(selectedUnit!);
                    });
                  },
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
        backgroundColor: AppColors.accentColor,
        shape: const Border(),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const Gap(20),
              if (prediction != null)
                Text(
                  'Prediction: ${prediction == 1 ? 'On' : 'Off'}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              const Gap(20),
              if (prediction != null)
                Text(
                  'The sprinkler is predicted to be ${prediction == 1 ? 'on' : 'off'}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
            ]
          ),
        ),
      ),
    );
  }
}
