// import 'package:flutter/material.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';
// import 'package:latlong2/latlong.dart' as latlong; // Use an alias for latlong2
//
// class DeliveryLocationPage extends StatefulWidget {
//   @override
//   _DeliveryLocationPageState createState() => _DeliveryLocationPageState();
// }
//
// class _DeliveryLocationPageState extends State<DeliveryLocationPage> {
//   latlong.LatLng? selectedLocation; // Use the alias here
//   final TextEditingController _descriptionController = TextEditingController();
//   final String accessToken = "pk.eyJ1IjoiYW1yLWFsc2FicmkiLCJhIjoiY20xZnY5aDljMW5hajJsczYyYzA4MHdxMiJ9.ZGBv8Xe932miYPNNp7YWvw"; // Your Mapbox access token
//
//   void _handleTap(LatLng point) {
//     setState(() {
//       selectedLocation = latlong.LatLng(point.latitude, point.longitude); // Use the alias here
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Select Delivery Location"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: GestureDetector(
//               onTapDown: (details) {
//                 // Convert the tap position to geographic coordinates
//                 // Here we'll use a placeholder LatLng for demonstration.
//                 final LatLng tappedLocation = LatLng(37.7749, -122.4194); // Placeholder
//                 _handleTap(tappedLocation);
//               },
//               child: MapboxMap(
//                 accessToken: accessToken,
//                 onMapCreated: (MapboxMapController controller) {
//                   // Handle map created
//                 },
//                 initialCameraPosition: CameraPosition(
//                   target: LatLng(37.7749, -122.4194), // Default location (San Francisco)
//                   zoom: 10,
//                 ),
//               ),
//             ),
//           ),
//           if (selectedLocation != null)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 "Selected Location: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}",
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: _descriptionController,
//               decoration: InputDecoration(
//                 labelText: "Location Description",
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 2,
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (selectedLocation != null && _descriptionController.text.isNotEmpty) {
//                 String description = _descriptionController.text;
//                 print("Selected Location: $selectedLocation, Description: $description");
//                 Navigator.pop(context); // Navigate back after submission
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("Please select a location and provide a description.")),
//                 );
//               }
//             },
//             child: Text("Submit"),
//           ),
//         ],
//       ),
//     );
//   }
// }
