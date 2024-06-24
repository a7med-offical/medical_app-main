import 'package:flutter/material.dart';
import 'package:medical_app/auth/register_doctor_screen/register_doctor_screen.dart';

import '../auth/register_patient_screen/register_patient_screen.dart';

class JoinAppScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Positioned(
            left: MediaQuery.sizeOf(context).width / 2 - 100,
            right: MediaQuery.sizeOf(context).width / 2 - 100,
            top: MediaQuery.sizeOf(context).height * 0.35,
            child: Container(
              width: 100,
              height: 150,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/join.jfif'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 50),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Center(
                      child: Text(
                        "Are You?",
                        style: const TextStyle(
                          color: Color(0xFF9F73AB),
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 400), // Adjusted height for buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 50,
                        width: 150,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromRGBO(63, 59, 108, 1),
                              Color.fromRGBO(63, 59, 108, 1),
                            ],
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPatientPage()),
                            );
                          },
                          child: Text(
                            "Patient",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
