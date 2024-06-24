import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String textButton;
  final void Function() onPressed;
  const CustomButton(
      {super.key, required this.textButton, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          textButton,
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 60),
            backgroundColor: Colors.purple,
            shape:
                BeveledRectangleBorder(borderRadius: BorderRadius.circular(2))),
      ),
    );
  }
}
