import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:uber/Screens/signin_screen.dart';
import 'package:uber/Services/location_services.dart';
import '../API/firebase_manager.dart';
import '../widgets/home_buttom_sheet.dart';


class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>  {
  late Future<String?> userNameFuture;
  List<Marker> markers = [];
  List<LatLng> routePoints = [];
  final MapController mapController = MapController();
  Position? currentLocation;
  double distance = 0;
  TextEditingController destinationController = TextEditingController();


  @override
  void initState() {
    super.initState();
    userNameFuture = FirebaseManager.getUserName();

    loadCurrentLocation();
  }

  Future<void> loadCurrentLocation() async {
    final position = await LocationServices.getCurrentLocation();
    setState(() {
      currentLocation = position;
    });
  }

  Future<void> selectDestination(LatLng destination) async {
    // user current location
    final start = LatLng(
      currentLocation!.latitude,
      currentLocation!.longitude,
    );

    // Get route
    final route = await LocationServices.getRoute(
      start,
      destination,
    );

    // Calculate distance
    final calculatedDistance = await LocationServices.getDistance(
      start,
      destination,
    );

    if (!mounted) return;

    setState(() {
      markers.clear();
      markers.add(LocationServices.createDestinationMarker(destination),);
      routePoints.clear();
      distance = 0;
      routePoints = route;
      distance = calculatedDistance;

    });
  }

  Future<void> searchDestination() async {
    final address = destinationController.text.trim();

    if (address.isEmpty) return;

    try {
      final locations = await locationFromAddress(address);

      if (locations.isEmpty) {
        print('No location found');
        return;
      }

      final location = locations.first;

      final destination = LatLng(
        location.latitude,
        location.longitude,
      );

      print('Address: $address');
      print('Latitude: ${location.latitude}');
      print('Longitude: ${location.longitude}');

      // Move map to destination
      mapController.move(
        destination,
        17.5,
      );

      // Add marker, get route and calculate distance
      await selectDestination(destination);
    } catch (e) {
      print('Error searching destination: $e');
    }
  }
  @override
  void dispose() {
    destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: FirebaseManager.getUserName(),
          builder: (context, snapshot) {
            return Text(
              'Hello ${snapshot.data ?? "User"}',
            );
            },
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseManager.logout();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SigninScreen(),
                ),
              );
            },
            icon: const Icon(Icons.logout , color: Colors.red,),
          ),
        ],
      ),

      body: currentLocation == null
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Stack(
        children: [
          FlutterMap(
            mapController: mapController,

            options: MapOptions(
              onTap: (tapPosition, point) {
                selectDestination(point);
              },

              initialZoom: 17.5,

              initialCenter: LatLng(
                currentLocation!.latitude,
                currentLocation!.longitude,
              ),
            ),

            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.uber',
              ),

              // Draw route only if there are route points
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5,
                      color: Colors.black,
                    ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  // Current location
                  Marker(
                    point: LatLng(
                      currentLocation!.latitude,
                      currentLocation!.longitude,
                    ),
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.navigation_rounded,
                      color: Colors.lightBlueAccent,
                      size: 45,
                    ),
                  ),

                  // Destination
                  ...markers,
                ],
              ),
            ],
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.15,
            maxChildSize: 0.4,
            builder: (context, scrollController) {
              return HomeButtomSheet(
                scrollController: scrollController,
                ditance: distance,
                destinationController: destinationController ,
                onSearch: searchDestination,
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentLocation != null) {
            mapController.move(
              LatLng(
                currentLocation!.latitude,
                currentLocation!.longitude,
              ),
              17.5,
            );
          }
        },
        child: const Icon(Icons.my_location),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }
}