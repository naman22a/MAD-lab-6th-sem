import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  Future<void> _kubesageUrl() async {
    final url = Uri.parse('https://github.com/naman22a/kubesage');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _ojUrl() async {
    final url = Uri.parse('https://github.com/naman22a/online-judge-platform');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade100,
      appBar: AppBar(
        title: Text('Projects'),
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
              leading: FaIcon(
                FontAwesomeIcons.code,
                color: Colors.orange,
              ),
              title: Text(
                'Online Judge Platform',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Icon(Icons.open_in_new),
              onTap: _ojUrl,
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.kubernetes,
                color: Colors.indigo,
              ),
              title: Text(
                'KubeSage',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: GestureDetector(
                onTap: _kubesageUrl,
                child: Icon(
                  Icons.open_in_new,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
