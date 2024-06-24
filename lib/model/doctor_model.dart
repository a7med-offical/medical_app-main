import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String uid;
  final String number;
  final String name;
  final String jobTitle;
  final String email;

  Doctor({
    required this.uid,
    required this.number,
    required this.name,
    required this.jobTitle,
    required this.email,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      uid: json['uid'] ?? '',
      number: json['number'] ?? '',
      name: json['name'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class DoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Doctor?> getDoctorByUid(String doctorUid) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('doctors')
          .where('uid', isEqualTo: doctorUid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Doctor.fromJson(querySnapshot.docs.first.data());
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching doctor data: $e');
      return null;
    }
  }
}
