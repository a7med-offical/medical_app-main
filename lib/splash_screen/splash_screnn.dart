import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medical_app/home_screen/home_screen.dart';
import 'package:medical_app/on_boarding_screen/on_boarding_screen.dart';

// ignore: camel_case_types
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// ignore: camel_case_types
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), navigator);
  }

  void navigator() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const OnboardingScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffF4F4F4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.network(
              'https://aanmc.org/wp-content/uploads/2017/05/Becoming-an-ND.jpg',
            ),
            const CircularProgressIndicator(
              backgroundColor: Colors.blue,
              strokeWidth: 6,
              color: Colors.white,
            ),
            Column(
              children: const [
                Text(
                  'Welcome ',
                  style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 60,
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
