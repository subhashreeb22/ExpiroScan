import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/user_model.dart';
import 'login_screen.dart';
class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF101820),
        title: const Text("Settings",
          style: TextStyle(fontSize: 18,),),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Card(
            elevation: 1,
            shadowColor: Colors.grey,
            child: Container(
              width: 383.0,
              height: 180.0,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0,),
                  const Text(
                    'Account Information',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Username:',
                        style: TextStyle(
                        ),
                      ),
                      Text(
                        '${loggedInUser.userName}',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Email ID:',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${loggedInUser.email}',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 1,
            shadowColor: Colors.grey,
            child: Container(
              width: 383.0,
              height: 180.0,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0,),
                  const Text(
                    'Account Settings',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Name',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${loggedInUser.userName}',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Expiry Date Notification',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '10 AM',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 1,
            shadowColor: Colors.grey,
            child: Container(
              width: 383.0,
              height: 180.0,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0,),
                  const Text(
                    'Notification Settings',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notification',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8.0), // Add horizontal spacing
                      Switch(
                        value: true, // Replace with the actual toggle value
                        onChanged: (bool value) {
                          // Handle toggle change here
                          // You can use a state variable to manage the toggle state
                          // and update the value accordingly.
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 40,),
          SizedBox(
            width: 370,
            height: 50,// Set the desired width
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.black, // Set your custom background color here
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white, // Set text color for the button
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




