import 'package:expiro_scan/screens/add_manually.dart';
import 'package:expiro_scan/screens/home_screen.dart';
import 'package:expiro_scan/screens/scanned_items.dart';
import 'package:expiro_scan/screens/settings.dart';
import 'package:flutter/material.dart';

class NavigatorDart extends StatefulWidget {
  const NavigatorDart({super.key});

  @override
  State<NavigatorDart> createState() => _NavigatorDartState();
}

class _NavigatorDartState extends State<NavigatorDart> {
  int pageIndex = 0;

  final pages = [
    const ScannedItems(),
    const HomeScreen(),
    const AddManuallyScreen(),
    const Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[pageIndex],
      bottomNavigationBar: buildMyNavBar(context),
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF101820),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 0;
              });
            },
            icon: pageIndex == 0
                ? const Icon(
              Icons.home_rounded,
              color: Colors.white,
            )
                : const Icon(
              Icons.home_outlined,
              color: Colors.white,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 1;
              });
            },
            icon: pageIndex == 1
                ? const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
            )
                : const Icon(
              Icons.qr_code_scanner_outlined,
              color: Colors.white,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 2;
              });
            },
            icon: pageIndex == 2
                ? const Icon(
              Icons.add_circle,
              color: Colors.white,
            )
                : const Icon(
              Icons.add_circle_outline,
              color: Colors.white,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 3;
              });
            },
            icon: pageIndex == 3
                ? const Icon(
              Icons.settings, // Replace with the icon for MyNewScreen
              color: Colors.white,
            )
                : const Icon(
              Icons.settings_outlined, // Replace with the icon for MyNewScreen
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

