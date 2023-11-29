import 'package:expiro_scan/screens/login_screen.dart';
import 'package:expiro_scan/screens/scanned_items.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void>_firebaseMessagingBackgroundHandler(RemoteMessage message) async {
   print('Handling Background Message  ${message.messageId}');
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExpiroScan',
      theme: ThemeData(
        // Change to your desired color
      ),
      home: AnimatedSplashScreen(
        splash: Image.asset(
          'assets/images/barcode-scanner.png',
        ), nextScreen: const LoginScreen(),
        splashTransition: SplashTransition.scaleTransition,
      ),
    );
  }
}

