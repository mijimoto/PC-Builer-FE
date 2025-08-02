import 'package:flutter/material.dart';

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
import 'BuildPageScreen.dart'; // From the first file
import 'reset_password_page.dart'; // Import the reset password page

void main() {
  runApp(const MyApp()); // ✅ Launch the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Builder Screens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,

      // ✅ Choose ONE to test at a time:
      //home: BuildPageScreen(),
      //home: LogInScreen(),
      //home: ForgotPasswordScreen(),
      //home: HomePageScreen(),
      //home: SignUpScreen(),
      //home: AccountScreen(),
      //home: UserProfileEdit(),
      //home: ItemListPage(),
      //home: InfoPartScreen(partName: 'CPU'),
      home: ResetPasswordPage(token: '35fb64d6-4c51-4dfd-b18a-d16155eb8317'), // ✅ Reset Password Page
    );
  }
}
