import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

class CheckDiseases extends StatefulWidget {
  @override
  _CheckDiseasesState createState() => _CheckDiseasesState();
}

class _CheckDiseasesState extends State<CheckDiseases> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedGender;
  String? _selectedBloodType;
  String? _selectedMedication;
  TextEditingController _ageController = TextEditingController();
  TextEditingController _oxygenSaturationController = TextEditingController();
  TextEditingController _bodyTemperatureController = TextEditingController();
  TextEditingController _bloodSugarController = TextEditingController();
  TextEditingController _systolicController = TextEditingController();
  TextEditingController _diastolicController = TextEditingController();

  List<String> _genders = ['Female', 'Male'];
  List<String> _bloodTypes = ['O-', 'O+', 'B-', 'AB+', 'A+', 'AB-', 'A-', 'B+'];
  List<String> _medications = [
    'Aspirin',
    'Lipitor',
    'Penicillin',
    'Paracetamol',
    'Ibuprofen'
  ];

  Future<void> _sendData() async {
    try {
      if (_formKey.currentState!.validate()) {
        var url = Uri.parse('https://connection-1-vszo.onrender.com/predict');
        var response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "Age": [int.parse(_ageController.text)],
            "Gender": [_selectedGender],
            "Blood Type": [_selectedBloodType],
            "Medication": [_selectedMedication],
            "Oxygen Saturation (%)": [
              double.parse(_oxygenSaturationController.text)
            ],
            "Body Temperature (°C)": [
              double.parse(_bodyTemperatureController.text)
            ],
            "Blood Sugar (mg/dL)": [double.parse(_bloodSugarController.text)],
            "Systolic": [int.parse(_systolicController.text)],
            "Diastolic": [int.parse(_diastolicController.text)]
          }),
        );

        if (response.statusCode == 200) {
          _showDialog('Result', '${response.body}');
        } else {
          _showDialog(
              'Error', 'Request failed with status: ${response.statusCode}.');
        }
      }
    } on Exception catch (e) {
      _showDialog('Error', 'Request failed Enter avalid data.');
    }
  }

  void _showDialog(String title, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.bottomSlide,
      title: title,
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      descTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      desc: message,
      btnOkOnPress: () {},
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Check Diseases'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_ageController, 'Age', TextInputType.number),
              SizedBox(height: 16),
              _buildDropdownField(_genders, 'Gender', (value) {
                setState(() {
                  _selectedGender = value;
                });
              }),
              SizedBox(height: 16),
              _buildDropdownField(_bloodTypes, 'Blood Type', (value) {
                setState(() {
                  _selectedBloodType = value;
                });
              }),
              SizedBox(height: 16),
              _buildDropdownField(_medications, 'Medication', (value) {
                setState(() {
                  _selectedMedication = value;
                });
              }),
              SizedBox(height: 16),
              _buildTextField(_oxygenSaturationController,
                  'Oxygen Saturation (%)', TextInputType.number),
              SizedBox(height: 16),
              _buildTextField(_bodyTemperatureController,
                  'Body Temperature (°C)', TextInputType.number),
              SizedBox(height: 16),
              _buildTextField(_bloodSugarController, 'Blood Sugar (mg/dL)',
                  TextInputType.number),
              SizedBox(height: 16),
              _buildTextField(
                  _systolicController, 'Systolic', TextInputType.number),
              SizedBox(height: 16),
              _buildTextField(
                  _diastolicController, 'Diastolic', TextInputType.number),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendData,
                child: Text('Chack'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      TextInputType keyboardType) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal, width: 2.0),
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(
      List<String> items, String label, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }
}
