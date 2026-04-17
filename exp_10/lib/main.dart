import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class AppColors {
  static const darkGray = Color(0xFF4A4A4A);
  static const lightGray = Color(0xFFCBCBCB);
  static const cream = Color(0xFFFFFFE3);
  static const blueGray = Color(0xFF6D8196);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.cream,
        primaryColor: AppColors.blueGray,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.blueGray,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String locationText = "Press button to get location";
  Position? currentPosition;
  Position? lastPosition;
  double movement = 0.0;

  List<String> nearbyPlaces = [];

  Future<void> getLocation() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      lastPosition = currentPosition;
      currentPosition = position;

      setState(() {
        locationText = "Lat: ${position.latitude}\nLng: ${position.longitude}";
      });

      generateNearbyPlaces();
    } else {
      setState(() {
        locationText = "Permission Denied";
      });
    }
  }

  Future<void> openMaps() async {
    if (currentPosition == null) return;

    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${currentPosition!.latitude},${currentPosition!.longitude}",
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void generateNearbyPlaces() {
    nearbyPlaces = [
      "Restaurant (Popular nearby)",
      "Cafe (Within 500m)",
      "Hospital (Within 1km)",
      "Shopping Mall",
      "ATM / Bank",
    ];
  }

  void calculateMovement() {
    if (lastPosition == null || currentPosition == null) {
      setState(() => movement = 0);
      return;
    }

    double distance = Geolocator.distanceBetween(
      lastPosition!.latitude,
      lastPosition!.longitude,
      currentPosition!.latitude,
      currentPosition!.longitude,
    );

    setState(() {
      movement = distance;
    });
  }

  Widget buildCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget customButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueGray,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location Tracker")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildCard(
                    "Current Location",
                    Text(
                      locationText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  buildCard(
                    "Actions",
                    Column(
                      children: [
                        customButton("Get Location", getLocation),
                        const SizedBox(height: 10),
                        customButton("Open in Google Maps", openMaps),
                        const SizedBox(height: 10),
                        customButton("Track Movement", calculateMovement),
                      ],
                    ),
                  ),

                  buildCard(
                    "Movement",
                    Text(
                      movement == 0
                          ? "No movement detected"
                          : "${movement.toStringAsFixed(2)} meters moved",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  buildCard(
                    "Nearby Places",
                    Column(
                      children: nearbyPlaces
                          .map(
                            (place) => ListTile(
                              leading: const Icon(
                                Icons.place,
                                color: AppColors.darkGray,
                              ),
                              title: Text(place),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
