import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/auth/login_screen/login_screen.dart';
import 'package:medical_app/chat/user_chat_list.dart';

class RegisterDoctorPage extends StatefulWidget {
  @override
  _RegisterDoctorPageState createState() => _RegisterDoctorPageState();
}

class _RegisterDoctorPageState extends State<RegisterDoctorPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String name = '';
  String number = '';
  String jobTitle = '';
  String location = '';
  String availableTime = '';
  String email = '';
  String password = '';
  UserCredential? userCredential;
  void registerDoctor() async {
    if (_formKey.currentState!.validate()) {
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await _firestore
            .collection('doctors')
            .doc(userCredential!.user!.uid)
            .set({
          'name': name,
          'number': number,
          'jobTitle': jobTitle,
          'location': location,
          'availableTime': availableTime,
          'email': email,
          'uid': userCredential!.user!.uid,
          'role': 'doctor',
        });

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            )); // Sh
      } on FirebaseAuthException catch (e) {
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register as Doctor'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Number'),
                onChanged: (value) => number = value,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your number' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Job Title'),
                onChanged: (value) => jobTitle = value,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your job title' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                onChanged: (value) => location = value,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your location' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Available Time'),
                onChanged: (value) => availableTime = value,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your available time' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) => email = value,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your email' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) => password = value,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your password' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  registerDoctor();
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
