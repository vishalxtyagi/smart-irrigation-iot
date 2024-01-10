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
    return Scaffold(
      backgroundColor: const Color(0xff030317),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              width: double.infinity,
              height: 70,
              child: TextField(
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Search your address',
                  hintStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  filled: true,
                  fillColor: const Color(0xff00A1FF).withOpacity(0.5),
                ),
                onChanged: (value) => address = value,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xff00A1FF).withOpacity(0.5),
                    ),
                  ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
