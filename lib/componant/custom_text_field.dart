import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData iconData;
  final Function(String) onChanged;
  TextEditingController? controller;
  CustomTextField(
      {super.key,
      required this.hintText,
      required this.iconData,
      required this.onChanged,
      this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: TextFormField(
        controller: controller,
        validator: (value) =>
            value == null ? 'Sorry this field is required' : null,
        onChanged: onChanged,
        decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(iconData),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(16),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            )),
      ),
    );
  }
}
