import 'package:flutter/material.dart';

// Screens
import 'build_page.dart';
import 'forgot_password_page.dart';
import 'home_page.dart';
import 'sign_up_screen.dart';
import 'user_page.dart';
import 'log_in_page.dart'; 
import 'user_profile_edit.dart';
import 'item_batch.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Builder Screens',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      // ✅ Choose ONE to test at a time:
      //home: LogInScreen(),           // log_in_page.dart
      //home: BuildPageScreen(),       // build_page.dart
      //home: ForgotPasswordScreen(),  // forgot_password_page.dart
      //home: HomePageScreen(),        // home_page.dart
      //home: SignUpScreen(),          // sign_up_screen.dart
      //home: AccountScreen(),         // user_page.dart
      home: UserProfileEdit(),       // user_profile_edit.dart
      //home: ItemListPage(),       // item_batch.dart
    );
  }
}
