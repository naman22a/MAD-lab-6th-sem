import 'package:exp_2/screens/contact_screen.dart';
import 'package:exp_2/screens/projects_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/photo.jpeg'),
                radius: 80,
              ),
              SizedBox(height: 20),
              Text(
                'Naman Arora',
                style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Btech AIML - A',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              Text(
                '2023 - 2027',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              ListTile(
                leading: Icon(Icons.folder),
                title: Text('View Projects'),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProjectsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.link),
                title: Text('Contact'),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ContactScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'My name is Naman Arora. I am a Full Stack Developer with a strong focus on Backend Development and DevOps. I am passionate about building scalable systems, designing efficient backend architectures, and managing modern cloud-based infrastructure. I enjoy working on complex technical problems and creating software systems that are reliable, secure, and efficient.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                'I primarily work on backend services, APIs, and system infrastructure. I am particularly interested in how large-scale systems are designed, deployed, and maintained using modern development and DevOps practices.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
