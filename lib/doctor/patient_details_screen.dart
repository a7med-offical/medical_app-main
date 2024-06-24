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
import 'package:medical_app/auth/login_screen/login_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  final DocumentSnapshot patient;

  const PatientDetailScreen({Key? key, required this.patient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final patientData = patient.data() as Map<String, dynamic>;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: const Text('User Chat',
              style: TextStyle(
                color: Colors.white,
              )),
          backgroundColor: Colors.blue[800],
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
            labelColor: Colors.white,
            labelStyle: TextStyle(fontSize: 16),
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Reports'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PatientDetails(patientData: patientData),
            PatientReports(patientId: patient.id),
          ],
        ),
      ),
    );
  }
}

class PatientDetails extends StatelessWidget {
  final Map<String, dynamic> patientData;

  const PatientDetails({Key? key, required this.patientData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = patientData['imageUrl'] ?? 'assets/images/person.png';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Swing(
              child: CircleAvatar(
                radius: 80,
                backgroundImage: imageUrl.startsWith('http')
                    ? NetworkImage(imageUrl)
                    : AssetImage(imageUrl),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailItem('Name', patientData['name'] ?? 'Unknown'),
          const SizedBox(height: 10),
          _buildDetailItem(
              'phone',
              patientData['phone'] != null
                  ? patientData['phone'].toString()
                  : 'Unknown'),
          const SizedBox(height: 10),
          _buildDetailItem('Email', patientData['email'] ?? 'Unknown'),
          const SizedBox(height: 10),
          _buildDetailItem('status', patientData['role'] ?? 'Unknown'),
          // You can add more fields here
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return FadeIn(
      child: Container(
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
                style: TextStyle(
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
      ),
    );
  }
}

class PatientReports extends StatefulWidget {
  final String patientId;

  const PatientReports({Key? key, required this.patientId}) : super(key: key);

  @override
  _PatientReportsState createState() => _PatientReportsState();
}

class _PatientReportsState extends State<PatientReports> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadReport() async {
    if (_image == null || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide an image and description')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });
    var name = '';
    FirebaseFirestore.instance
        .collection('doctors')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('name')) {
          String? name = data["name"];
          print("Name: $name");
          setState(() {});
          // Use the name variable as needed
        } else {
          print("Name field does not exist in the document.");
        }
      } else {
        print("Document does not exist.");
      }
    }).catchError((error) {
      // Handle any errors here
      print("Error getting document: $error");
    });
    try {
      // Fetch doctor's name from Firestore
      String doctorName = '';
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic>? data =
              documentSnapshot.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('name')) {
            doctorName = data['name'];
          } else {
            print("Name field does not exist in the document.");
          }
        } else {
          print("Document does not exist.");
        }
      });

      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
          'reports/${widget.patientId}/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Add report details to Firestore
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('reports')
          .add({
        'description': _descriptionController.text,
        'image_url': downloadUrl,
        'Doctor name': doctorName, // Use doctor's name here
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report uploaded successfully')),
      );

      _descriptionController.clear();
      setState(() {
        _image = null;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _image != null
                ? Image.file(
                    _image!,
                    height: 150,
                  )
                : Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Center(child: Text('No image selected')),
                  ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadReport,
                    child: const Text('Upload Report'),
                  ),
          ],
        ),
      ),
    );
  }
}
