import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:irrigation/screens/home_page.dart';
import 'package:irrigation/utils/colors.dart';
import 'package:irrigation/utils/prefs.dart';
import 'package:irrigation/utils/shared.dart';
import 'package:provider/provider.dart';
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
  bool showEmtpyState = false;

  @override
  void initState() {
    // checkSetup();
    super.initState();

    initFirebase();
    loadAllUnits();

    loadModel("assets/svm.json").then((x) {
      svc = SVC.fromMap(json.decode(x));
      print('Model loaded');
    });
  }


  Future<void> initFirebase() async {
    _databaseReference = FirebaseDatabase.instance.ref("FirebaseIOT");
    // Set up a listener for changes in the sprinkler state
    print('inti fb Model loaded');
  }

  Future<void> listenDb(String unit) async {
    print('Model loaded listen');
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
      fetchData(selectedUnit!);
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
    print('Model loaded fetch');
    if (firebaseData != null) {
      print('Firebase data: $firebaseData');

      final List<double> features = getFeatures(
        double.parse(firebaseData!['current']['temperature'].toString()),
        double.parse(firebaseData!['current']['humidity'].toString()),
        double.parse(firebaseData!['current']['soilMoisture'].toString()),
        DateTime.now().difference(DateTime.fromMicrosecondsSinceEpoch(firebaseData!['plantationDate'])).inDays,
        int.parse(firebaseData!['crop'].toString()),
      );
      setState(() {
        showEmtpyState = false;
        prediction = svc!.predict(features);
        print('Prediction: $prediction');
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateSharedValue();
      });
    } else {
      setState(() {
        showEmtpyState = true;
        prediction = null;
      });
    }
  }

  void _updateSharedValue() {
    print('Updating shared value prediction');
    Provider.of<SharedValue>(context, listen: false).setPrediction(1); //prediction ?? 0);
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
                      firebaseData = null;
                      selectedUnit = value!;
                      AppPrefs().saveSelectedUnit(value);

                      fetchData(selectedUnit!);
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
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/crop_monitoring.png',
              width: double.infinity,
            ),
            Gap(50),

            if (prediction != null)
              RichText(
                text: TextSpan(
                  text: 'According to our model prediction, you ',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    color: AppColors.primaryColor,
                  ),
                  children: [
                    TextSpan(
                      text: prediction == 1 ? 'should' : 'should not',
                      style: TextStyle(
                        color: prediction == 1 ? Colors.green : Colors.red,
                      ),
                    ),
                    const TextSpan(
                      text: ' irrigate your crops today.',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            if (showEmtpyState)
              const Text(
                'No data available.',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
