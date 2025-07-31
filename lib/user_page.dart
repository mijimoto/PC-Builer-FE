import 'package:flutter/material.dart';
import 'user_profile_edit.dart';
import 'log_in_page.dart';
import 'home_page.dart'; // Import HomePageScreen
import 'BuildPage.dart'; // Import BuildPageScreen

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

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
                        'First Name: Sorakado ',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Last Name: Aoi',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Email: nuhuh@gmail.com',
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
                    MaterialPageRoute(builder: (context) => UserProfileEdit()),
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
