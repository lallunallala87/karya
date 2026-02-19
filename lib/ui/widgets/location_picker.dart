//location_picker.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _controller;
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
  }

  // Function to get the current location of the user
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _controller?.animateCamera(
      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
    );
  }

  // Handle tap to pick a location on the map
  void _onMapTapped(LatLng location) {
    setState(() {
      _pickedLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Pick a Location")),
    body: Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(37.7749, -122.4194),
            zoom: 14,
          ),
          onMapCreated: (controller) {
            _controller = controller;
          },
          onTap: _onMapTapped,
          markers: _pickedLocation == null
              ? {}
              : {
                  Marker(
                    markerId: const MarkerId("picked_location"),
                    position: _pickedLocation!,
                  ),
                },
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: ElevatedButton(
            onPressed: () {
              if (_pickedLocation != null) {
                Navigator.pop(context, _pickedLocation);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please pick a location first.")),
                );
              }
            },
            child: const Text("Confirm Location"),
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _getCurrentLocation,
      child: const Icon(Icons.my_location),
    ),
  );
}
