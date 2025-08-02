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
import 'HomeBuildPage.dart';
import 'AddItemPage.dart'; // From the first file

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
      home: HomePageScreen(),
      //home: SignUpScreen(),
      //home: AccountScreen(),
      //home: UserProfileEdit(),
      //home: ItemListPage(),
     //home: InfoPartScreen(partName: 'CPU'),
    );
  }
}