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
  final List<Map<String, dynamic>> devices = [];

  Future<List<Map<String, dynamic>>> getUnits() async {
    List<Map<String, dynamic>> units = [];
    for (var element in widget.devices) {
      await _databaseReference.child(element).child('name').once().then((event) {
        String deviceName = event.snapshot.value.toString();

        units.add({
          'id': element,
          'name': deviceName != 'null' ? deviceName : 'Unit ${units.length + 1}',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      });
    }
    return units;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.isManageDevices ? 'Manage devices' : 'Network selection'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: getUnits(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No devices found.'),
                    );
                  } else {
                    devices.clear();
                    devices.addAll(snapshot.data!);
                    return ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: TextFormField(
                              initialValue: devices[index]['name'],
                              decoration: const InputDecoration(
                                labelText: 'Name',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  devices[index]['name'] = value;
                                });
                              },
                            ),
                            subtitle: Text(devices[index]['id']),
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
                    );
                  }
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
                      await AppPrefs().addDevice(element);
                    }
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage())
                    );
                    return;
                  }

                  await AppPrefs().clearDevices();
                  await AppPrefs().clearSelectedUnit();

                  if (widget.isManageDevices) {
                    if (devices.isEmpty) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => GetStarted())
                      );
                      return;
                    }

                    await AppPrefs().saveDevices(devices);
                    Navigator.pop(context);
                  } else {
                    if (devices.isEmpty) throw 'No devices found.';

                    await AppPrefs().saveDevices(devices);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage())
                    );                  }
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
              child: Text(widget.isManageDevices ? 'Save changes' : 'Proceed'),
            ),
          ],
        ),
      ),
    );
  }
}
