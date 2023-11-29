import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../model/product_model.dart';
import '../model/user_model.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> entries  = [];
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  String result = "";

  Future<void> scanBarcode() async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );

    if (res is String) {
      // Parse the scanned data into a Product object
      try {
        Map<String, String> data = {};
        List<String> keyValuePairs = res.split('|');
        for (String pair in keyValuePairs) {
          List<String> parts = pair.split(':');
          if (parts.length == 2) {
            String key = parts[0].trim();
            String value = parts[1].trim();
            data[key] = value;
          }
        }

        Product product = Product(
          uid: data ['uid'] ?? '',
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          price: double.tryParse(data['price'] ?? '') ?? 0.0,
          expiryDate: DateTime.tryParse(data['expiryDate'] ?? '') ?? DateTime.now(),
        );

        // Add the product data to Firestore under the user's document
        DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
        CollectionReference productsCollection = userDocRef.collection('products');
        await productsCollection.add(product.toMap());

        setState(() {
          result = "Data added to Firestore successfully!";
        });
      } catch (e) {
        setState(() {
          result = "Error adding data to Firestore: $e";
        });
      }
    }
  }
  
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF101820),
        title: Text("Welcome, ${loggedInUser.userName}",
          style: const TextStyle(fontSize: 18,),),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Image.asset("assets/images/scanning.png", width: 300, height: 300,),
            const SizedBox(height: 30),
            FloatingActionButton.extended(
              onPressed: () => scanBarcode(),
              backgroundColor: const Color(0xFF101820),
              label: const Text('Scan'),
              icon: const Icon(Icons.qr_code_scanner), // Add an icon if needed
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Adjust the border radius
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap target size
              elevation: 4, // Adjust the elevation
              highlightElevation: 8, // Adjust the highlight elevation
            ),
            const SizedBox(height: 20),
            Text(result),
          ],
        ),
      ),
    );
  }
}

// the logout function
Future<void> logout(context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()));
}
