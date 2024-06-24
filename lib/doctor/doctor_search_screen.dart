import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/auth/login_screen/login_screen.dart';
import 'package:medical_app/doctor/patient_details_screen.dart';
import 'package:medical_app/home/home_doctor.dart';

class DoctorSearchPage extends StatefulWidget {
  const DoctorSearchPage({Key? key}) : super(key: key);

  @override
  _DoctorSearchPageState createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final StreamController<String> _searchStreamController =
      StreamController<String>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchStreamController.add(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchStreamController.close();
    super.dispose();
  }

  Stream<QuerySnapshot> searchPatients(String query) {
    if (query.isEmpty) {
      return FirebaseFirestore.instance.collection('patients').snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('patients')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots();
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Set the background color to blue
        title: const Text(
          'Doctor Home Page',
          style: TextStyle(color: Colors.white), // Text color white
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Patients by Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<String>(
                stream: _searchStreamController.stream,
                initialData: '',
                builder: (context, snapshot) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: searchPatients(snapshot.data!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No patients found'));
                      }

                      final patients = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          final patient = patients[index];
                          final patientData =
                              patient.data() as Map<String, dynamic>;

                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                backgroundImage:
                                    patientData.containsKey('imageUrl') &&
                                            patientData['imageUrl'].isNotEmpty
                                        ? NetworkImage(patientData['imageUrl'])
                                        : null,
                                child: patientData.containsKey('imageUrl') &&
                                        patientData['imageUrl'].isNotEmpty
                                    ? null
                                    : Text(
                                        patientData['name'][0].toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                              ),
                              title: Text(
                                patientData['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(patientData.containsKey('phone')
                                  ? patientData['phone']
                                  : 'No details available'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PatientDetailScreen(patient: patient),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
