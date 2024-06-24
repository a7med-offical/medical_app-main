import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animator/widgets/attention_seekers/swing.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in.dart';
import 'package:flutter_animator/widgets/sliding_entrances/slide_in_up.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/auth/login_screen/login_screen.dart';

class PatientProfileScreen extends StatelessWidget {
  final String patientId;

  PatientProfileScreen({Key? key, required this.patientId}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue, // Set the background color to blue
          title: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('patients')
                .doc(patientId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading...');
              }
              if (snapshot.hasError) {
                return const Text('Error');
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text('Patient not found');
              }

              final patientData = snapshot.data!.data() as Map<String, dynamic>;
              return Text(
                patientData['name'] ?? 'Unknown',
                style: TextStyle(color: Colors.white), // Text color white
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(
                Icons.output_sharp,
                color: Colors.white,
              ),
            ),
          ],

          bottom: const TabBar(
            labelStyle: TextStyle(color: Colors.white, fontSize: 18),
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Reports'),
            ],
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('patients')
              .doc(patientId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('No patient data found.'));
            }

            final patientData = snapshot.data!.data() as Map<String, dynamic>;
            return TabBarView(
              children: [
                PatientDetails(patientId: patientId),
                PatientReportsPage(patientId: patientId),
              ],
            );
          },
        ),
      ),
    );
  }
}

class PatientDetails extends StatelessWidget {
  final String patientId;

  const PatientDetails({Key? key, required this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No patient data found.'));
        }

        var patientData = snapshot.data!.data() as Map<String, dynamic>;

        // Extract imageUrl or provide a default if not available
        String imageUrl = patientData['imageUrl'] ?? 'default_image_url';

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16),
                Center(
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : AssetImage('assets/images/default_image.png'),
                    // Use default_image.png from assets if imageUrl is empty
                  ),
                ),
                SizedBox(height: 20),
                _buildDetailItem('Name', patientData['name'] ?? 'Unknown'),
                SizedBox(height: 10),
                _buildDetailItem(
                  'Phone',
                  patientData['phone'] != null
                      ? patientData['phone'].toString()
                      : 'Unknown',
                ),
                SizedBox(height: 10),
                _buildDetailItem('Email', patientData['email'] ?? 'Unknown'),
                SizedBox(height: 10),
                _buildDetailItem('Role', patientData['role'] ?? 'Unknown'),
                // Add more fields as needed
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class PatientReportsPage extends StatefulWidget {
  final String patientId;

  PatientReportsPage({Key? key, required this.patientId}) : super(key: key);

  @override
  _PatientReportsPageState createState() => _PatientReportsPageState();
}

class _PatientReportsPageState extends State<PatientReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientId)
            .collection('reports')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final reports = snapshot.data?.docs ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text('No reports found.'));
          }
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              var report = reports[index].data() as Map<String, dynamic>;
              String description = report['description'] ?? 'No description';
              String imageUrl = report['image_url'] ?? '';
              Timestamp timestamp = report['timestamp'] ?? Timestamp.now();
              String doctor = report['Doctor name'] ?? 'Unknown doctor';

              // Format timestamp to a readable string
              String formattedDate =
                  DateFormat.yMMMd().add_jm().format(timestamp.toDate());

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.grey[700],
                          ),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        'Doctor: $doctor', // Hint before doctor's name
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Description : ' + description,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Reported on: $formattedDate', // Formatted date
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
