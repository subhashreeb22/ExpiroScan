import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../model/user_model.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({Key? key}) : super(key: key);

  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  static final _notification = FlutterLocalNotificationsPlugin();
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

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

  Future<void> checkProductExpiryFromFirestore(String productId) async {
    final currentDate = DateTime.now();
    final firestore = FirebaseFirestore.instance;

    try {
      final productDoc = await firestore.collection('users').doc(user?.uid).collection('products').doc().get();
      if (productDoc.exists) {
        final productData = productDoc.data() as Map<String, dynamic>;
        final expiryDateTimestamp = productData['expiryDate'] as Timestamp?;

        if (expiryDateTimestamp != null) {
          final expiryDate = expiryDateTimestamp.toDate();

          if (expiryDate.isBefore(currentDate)) {
            // The product has expired, notify the user.
            await showNotification(
              title: 'Product Expired',
              body: 'Your product has expired.',
              payload: 'product_expired',
            );
          }
        }
      }
    } catch (e) {
      print('Error fetching product data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
