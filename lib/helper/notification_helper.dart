import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationHelper {
  Future<void> sendNotification(String topic,
      {required String userName,
      required String message,
      required String place,
      required String phoneNumber}) async {
    var headersList = {
      'Content-Type': 'application/json',
      'Authorization': 'key=YOUR_SERVER_KEY' // Replace with your FCM server key
    };

    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    var body = jsonEncode({
      "to": "/topics/$topic",
      "notification": {
        "title": 'New Notification',
        'body': '$userName \n$message \n$place',
        "sound": "default"
      },
      "data": {
        "userName": userName,
        "place": place,
        "phoneNumber": phoneNumber,
      },
    });

    var response = await http.post(url, headers: headersList, body: body);

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Error: ${response.reasonPhrase}');
    }
  }

  void configureFirebaseMessaging(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Foreground message received: ${message.notification!.body}');
        showNotificationDialog(context, message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked when app is in background');
      // Handle navigation or deep linking here
    });
  }

  void showNotificationDialog(BuildContext context, RemoteMessage message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('New Notification'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message.notification!.body ?? ''),
            Text(message.data['userName'] ?? ''),
            Text(message.data['place'] ?? ''),
            Text(message.data['phoneNumber'] ?? ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
