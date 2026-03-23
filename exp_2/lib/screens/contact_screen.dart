import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _openGithub() async {
    final url = Uri.parse('https://github.com/naman22a');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _openLinkedin() async {
    final url = Uri.parse('https://linkedin.com/in/naman22a');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _openEmail() async {
    final url = Uri.parse('mailto:namanarora1022@gmail.com');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade100,
      appBar: AppBar(
        title: Text('Contact'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade500,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 40.0,
        ),
        child: Column(
          children: [
            ListTile(
              tileColor: Colors.teal.shade200,
              leading: FaIcon(
                FontAwesomeIcons.github,
                color: Colors.black,
              ),
              title: Column(
                children: [
                  Text(
                    'Github',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'https://github.com/naman22a',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              trailing: Icon(Icons.open_in_new),
              onTap: _openGithub,
            ),
            SizedBox(height: 20),
            ListTile(
              tileColor: Colors.teal.shade200,
              leading: FaIcon(
                FontAwesomeIcons.linkedin,
                color: Colors.blue,
              ),
              title: Column(
                children: [
                  Text(
                    'Linkedin',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'https://linkedin.com/in/naman22a',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              trailing: Icon(Icons.open_in_new),
              onTap: _openLinkedin,
            ),
            SizedBox(height: 20),
            ListTile(
              tileColor: Colors.teal.shade200,
              leading: FaIcon(
                FontAwesomeIcons.google,
                color: Colors.red,
              ),
              title: Column(
                children: [
                  Text(
                    'Gmail',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'namanarora1022@gmail.com',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              trailing: Icon(Icons.open_in_new),
              onTap: _openEmail,
            ),
          ],
        ),
      ),
    );
  }
}
