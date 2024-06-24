import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/ai_screen/check_diseases_screen.dart';
import 'package:medical_app/chat/user_chat_list.dart';
import 'package:medical_app/patient/notification_screen.dart';
import 'package:medical_app/patient/patient_profile_screen.dart';
import 'package:medical_app/patient/search_screen.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});
  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    SearchPage(),
    HomeUserChat(),
    PatientProfileScreen(
      patientId: FirebaseAuth.instance.currentUser!.uid,
    ),
    NotificationScreen(),
  ];
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return CheckDiseases();
          }));
        },
        child: Container(
          height: 30,
          width: 30,
          child: Icon(Icons.person_search_sharp),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
