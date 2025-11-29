import 'package:flutter/material.dart';

class CustomLogo extends StatelessWidget {
  const CustomLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipOval(
        child: Image.asset(
          'image/shady.jpg',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
