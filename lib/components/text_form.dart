import 'package:flutter/material.dart';

class CustomTextForm extends StatelessWidget {
  const CustomTextForm({
    super.key,
    required this.hintText,
    required this.myController,
    required this.validator,
    this.keyboardType,
  });

  final String hintText;
  final TextEditingController myController;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: myController,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFBDBDBD),
          ),
          borderRadius: BorderRadius.circular(70),
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
      ),
    );
  }
}
