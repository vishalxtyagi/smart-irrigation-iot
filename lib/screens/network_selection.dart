import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:irrigation/utils/prefs.dart';
import 'package:irrigation/utils/size_config.dart';

import 'home_page.dart';

class NetworkSelection extends StatefulWidget {
  const NetworkSelection({
      required this.devices,
      super.key
  });

  final List<String> devices;

  @override
  State<StatefulWidget> createState() {
    return NetworkSelectionState();
  }
}

class NetworkSelectionState extends State<NetworkSelection> {
  final List<Map<String, dynamic>> devices = [];

  @override
  void initState() {
    super.initState();

    for (var element in widget.devices) {
      devices.add({
        'id': element,
        'name': 'My device ${devices.length + 1}',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Network selection'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
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
                try{
                  AppPrefs().saveDevices(devices)
                      .then((value) => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage())
                  ));
                } catch (e) {
                  await showDialog(
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
              child: const Text('Proceed'),
            ),
          ],
        ),
      ),
    );
  }
}