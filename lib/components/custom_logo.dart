import 'package:flutter/material.dart';

class CustomLogo extends StatelessWidget {
  const CustomLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(90),
          color: Colors.grey[200],
        ),
        child: ClipOval(
          child: Image.asset(
            "asset/images/consticon.png",
            height: 50,
          ),
        ),
      ),
    );
  }
}
