import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_screen/login_screen.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_search);
  }

  @override
  void dispose() {
    _searchController.removeListener(_search);
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> addToDoctorSubcollection(
      String doctorUid, String patientUid) async {
    try {
      var doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorUid)
          .get();
      if (!doctorDoc.exists) {
        throw Exception('Doctor not found');
      }
      var doctorData = doctorDoc.data() as Map<String, dynamic>;
      String doctorName = doctorData['name'] ?? 'Unknown';
      String patientImageUrl = doctorData['imageUrl'] ?? ''; // Fetch imageUrl

      var patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientUid)
          .get();
      if (!patientDoc.exists) {
        throw Exception('Patient not found');
      }
      var patientData = patientDoc.data() as Map<String, dynamic>;
      String patientName = patientData['name'] ?? 'Unknown';
      String patientEmail = patientData['email'] ?? 'Unknown';

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorUid)
          .collection('patients')
          .doc(patientUid)
          .set({
        'recieverId': patientUid,
        'name': patientName,
        'email': patientEmail,
        'timestamp': Timestamp.now(),
        'imageUrl': patientData['imageUrl'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Patient added to doctor\'s records'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add patient to doctor\'s records'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Error adding patient to doctor: $e');
    }
  }

  Future<void> addToPatientSubcollection(
      String doctorUid, String patientUid) async {
    try {
      var patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientUid)
          .get();
      if (!patientDoc.exists) {
        throw Exception('Patient not found');
      }
      var patientData = patientDoc.data() as Map<String, dynamic>;
      String patientName = patientData['name'] ?? 'Unknown';

      var doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorUid)
          .get();
      if (!doctorDoc.exists) {
        throw Exception('Doctor not found');
      }
      var doctorData = doctorDoc.data() as Map<String, dynamic>;
      String doctorName = doctorData['name'] ?? 'Unknown';
      String doctorJobTitle = doctorData['jobTitle'] ?? 'Unknown';
      String patientImageUrl = doctorData['imageUrl'] ?? ''; // Fetch imageUrl

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientUid)
          .collection('doctors')
          .doc(doctorUid)
          .set({
        'recieverId': doctorUid,
        'name': doctorName,
        'jobTitle': doctorJobTitle,
        'timestamp': Timestamp.now(),
        'imageUrl': patientData['imageUrl'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Doctor added to patient\'s records'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add doctor to patient\'s records'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Error adding doctor to patient: $e');
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Doctors',
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false);
              },
              icon: Icon(
                Icons.output_sharp,
                color: Colors.white,
              ))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Doctor',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('doctors').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var docs = snapshot.data!.docs;
                var filteredDocs = docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  var name = (data['name'] as String? ?? '').toLowerCase();
                  var jobTitle =
                      (data['jobTitle'] as String? ?? '').toLowerCase();
                  return name.contains(_searchQuery) ||
                      jobTitle.contains(_searchQuery);
                }).toList();
                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var data =
                        filteredDocs[index].data() as Map<String, dynamic>;
                    String name = data['name'] ?? 'No name';
                    String jobTitle = data['jobTitle'] ?? 'No job title';
                    String location = data['location'] ?? 'No location';
                    String imageUrl = data['imageUrl'] ?? '';
                    String doctorUid = data['uid'] ?? '';

                    // Determine avatar based on imageUrl or first character of name
                    Widget leadingWidget;
                    if (imageUrl.isNotEmpty) {
                      leadingWidget = CircleAvatar(
                        backgroundImage: NetworkImage(imageUrl),
                      );
                    } else {
                      // Use the first character of the name as initials
                      String initials =
                          name.isEmpty ? '?' : name[0].toUpperCase();
                      leadingWidget = CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          initials,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: leadingWidget,
                          title: Text(
                            'Dr. $name',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            '$jobTitle\n$location',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              String patientUid =
                                  FirebaseAuth.instance.currentUser!.uid;
                              await addToDoctorSubcollection(
                                  doctorUid, patientUid);
                              await addToPatientSubcollection(
                                  doctorUid, patientUid);
                            },
                            icon: Icon(Icons.chat_bubble, color: Colors.blue),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
