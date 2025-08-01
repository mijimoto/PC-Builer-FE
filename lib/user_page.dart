import 'package:flutter/material.dart';
import 'user_profile_edit.dart';
import 'log_in_page.dart';
import 'package:http/http.dart' as http; // For API calls
import 'dart:convert'; // For JSON encoding

class UserProfile extends StatefulWidget {
  final String accountid;

  const UserProfile({Key? key, required this.accountid}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String _firstName = 'UserName';
  String _lastName = '';
  String _email = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (widget.accountid.isEmpty) {
      setState(() {
        _errorMessage = 'Can not find account ID';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/v1/accounts/${widget.accountid}'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _firstName = data['firstname'] ?? _firstName;
          _lastName = data['lastname'] ?? _lastName;
          _email = data['email'] ?? _email;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Fetching Error. Error Code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connenction Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {},
              child: Text('Home', style: TextStyle(color: Colors.black87)),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'User Profile',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text('Build', style: TextStyle(color: Colors.black87)),
            ),
            TextButton(
              onPressed: () {},
              child: Text('Account', style: TextStyle(color: Colors.black87)),
            ),
          ],
        ),
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _firstName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'First Name: $_firstName',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Last Name: $_lastName',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Email: $_email',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileEdit(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF800080),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LogInScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Text(
                      'Log Out',
                      style: TextStyle(color: Color(0xFFB0BEC5)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
