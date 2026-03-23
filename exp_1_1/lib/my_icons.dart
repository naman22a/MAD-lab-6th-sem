import 'package:flutter/material.dart';

class MyIcons extends StatelessWidget {
  const MyIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_3x3,
            color: Colors.teal,
            size: 100.0,
          ),
          Icon(
            Icons.phone,
            color: Colors.teal,
            size: 100.0,
          ),
          Icon(
            Icons.home,
            color: Colors.teal,
            size: 100.0,
          ),
        ],
      ),
    );
  }
}
