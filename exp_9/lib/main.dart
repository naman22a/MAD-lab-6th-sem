import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'API App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: ApiHome(),
    );
  }
}

class ApiHome extends StatefulWidget {
  @override
  _ApiHomeState createState() => _ApiHomeState();
}

class _ApiHomeState extends State<ApiHome> {
  List users = [];
  bool isLoading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/users'));

      print("STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          users = data['users'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Server error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Network error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Data Viewer"), centerTitle: true),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['image']),
                    ),
                    title: Text("${user['firstName']} ${user['lastName']}"),
                    subtitle: Text(user['email']),
                  ),
                );
              },
            ),
    );
  }
}
