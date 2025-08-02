import 'package:flutter/material.dart';
import 'sign_up_screen.dart';
import 'forgot_password_page.dart';
import 'user_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email and password are required';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/accounts/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String?;
        final accountId = data['accountId']?.toString();

        if (token != null && accountId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt', token);
          await prefs.setString('accountId', accountId);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged In!'),
              duration: Duration(seconds: 2),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfile(accountid: accountId),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Invalid response from server';
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage =
              errorData['error'] ??
              'Login failed with code ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection Failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('LogInScreen: build called, isLoading: $_isLoading, errorMessage: $_errorMessage');
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD1C4E9), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 12.0),
                        child: Text(
                          "Sign in with email",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.normal,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                  ),
                                  obscureText: true,
                                ),
                                if (_errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      print('LogInScreen: Navigating to ForgotPasswordScreen');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(color: Color(0xFFB0BEC5)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF800080),
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: _isLoading ? null : _handleLogin,
                                  child: const Text('Login'),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          print('LogInScreen: Navigating to SignUpScreen');
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const SignUpScreen(),
                                            ),
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 166, 134, 221),
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text('Need an account'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 28),
              onPressed: () {
                print('LogInScreen: Navigating to HomePageScreen');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePageScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
