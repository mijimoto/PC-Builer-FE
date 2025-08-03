import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

// Screens
import 'forgot_password_page.dart';
import 'home_page.dart';
import 'sign_up_screen.dart';
import 'user_page.dart';
import 'log_in_page.dart';
import 'user_profile_edit.dart';
import 'item_batch.dart';
import 'DetailScreen.dart';
import 'InfoPartScreen.dart';
import 'HomeBuildPage.dart';
import 'AddItemPage.dart';
import 'reset_password_page.dart'; // Import your reset password screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _handleInitialUri();
    _listenForUriChanges();
  }

  Future<void> _handleInitialUri() async {
    try {
      final uri = await getInitialUri();
      _handleUri(uri);
    } catch (e) {
      print('Failed to get initial URI: $e');
    }
  }

  void _listenForUriChanges() {
    _sub = uriLinkStream.listen((Uri? uri) {
      _handleUri(uri);
    }, onError: (err) {
      print('Error receiving URI: $err');
    });
  }

  void _handleUri(Uri? uri) {
    if (uri != null && uri.scheme == 'pcbuilder' && uri.host == 'reset-password') {
      final token = uri.queryParameters['token'] ?? '';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(token: token),
        ),
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Builder Screens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: LogInScreen(), // default screen
    );
  }
}
