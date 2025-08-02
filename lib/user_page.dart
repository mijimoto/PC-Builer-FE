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
    print('UserProfile: initState called, accountid: ${widget.accountid}');
    _fetchUserData();
  }

  @override
  void dispose() {
    print('UserProfile: dispose called');
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    print('UserProfile: _getToken returned: ${token != null ? "Token found" : "No token"}');
    return token;
  }

  Future<void> _fetchUserData() async {
    print('UserProfile: _fetchUserData started, accountid: ${widget.accountid}');
    if (widget.accountid.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Cannot find account ID';
          _isLoading = false;
        });
      }
      print('UserProfile: _fetchUserData aborted: Empty accountid');
      return;
    }

    final token = await _getToken();
    if (token == null) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Token not found';
          _isLoading = false;
        });
      }
      print('UserProfile: _fetchUserData aborted: No token');
      return;
    }

    try {
      print('UserProfile: Sending GET to http://localhost:8080/api/v1/accounts/${widget.accountid}');
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/accounts/${widget.accountid}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      print('UserProfile: _fetchUserData response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('UserProfile: Parsed JSON: $jsonData');
        if (mounted) {
          setState(() {
            _firstName = jsonData['firstname'] ?? jsonData['firstName'] ?? 'Unknown';
            _lastName = jsonData['lastname'] ?? jsonData['lastName'] ?? '';
            _email = jsonData['email'] ?? '';
            _isLoading = false;
            _errorMessage = null;
          });
        }
        print('UserProfile: _fetchUserData succeeded, mounted: $mounted');
      } else if (response.statusCode == 404) {
        if (mounted) {
          setState(() {
            _errorMessage = 'User not found';
            _isLoading = false;
          });
        }
        print('UserProfile: _fetchUserData failed: User not found');
      } else if (response.statusCode == 401) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Unauthorized - Invalid token';
            _isLoading = false;
          });
        }
        print('UserProfile: _fetchUserData failed: Unauthorized');
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to fetch user data: ${response.statusCode} - ${response.body}';
            _isLoading = false;
          });
        }
        print('UserProfile: _fetchUserData failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection Error: ${e.toString()}';
          _isLoading = false;
        });
      }
      print('UserProfile: _fetchUserData error: ${e.toString()}');
    }
  }

  Future<void> _logout() async {
    print('UserProfile: _logout started');
    final token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No token found, logging out locally')),
        );
      }
      print('UserProfile: _logout no token, clearing local storage');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt');
      await prefs.remove('accountId'); // Fixed: Consistent key 'accountId'
      print('UserProfile: _logout navigating to LogInScreen');
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LogInScreen()),
          (Route<dynamic> route) => false,
        );
      }
      return;
    }

    try {
      print('UserProfile: Sending POST to http://localhost:8080/api/v1/accounts/logout');
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/accounts/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      print('UserProfile: _logout response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('jwt');
        await prefs.remove('accountId');
        print('UserProfile: _logout succeeded, cleared local storage, navigating to LogInScreen');
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LogInScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to log out: ${response.statusCode} - ${response.body}')),
          );
        }
        print('UserProfile: _logout failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection Error: ${e.toString()}')),
        );
      }
      print('UserProfile: _logout error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('UserProfile: build called, isLoading: $_isLoading, errorMessage: $_errorMessage');
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                print('UserProfile: Navigating to HomePageScreen');
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
                print('UserProfile: Navigating to BuildPageScreen');
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
              onPressed: () {
                print('UserProfile: Account button pressed (no navigation)');
              },
              child: Text(
                'Account',
                style: TextStyle(
                  color: Colors.blue,
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
            colors: [Color(0xFFD1C4E9), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$_firstName $_lastName',
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
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            print('UserProfile: Navigating to UserProfileEdit');
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
                          onPressed: _logout,
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
