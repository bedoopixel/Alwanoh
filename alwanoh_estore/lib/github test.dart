// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   void initState() {
//     super.initState();
//
//     // Request notification permissions
//     _requestPermissions();
//
//     // Listen for foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Foreground message received: ${message.notification?.title}');
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: Text(message.notification?.title ?? ''),
//           content: Text(message.notification?.body ?? ''),
//         ),
//       );
//     });
//
//     // Handle notification clicks (when app is in background or terminated)
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('Notification clicked: ${message.data}');
//       _handleNotificationClick(message);
//     });
//
//     // Get the device token (for sending notifications)
//     _getDeviceToken();
//   }
//
//   Future<void> _requestPermissions() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted notification permissions.');
//     } else {
//       print('User declined or has not accepted notification permissions.');
//     }
//   }
//
//   Future<void> _getDeviceToken() async {
//     String? token = await FirebaseMessaging.instance.getToken();
//     print('Device token: $token');
//     // Save this token to your server for sending notifications.
//   }
//
//   void _handleNotificationClick(RemoteMessage message) {
//     // Handle navigation based on the notification data
//     if (message.data['screen'] != null) {
//       Navigator.pushNamed(context, message.data['screen']);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Firebase Messaging Example'),
//       ),
//       body: Center(
//         child: Text('Welcome to Firebase Messaging Example'),
//       ),
//     );
//   }
// }
