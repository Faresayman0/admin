import 'package:flutter/material.dart';

class CustomTextForm extends StatelessWidget {
  const CustomTextForm({
    Key? key,
    required this.hintText,
    required this.myController,
    required this.validator,
    this.keyboardType,
    this.prefixIcon, // Make prefixIcon optional
  });

  final String hintText;
  final TextEditingController myController;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final IconData? prefixIcon; // Make prefixIcon optional

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.blue,
      validator: validator,
      controller: myController,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.blue,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFBDBDBD),
          ),
          borderRadius: BorderRadius.circular(70),
        ),
        fillColor: Colors.grey[100],
        filled: true,
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFBDBDBD),
          ),
          borderRadius: BorderRadius.circular(70),
        ),
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(
                  prefixIcon,
                  color: Colors.blue,
                ),
              )
            : null,
      ),
    );
  }
}
