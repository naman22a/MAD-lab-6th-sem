import 'package:flutter/material.dart';

class Buttons extends StatelessWidget {
  const Buttons({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            child: Text('Click Me'),
          ),
          TextButton(
            onPressed: () {},
            child: Text('Click Me'),
          ),
          OutlinedButton(
            onPressed: () {},
            child: Text('Click Me'),
          ),
        ],
      ),
    );
  }
}
