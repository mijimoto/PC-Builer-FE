import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile_edit.dart';
import 'log_in_page.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart'; 
import 'HomeBuildPage.dart'; 
import 'dart:convert';

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

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt'); // ✅ Fixed: Use 'jwt' key (same as login)
  }

  Future<void> _fetchUserData() async {
    if (widget.accountid.isEmpty) {
      setState(() {
        _errorMessage = 'Cannot find account ID';
        _isLoading = false;
      });
      return;
    }

    final token = await _getToken();
    if (token == null) {
      setState(() {
        _errorMessage = 'Token not found';
        _isLoading = false;
      });
      return;
    }

    try {
      print('🔍 Making API call to: http://localhost:8080/api/v1/accounts/${widget.accountid}');
      print('🔍 Using token: $token');
      
      // Call your backend's findById endpoint
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/accounts/${widget.accountid}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Response Status: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('🔍 Parsed JSON: $jsonData');
        
        setState(() {
          // Match the fields from your AccountsDTO
          _firstName = jsonData['firstname'] ?? jsonData['firstName'] ?? 'Unknown';
          _lastName = jsonData['lastname'] ?? jsonData['lastName'] ?? '';
          _email = jsonData['email'] ?? '';
          _isLoading = false;
          _errorMessage = null;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'User not found';
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'Unauthorized - Invalid token';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch user data. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection Error: $e';
        _isLoading = false;
      });
      print('🔍 Error: $e');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt'); // Clear the token
    await prefs.remove('account_id'); // Clear account ID if stored
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LogInScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable default back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePageScreen(),
                  ),
                );
              },
              child: Text(
                'Home',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BuildPageScreen(),
                  ),
                );
              },
              child: Text(
                'Build',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            TextButton(
              onPressed: () {}, // No navigation for Account (current screen)
              child: Text(
                'Account',
                style: TextStyle(
                  color: Colors.blue, // Highlight Account tab
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD1C4E9),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD1C4E9), Colors.white], // Light purple to white
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'UserName',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Last Name: $_lastName',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Email: $_email',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
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
                      builder: (context) => UserProfileEdit(accountid: widget.accountid),
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
                  // Navigate to login screen and clear the navigation stack
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
      ),
    );
  }
}
