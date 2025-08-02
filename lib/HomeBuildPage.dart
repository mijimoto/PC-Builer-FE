import 'package:flutter/material.dart';
import 'AddItemPage.dart';
import 'home_page.dart'; // Import your HomePageScreen
import 'user_page.dart'; // Import your UserProfile

class BuildPageScreen extends StatefulWidget {
  const BuildPageScreen({Key? key}) : super(key: key);

  @override
  State<BuildPageScreen> createState() => _BuildPageScreenState();
}

class _BuildPageScreenState extends State<BuildPageScreen> {
  // Non-final list to allow dynamic updates
  final List<Map<String, String>> builds = [
    {'title': 'Build1'},
    {'title': 'Build2'},
    {'title': 'Build3'},
  ];

  // Function to add a new build with a default title
  void _addNewBuild() {
    setState(() {
      // Generate a new title based on the current number of builds
      final newBuildNumber = builds.length + 1;
      builds.add({'title': 'Build$newBuildNumber'});
    });
  }

  // Function to delete a build at a given index
  void _deleteBuild(int index) {
    setState(() {
      builds.removeAt(index);
    });
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
              onPressed: () {}, // No navigation for Build (current screen)
              child: Text(
                'Build',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfile()),
                );
              },
              child: Text(
                'Account',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(
          0xFFD1C4E9,
        ), // Light purple to match gradient
        elevation: 0, // Remove shadow for seamless gradient transition
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
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: builds.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3 / 4,
            ),
            itemBuilder: (context, index) {
              return BuildCard(
                title: builds[index]['title']!,
                index: index,
                onCheckPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddItemScreen()),
                  );
                },
                onDeletePressed: () async {
                  // Show confirmation dialog
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: Text(
                        'Do you really want to delete ${builds[index]['title']}?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  // If confirmed, delete the build
                  if (confirm == true) {
                    _deleteBuild(index);
                  }
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBuild, // Add new build directly
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BuildCard extends StatelessWidget {
  final String title;
  final int index;
  final VoidCallback onCheckPressed;
  final VoidCallback onDeletePressed;

  const BuildCard({
    required this.title,
    required this.index,
    required this.onCheckPressed,
    required this.onDeletePressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: onDeletePressed,
                child: const Text("Delete"),
              ),
              TextButton(onPressed: onCheckPressed, child: const Text("Check")),
            ],
          ),
        ],
      ),
    );
  }
}
