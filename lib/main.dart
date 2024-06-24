import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/ai_screen/check_diseases_screen.dart';
import 'package:medical_app/home/home_doctor.dart';
import 'package:medical_app/home/user_home.dart';
import 'package:medical_app/on_boarding_screen/on_boarding_screen.dart';
import 'package:medical_app/provider/chat_provider.dart';
import 'ai_screen/check_diseases_screen.dart';
import 'package:medical_app/splash_screen/splash_screnn.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print(
            'Message also contained a notification: ${message.notification!.title}');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangeNotifier>(
      create: (context) => ChatService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home:
            SplashScreenWrapper(), // Use SplashScreenWrapper to handle initial navigation
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateToHome(FirebaseAuth.instance.currentUser?.uid ?? '');
  }

  Future<void> checkUserLogin() async {
    FirebaseAuth.instance.userChanges().listen((User? user) async {
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      } else {
        await _navigateToHome(user.uid);
      }
    });
  }

  Future<void> _navigateToHome(String userId) async {
    try {
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(userId)
          .get();
      if (doctorSnapshot.exists) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorHomeScreen(),
          ),
          (route) => false,
        );
      } else {
        DocumentSnapshot patientSnapshot = await FirebaseFirestore.instance
            .collection('patients')
            .doc(userId)
            .get();
        if (patientSnapshot.exists) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => UserHome(),
            ),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => OnboardingScreen(),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation Error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(); // Placeholder widget until user's login status is checked
  }
}
