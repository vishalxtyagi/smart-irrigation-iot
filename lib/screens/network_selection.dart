import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:irrigation/screens/get_started.dart';
import 'package:irrigation/screens/settings_page.dart';
import 'package:irrigation/utils/prefs.dart';
import 'package:irrigation/utils/size_config.dart';

import 'home_page.dart';

class NetworkSelection extends StatefulWidget {
  const NetworkSelection({
    required this.devices,
    this.isManageDevices = false,
    this.isAddDevice = false,
    super.key,
  });

  final bool isManageDevices;
  final bool isAddDevice;
  final List<String> devices;

  @override
  State<StatefulWidget> createState() {
    return NetworkSelectionState();
  }
}

class NetworkSelectionState extends State<NetworkSelection> {
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.ref('FirebaseIOT');
  List<Map<String, dynamic>> devices = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchUnits();
    print('init');
  }

  Future<void> _fetchUnits() async {
    try {
      devices = await getUnits();
      setState(() {}); // Update the state to trigger a rebuild
    } catch (e) {
      // Handle error
      print('Error fetching units: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUnits() async {
    List<Map<String, dynamic>> units = [];
    for (var element in widget.devices) {
        await _databaseReference.child(element).once().then((event) {
          Object? deviceData = event.snapshot.value;
          if (deviceData is Map<dynamic, dynamic>) {
            units.add({
              'id': element,
              'name': deviceData['name'] ?? 'Unit ${units.length + 1}',
              'crop': deviceData['crop'] ?? 1,
              'plantationDate': deviceData['plantationDate'] ?? DateTime
                  .now()
                  .millisecondsSinceEpoch,
              'control': deviceData['control'] ?? "OFF",
              'timestamp': DateTime
                  .now()
                  .millisecondsSinceEpoch,
            });
          } else {
            units.add({
              'id': element,
              'name': 'Unit ${units.length + 1}',
              'crop': 1,
              'plantationDate': DateTime
                  .now()
                  .millisecondsSinceEpoch,
              'control': "OFF",
              'timestamp': DateTime
                  .now()
                  .millisecondsSinceEpoch,
            });
          }
        });
    }
    return units;
  }

  @override
  Widget build(BuildContext context) {
    const cropMap = {
      1: 'Wheat',
      2: 'Ground Nuts',
      3: 'Garden flowers',
      4: 'Maize',
      5: 'Paddy',
      6: 'Potato',
      7: 'pulse',
      8: 'SugerCane',
      9: 'coffee'
    };

    SizeConfig.init(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.isManageDevices ? 'Manage Devices' : 'Network Selection',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: devices.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15),
                      title: Text(
                        'ID: ${devices[index]['id']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30),
                          TextFormField(
                            initialValue: devices[index]['name'],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter Name',
                            ),
                            onChanged: (value) {
                              setState(() {
                                devices[index]['name'] = value;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: TextEditingController(
                                text: devices[index]['plantationDate'] !=
                                    null
                                    ? DateTime.fromMillisecondsSinceEpoch(
                                    devices[index]['plantationDate'])
                                    .toString()
                                    : ''),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Plantation Date',
                            ),
                            readOnly: true,
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              ).then((value) {
                                if (value != null) {
                                  setState(() {
                                    selectedDate = value;
                                    devices[index]['plantationDate'] =
                                        value.millisecondsSinceEpoch;
                                  });
                                }
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Crop:',
                          ),
                          DropdownButton(
                            value: cropMap.containsKey(devices[index]['crop'])
                                ? devices[index]['crop']
                                : 1,
                            items: cropMap.entries.map((e) {
                              return DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                devices[index]['crop'] = value;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          ToggleButtons(
                            children: [
                              Icon(Icons.power),
                            ],
                            isSelected: [
                              devices[index]['control'] == "ON",
                            ],
                            onPressed: (index) {
                              setState(() {
                                devices[index]['control'] = devices[index]
                                ['control'] ==
                                    "ON"
                                    ? "OFF"
                                    : "ON";
                              });
                            },
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            devices.removeAt(index);
                            widget.devices.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const Gap(20),
            TextButton(
              onPressed: () async {
                try {
                  print(widget.isAddDevice);
                  if (widget.isAddDevice) {
                    for (var element in devices) {
                      await _databaseReference
                          .child(element['id'])
                          .update(element);
                      await AppPrefs().addDevice(element);
                    }
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                    return;
                  }

                  await AppPrefs().clearDevices();
                  await AppPrefs().clearSelectedUnit();
                  print(devices);

                  if (widget.isManageDevices) {
                    if (devices.isEmpty) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => GetStarted()));
                      return;
                    }

                    for (var element in devices) {
                      await _databaseReference
                          .child(element['id'])
                          .update(element);
                    }
                    await AppPrefs().saveDevices(devices);
                    Navigator.pop(context);
                  } else {
                    if (devices.isEmpty) throw 'No devices found.';

                    for (var element in devices) {
                      await _databaseReference
                          .child(element['id'])
                          .update(element);
                    }
                    await AppPrefs().saveDevices(devices);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  }
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: Text(e.toString()),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text(
                widget.isManageDevices ? 'Save Changes' : 'Proceed',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
