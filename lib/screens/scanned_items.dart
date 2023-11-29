import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import '../widget/SeachBox.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'home_screen.dart';
class ScannedItems extends StatefulWidget {
  const ScannedItems({super.key});

  @override
  State<ScannedItems> createState() => _ScannedItemsState();
}

class _ScannedItemsState extends State<ScannedItems> {
  String? mtoken = " ";
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin =
  FlutterLocalNotificationsPlugin();
  bool _notificationSent = false;
  static final _notification = FlutterLocalNotificationsPlugin();


  @override
  void initState() {
    super.initState();
    requestPermission();
    getToken();
    initInfo();
    checkProductExpiryFromFirestore();
  }

  static Future _notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId',
        'channelName',
        importance: Importance.max,
      ),
    );
  }
  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notification.show(
        id,
        title,
        body,
        await _notificationDetails(),
        payload: 'Default sound',
      );


  Future<void> checkProductExpiryFromFirestore() async {
    final currentDate = DateTime.now();
    final firestore = FirebaseFirestore.instance;

    try {
      final userUid = user?.uid;
      if (userUid != null) {
        final productsCollection = firestore.collection('users').doc(userUid).collection('products');
        final productDocs = await productsCollection.get();

        for (QueryDocumentSnapshot productDoc in productDocs.docs) {
          final productData = productDoc.data() as Map<String, dynamic>;
          final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

          // Assuming "expiryDate" is stored as a String in Firestore
          final String dateString = productData["expiryDate"] as String;
          final productName = productData["name"] as String;

          // Parse the dateString into a DateTime object
          final DateTime expiryDate = dateFormat.parse(dateString);

          final DateTime now = DateTime.now();

          // Calculate the difference in days until expiry
          final int daysUntilExpiry = expiryDate.isBefore(now) ? -1 : expiryDate.difference(now).inDays;

          if (daysUntilExpiry != null) {
            if (daysUntilExpiry <= 0 && !_notificationSent) {
              // The product has expired or is expiring today, notify the user.
              await showNotification(
                title: 'Product Expired',
                body: '${productName} has been expired.',
                payload: 'product_expired',
              );
              _notificationSent = true;
            } else {
              // The product is not yet expired.
              print('Days until expiry for document ${productDoc.id}: $daysUntilExpiry');
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching product data: $e');
    }
  }


  initInfo() {
    var androidInitialize = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: androidInitialize);
    flutterLocalNotificationPlugin.initialize(initializationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("onMessage");
      print("onMessage: ${message.notification?.title}/${message.notification?.body}}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(), htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(), htmlFormatContentTitle: true,
      );

      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'expiroScan', 'expiroScan', importance: Importance.high,
        styleInformation: bigTextStyleInformation, priority: Priority.high, playSound: true,
      );
      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationPlugin.show(0, message.notification?.title, message.notification?.body, platformChannelSpecifics);
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print('User granted Permission');
    } else if(settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional Permission');
    } else {
      print('User declined');
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then(
            (token){
          setState(() {
            mtoken = token;
            print('My token is $mtoken');
          });
          saveToken(token!);
        }
    );
  }

  void saveToken(String token) async {
    // Ensure that the user is authenticated and has a valid UID
    if (user != null && user?.uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
        'token': token,
      });
    } else {
      print('User not authenticated or user UID is null.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF101820),
          title: const Text(
            "Scanned Items",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: [
            const SizedBox(
              width: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0, bottom: 20.0 ),
              child: CustomSearchBox(
                onTextChanged: (value) {
                  setState(() {
                    var searchText = value;
                  });
                }
              ),
            ),
            const SizedBox(
              width: 50,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user!.uid)
                  .collection("products")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Something is wrong"),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No scanned items yet."),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot doc = snapshot.data!.docs[index];
                    final String id = doc["id"] ?? "";
                    final String name = doc["name"] ?? "";
                    final double price = doc["price"] ?? 0.0;
                    String dateString = doc["expiryDate"] as String; // Assuming expiryDate is stored as a String
                    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
                    final DateTime expiryDate = dateFormat.parse(dateString);
                    final DateTime now = DateTime.now();
                    final int daysUntilExpiry = expiryDate.isBefore(now) ? -1 : expiryDate.difference(now).inDays;
                    String expiryStatus = 'Good Product'; // Default status
                    Color statusColor = Colors.green; // Default color for "Good Product"
                    Color borderColor = Colors.transparent;

                    if (daysUntilExpiry < 0) {
                      expiryStatus = 'Expired';
                      statusColor = Colors.red; // Set color to red for "Expired"
                      borderColor = Colors.red;
                    } else if (daysUntilExpiry >= 0 && daysUntilExpiry <= 1) {
                      expiryStatus = 'Expires Tomorrow';
                      statusColor = Colors.red; // Set color to red for "Expired"
                    } else if (daysUntilExpiry <= 7) {
                      expiryStatus = 'Expires in a Week';
                      statusColor = Colors.red; // Set color to red for "Expired"
                    } else if (daysUntilExpiry <= 30) {
                      expiryStatus = 'Expires in a Month';
                     statusColor = Colors.red; // Set color to red for "Expired"
                    } else if (daysUntilExpiry <= 60) {
                      expiryStatus = 'Expires in 2 Months';
                      statusColor = Colors.red; // Set color to red for "Expired"
                    } else if (daysUntilExpiry <= 90) {
                      expiryStatus = 'Expires in 3 Months';
                      statusColor = Colors.red; // Set color to red for "Expired"
                    } else if(daysUntilExpiry > 90) {
                      expiryStatus = 'Good Product';
                      statusColor = Colors.green; // Set color to red for "Expired"
                    }

                    return Card(
                      elevation: 4, // Add elevation for a dropdown shadow effect
                      shadowColor: Colors.grey, // You can customize the shadow color
                      // margin: const EdgeInsets.symmetric(
                      //   horizontal: 15.0,
                      //   vertical: 10,
                      // ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10,
                        ),// Add padding inside the card
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(id),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(name),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 4,
                              child: Text(
                                expiryStatus,
                                style: TextStyle(
                                  color: statusColor, // Set the text color based on the status
                                  fontWeight: FontWeight.w600, // Add other text styles as needed
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(user!.uid)
                                    .collection("products")
                                    .doc(doc.id)
                                    .delete();
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
    );
  }
}

