import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:uber/API/api_constants.dart';

import '../API/end_points.dart';

class LocationServices {

  static Future<Position?> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      print('==============================================> Location services are disabled');
      return null;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('==============================================> Location permission was not granted');
      return null;
    }
    print('==============================================> Location permission was granted');
    return await Geolocator.getCurrentPosition();
  }
  static Future<List<LatLng>> getRoute(LatLng start, LatLng destination,) async {
    final url = Uri.https(
      ApiConstants.baseURL,
      EndPoints.routing,
      {
        'api_key': ApiConstants.ApiKey,
        'start': '${start.longitude},${start.latitude}',
        'end': '${destination.longitude},${destination.latitude}',
      },
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      debugPrint('Route API error: ${response.statusCode}');
      debugPrint(response.body);
      return [];
    }

    final data = jsonDecode(response.body);

    final coordinates =
    data['features'][0]['geometry']['coordinates'] as List;

    return coordinates.map<LatLng>((coordinate) {
      return LatLng(
        coordinate[1].toDouble(),
        coordinate[0].toDouble(),
      );
    }).toList();
  }
  static Marker createDestinationMarker(LatLng point) {
    return Marker(
      width: 80.0,
      height: 80.0,
      point: point,
      child: const Icon(
        Icons.location_on,
        color: Colors.red,
        size: 40.0,
      ),
    );
  }
  static Future<List<LatLng>> getRouteFromCurrentLocation(LatLng destination,) async {
    final position = await LocationServices.getCurrentLocation();

    if (position == null) {
      return [];
    }

    final currentLocation = LatLng(
      position.latitude,
      position.longitude,
    );

    return await getRoute(
      currentLocation,
      destination,
    );
  }
  static Future<double> getDistance(LatLng start, LatLng destination,) async {
    final distanceInMeters = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      destination.latitude,
      destination.longitude,
    );

    final distanceInKm = distanceInMeters / 1000;

    return distanceInKm;
  }

}


