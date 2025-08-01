import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'log_in_page.dart';
import 'dart:io'; // For exit()
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;
  bool _hoverSignUp = false;
  bool _hoverAlready = false;

  final emailRegex = RegExp(r'^[\w-\.]+@gmail\.com$');

  Future<void> _validateAndSubmit() async {
    setState(() {
      _errorMessage = null;
    });

    final firstName = _firstNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill out all required fields.';
      });
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    try {
      // Gọi API đăng ký
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/accounts/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstname': firstName,
          'lastname': _lastNameController.text.trim(),
          'email': email,
          'passwordhased': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your email. We have sent a verification mail'),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LogInScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Registered Failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection Failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    const Text(
                      "Create An Account",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 8),

                    MouseRegion(
                      onEnter: (_) => setState(() => _hoverSignUp = true),
                      onExit: (_) => setState(() => _hoverSignUp = false),
                      child: GestureDetector(
                        onTap: _validateAndSubmit,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: _hoverSignUp
                                ? const Color(0xFFa05279)
                                : const Color(0xFF934B74),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text.rich(
                      TextSpan(
                        text: "By signing up, you agree with the ",
                        children: [
                          TextSpan(
                            text: "Terms of Service",
                            style: const TextStyle(color: Colors.blue),
                          ),
                          const TextSpan(text: " and "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(height: 24),

                    MouseRegion(
                      onEnter: (_) => setState(() => _hoverAlready = true),
                      onExit: (_) => setState(() => _hoverAlready = false),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LogInScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                            color: _hoverAlready
                                ? Colors.grey.shade300
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Already have an account?",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Exit (X) Button
          // Positioned(
          //   top: 36,
          //   left: 20,
          //   child: GestureDetector(
          //     onTap: () => exit(0),
          //     child: const Icon(Icons.close, size: 24),
          //   ),
          // ),
        ],
      ),
    );
  }
}