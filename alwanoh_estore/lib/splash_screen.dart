// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'dart:math' as math;
//
// import 'Main_Screens/WelcomeScreen.dart';
// import 'Thems/styles.dart';
//
// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   String? imageUrl;
//   late AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadImage();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     )..forward();
//
//     // Navigate to the next page after 5 seconds
//     Future.delayed(const Duration(seconds: 5), () {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (_) => WelcomeScreen()),
//       );
//     });
//   }
//   Future<void> _loadImage() async {
//     try {
//       // Get the download URL for the image from Firebase Storage
//       String downloadURL = await FirebaseStorage.instance
//           .refFromURL('gs://alwanoh-store.appspot.com/Home/pp.png')
//           .getDownloadURL();
//
//       setState(() {
//         imageUrl = downloadURL; // Set the fetched URL to imageUrl
//       });
//     } catch (e) {
//       print('Error fetching image from Firebase Storage: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             // Hexagon Image Background
//             ClipPath(
//               clipper: HexagonClipper(),
//               child: Image.network(
//                 imageUrl!,
//                 fit: BoxFit.contain,
//                 width: 200,
//                 height: 200,
//               ),
//             ),
//             // Animated Hexagon Drawing
//             AnimatedBuilder(
//               animation: _controller,
//               builder: (_, __) {
//                 return CustomPaint(
//                   size: const Size(200, 200),
//                   painter: AnimatedHexagonPainter(_controller.value),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Painter to Draw the Hexagon Over Time
// class AnimatedHexagonPainter extends CustomPainter {
//   final double progress;
//
//   AnimatedHexagonPainter(this.progress);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Styles.customColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4.0;
//
//     final path = Path();
//     final width = size.width;
//     final height = size.height;
//
//     final points = [
//       Offset(width * 0.5, 0),
//       Offset(width, height * 0.25),
//       Offset(width, height * 0.75),
//       Offset(width * 0.5, height),
//       Offset(0, height * 0.75),
//       Offset(0, height * 0.25),
//     ];
//
//     for (int i = 0; i < points.length; i++) {
//       final start = points[i];
//       final end = points[(i + 1) % points.length];
//
//       if (progress > i / points.length) {
//         final segmentProgress =
//         math.min((progress - i / points.length) * points.length, 1.0);
//         final currentEnd = Offset(
//           start.dx + (end.dx - start.dx) * segmentProgress,
//           start.dy + (end.dy - start.dy) * segmentProgress,
//         );
//         path.moveTo(start.dx, start.dy);
//         path.lineTo(currentEnd.dx, currentEnd.dy);
//       }
//     }
//
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
//
// // Clipper for the Hexagon Shape
// class HexagonClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     final width = size.width;
//     final height = size.height;
//
//     path.addPolygon([
//       Offset(width * 0.5, 0),
//       Offset(width, height * 0.25),
//       Offset(width, height * 0.75),
//       Offset(width * 0.5, height),
//       Offset(0, height * 0.75),
//       Offset(0, height * 0.25),
//     ], true);
//
//     return path;
//   }
//
//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
// }
//
// // Dummy Home Page
// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home Page')),
//       body: const Center(child: Text('Welcome to the Home Page!')),
//     );
//   }
// }
//
