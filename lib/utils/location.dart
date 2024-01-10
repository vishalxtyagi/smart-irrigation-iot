import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'permission.dart';

class LocationUtil {
  double? latitude;
  double? longitude;
  String? address;

  Future<void> getCurrentLocation() async {
    await AppPermission.requestLocationPermission();

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
      );
      latitude = position.latitude;
      longitude = position.longitude;

    } catch (e) {
      log('(getCurrentLocation) Error: $e');
    }
  }

  Future<void> getLatLonFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      latitude = locations[0].latitude;
      longitude = locations[0].longitude;
    } catch (e) {
      log('(getLatLonFromAddress) Error: $e');
    }
  }

  Future<void> getAddressFromLatLon() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude!, longitude!);
      Placemark place = placemarks[0];
      address = '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country} - ${place.postalCode}';
    } catch (e) {
      log('(getAddressFromLatLon) Error: $e');
    }
  }

  Future<void> findCoordinates(String? lat, String? lon, String? address) async {
    LocationUtil location = LocationUtil();

    if (address != null) {
      await location.getLatLonFromAddress(address);
    } else if (lat == null || lon == null) {
      await location.getCurrentLocation();
    }

    latitude = location.latitude ?? double.parse(lat!);
    longitude = location.longitude ?? double.parse(lon!);
  }
}
