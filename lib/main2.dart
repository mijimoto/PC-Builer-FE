import 'package:flutter/material.dart';
import 'package:test1/buildPart/BuildPageScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Build Page',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BuildPageScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
