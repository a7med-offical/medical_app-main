import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/helper/notification_helper.dart';
import 'package:medical_app/auth/login_screen/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationHelper notificationHelper = NotificationHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    notificationHelper.configureFirebaseMessaging(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          await FirebaseMessaging.instance.subscribeToTopic('message');
          customShowBottomSheet(
              context, await FirebaseAuth.instance.currentUser!.uid);
        },
        child: Icon(
          Icons.notification_add,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 70),
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('notification').snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Something went wrong'),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text('No notifications available'),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: CustomCardNotification(
                              snap: snapshot.data!.docs[index],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.notifications, color: Colors.white),
                      Text(
                        'Notification',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                            (route) => false,
                          );
                        },
                        icon: const Icon(
                          Icons.output_sharp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void customShowBottomSheet(BuildContext context, String id) {
    String userName = '';
    String message = '';
    String phoneNumber = '';
    String place = '';
    var now = DateTime.now();
    var formatDate = DateFormat('yyyy-MM-dd').format(now);
    CollectionReference notification =
        FirebaseFirestore.instance.collection('notification');
    Future<void> addNotification() async {
      try {
        await notification.add({
          'userName': userName,
          'message': message,
          'phoneNumber': phoneNumber,
          'place': place,
          'id': id,
          'date': formatDate,
        });
      } catch (e) {
        print('Error adding document: $e');
      }
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              right: 16,
              left: 16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                  onChanged: (p0) {
                    userName = p0;
                  },
                  text: 'User_Name',
                ),
                SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                  onChanged: (p0) {
                    message = p0;
                  },
                  text: 'Message',
                ),
                SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                  text: 'Place',
                  onChanged: (p0) {
                    place = p0;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                  text: 'Phone_Number',
                  onChanged: (p0) {
                    phoneNumber = p0;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                MaterialButton(
                  minWidth: double.infinity,
                  height: 45,
                  onPressed: () async {
                    await addNotification();

                    await notificationHelper.sendNotification(
                      'message',
                      phoneNumber: phoneNumber,
                      place: place,
                      message: message,
                      userName: userName,
                    );

                    Navigator.pop(context); // Dismiss the bottom sheet
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('Send Notification'),
                  color: Colors.blue,
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomCardNotification extends StatelessWidget {
  const CustomCardNotification({Key? key, required this.snap})
      : super(key: key);
  final QueryDocumentSnapshot snap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 3),
        borderRadius: BorderRadius.circular(25),
        color: Colors.white70,
      ),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomListTile(
                  text: snap['message'],
                  icon: Icons.message,
                  fontSize: 20,
                  date: '',
                ),
                CustomListTile(
                  text: snap['userName'],
                  icon: Icons.person,
                  date: '',
                ),
                CustomListTile(
                  text: snap['place'],
                  icon: Icons.location_on,
                  date: '',
                ),
                CustomListTile(
                  text: snap['phoneNumber'],
                  icon: Icons.phone,
                  date: snap['date'],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  CustomListTile({
    Key? key,
    this.fontSize = 14,
    required this.text,
    required this.icon,
    this.date,
  }) : super(key: key);

  final String text;
  final double fontSize;
  final String? date;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.blue,
          size: 20,
        ),
        const SizedBox(
          width: 5,
        ),
        Container(
          width: 180,
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          date!,
          style: TextStyle(
            color: Colors.blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    Key? key,
    this.text,
    this.suffixIcon,
    this.isVisable = false,
    this.onChanged,
    this.validator,
    this.onPressed,
    this.textInputType = TextInputType.emailAddress,
    this.controller,
  }) : super(key: key);

  final String? text;
  final IconData? suffixIcon;
  final bool? isVisable;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Function()? onPressed;
  final TextInputType? textInputType;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: textInputType,
      validator: validator,
      onChanged: onChanged,
      obscureText: isVisable!,
      style: const TextStyle(
        color: Colors.black,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              suffixIcon,
              color: Colors.blue,
            ),
          ),
        ),
        errorStyle: TextStyle(color: Colors.white),
        hintText: text,
        hintStyle: const TextStyle(color: Colors.blue, fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            width: 5,
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(50.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            width: 5,
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}
