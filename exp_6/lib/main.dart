import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SensorApp(),
    );
  }
}

class SensorApp extends StatefulWidget {
  const SensorApp({super.key});

  @override
  State<SensorApp> createState() => _SensorAppState();
}

class _SensorAppState extends State<SensorApp> {
  // Accelerometer
  double ax = 0, ay = 0, az = 0;

  // Gyroscope
  double gx = 0, gy = 0, gz = 0;

  // Location
  Position? position;
  String locationStatus = "Press button to get location";

  @override
  void initState() {
    super.initState();

    // Accelerometer stream
    accelerometerEvents.listen((event) {
      setState(() {
        ax = event.x;
        ay = event.y;
        az = event.z;
      });
    });

    // Gyroscope stream
    gyroscopeEvents.listen((event) {
      setState(() {
        gx = event.x;
        gy = event.y;
        gz = event.z;
      });
    });
  }

  Future<void> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          locationStatus = "Location services are disabled";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          locationStatus = "Permission permanently denied";
        });
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        position = pos;
        locationStatus = "Lat: ${pos.latitude}, Lng: ${pos.longitude}";
      });
    } catch (e) {
      setState(() {
        locationStatus = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sensor Integration"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("📱 Accelerometer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("X: $ax\nY: $ay\nZ: $az"),
              const SizedBox(height: 20),
              const Text("🌀 Gyroscope",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("X: $gx\nY: $gy\nZ: $gz"),
              const SizedBox(height: 20),
              const Text("📍 GPS Location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(locationStatus),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: getLocation,
                child: const Text("Get Location"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
