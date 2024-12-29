import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Thems/styles.dart'; // Import your custom styles

class LocationPickerPage extends StatefulWidget {
  final LatLng? initialLocation;
  LocationPickerPage({this.initialLocation});
  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  LatLng _initialPosition = LatLng(37.7749, -122.4194); // Default location (San Francisco)

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // Get user's current location
  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_initialPosition),
      );
    }
  }

  // Save the selected location
  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  // Set the map's marker to the user's current location
  void _setToCurrentLocation() async {
    await _getUserLocation();
    setState(() {
      _selectedLocation = _initialPosition;
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_initialPosition),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.primaryColor,
      appBar: AppBar(
        title: Text('Pick Your Location', style: TextStyle(color: Colors.white)),
        backgroundColor: Styles.customColor,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: _onMapTapped,
            markers: _selectedLocation != null
                ? {
              Marker(
                markerId: MarkerId('selected-location'),
                position: _selectedLocation!,
              ),
            }
                : {},
          ),
          Positioned(
            bottom: 90,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _setToCurrentLocation,
              icon: Icon(Icons.my_location, color: Colors.white),
              label: Text('Use Current Location', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.customColor,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedLocation != null) {
                  Navigator.pop(context, _selectedLocation);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a location!')),
                  );
                }
              },
              child: Text('Confirm Location', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.customColor,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
