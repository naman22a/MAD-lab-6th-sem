import 'package:flutter/material.dart';
import 'counter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  final Counter counter = Counter();

  void incrementCounter() {
    print("🔼 Increment button pressed");
    print("Before increment: ${counter.value}");

    counter.increment();

    print("After increment: ${counter.value}");
  }

  void decrementCounter() {
    print("🔽 Decrement button pressed");
    print("Before decrement: ${counter.value}");

    counter.decrement();

    print("After decrement: ${counter.value}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Testing & Debug App"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Value: ${counter.value}",
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                incrementCounter();
              });
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                decrementCounter();
              });
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
