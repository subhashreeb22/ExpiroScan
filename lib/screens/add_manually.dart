import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiro_scan/screens/home_screen.dart';
import 'package:expiro_scan/screens/scanned_items.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/product_model.dart';
import '../model/user_model.dart';

class AddManuallyScreen extends StatefulWidget {
  const AddManuallyScreen({super.key});

  @override
  State<AddManuallyScreen> createState() => _AddManuallyScreenState();
}

class _AddManuallyScreenState extends State<AddManuallyScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  final TextEditingController _expiryDateController = TextEditingController();
  TextEditingController idController = TextEditingController(); // Declare controller for ID field
  TextEditingController nameController = TextEditingController(); // Declare controller for Name field
  TextEditingController priceController = TextEditingController(); // Declare controller for Price field
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _expiryDateController.text = selectedDate.toString(); // Set the selected date in the text field
      });
  }

  @override
  void dispose() {
    idController.dispose(); // Dispose of the controllers
    nameController.dispose();
    priceController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF101820),
          title: Text("Add Manually",
            style: const TextStyle(fontSize: 18,),),
          centerTitle: true,
        ),
      body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Add Products', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
        SizedBox(height: 20,),
        Padding(
          padding: const EdgeInsets.only(left: 28.0, right: 28.0),
          child: TextField(
            controller: idController,
            decoration: InputDecoration(
              labelText: 'ID',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), // Border width and color
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), // Focused border width and color
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), // Enabled border width and color
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 28.0, right: 28.0),
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), // Border width and color
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), // Focused border width and color
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), // Enabled border width and color
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 28.0, right: 28.0),
          child: TextField(
            controller: priceController,
            decoration: InputDecoration(
              labelText: 'Price',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), // Border width and color
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), // Focused border width and color
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), // Enabled border width and color
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 28.0, right: 28.0),
          child: TextFormField(
            controller: _expiryDateController,
            decoration: InputDecoration(
              labelText: 'Expiry Date',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), // Border width and color
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), // Focused border width and color
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), // Enabled border width and color
              ),
              suffixIcon: Theme(
                data: ThemeData(iconTheme: IconThemeData(color: Colors.black)), // Set the icon color to black
                child: GestureDetector(
                  onTap: () {
                    _selectDate(context); // Show date picker when the icon is tapped
                  },
                  child: Icon(Icons.calendar_today),
                ),
              ),
            ),
            readOnly: true,
            onTap: () {
              _selectDate(context); // Show date picker when the text field is tapped
            },
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () async {
            // Get the values from the input fields
            String id = idController.text;
            String name = nameController.text;
            double price = double.tryParse(priceController.text) ?? 0.0;
            DateTime expiryDate = selectedDate ?? DateTime.now();

            // Print the values for debugging
            print("ID: $id");
            print("Name: $name");
            print("Price: $price");

            // Create a Firestore reference to the "products" collection within the user's document
            DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
            CollectionReference productsCollection = userDocRef.collection('products');

            // Add the product data to Firestore
            await productsCollection.add({
              'id': id,
              'name': name,
              'price': price,
              'expiryDate': expiryDate.toIso8601String(),
            });

            // Clear the input fields after saving
            idController.clear();
            nameController.clear();
            priceController.clear();
            _expiryDateController.clear();
            setState(() {
              selectedDate = null;
            });

            // Show a success message or perform other actions as needed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Data saved to Firestore.'),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF101820), // Button background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Adjust the border radius
            ),
            elevation: 4, // Adjust the elevation
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Adjust padding
          ),
          child: Text('Save'), // Change the button label
        )
      ],
      )
    );
  }
}