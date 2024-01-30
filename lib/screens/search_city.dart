import 'package:flutter/material.dart';

class SearchCity extends StatefulWidget {
  const SearchCity({super.key});

  @override
  State<SearchCity> createState() => _SearchCityState();
}

class _SearchCityState extends State<SearchCity> {
  String? address;
  @override
  Widget build(BuildContext context) {
    List<String> cities = ['Panipat', 'Karnal', 'Sonipat', 'Delhi', 'Chandigarh', 'Ambala', 'Kurukshetra'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                TextField(
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search your address',
                  ),
                  onChanged: (value) => address = value,
                ),
                const SizedBox(height: 20),
                ListView(
                  shrinkWrap: true,
                  children: [
                    for (String city in cities)
                      ListTile(
                        title: Text(city + ', India'),
                        onTap: () {
                          Navigator.pop(context, city);
                        },
                      ),
                    ]
                )
              ]
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, address);
              },
              child: const Text(
                'Search',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
