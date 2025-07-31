import 'package:flutter/material.dart';
import 'build_page.dart'; 

class HomePageScreen extends StatelessWidget {
  final List<Map<String, String>> builds = [
    {'title': 'Build1'},
    {'title': 'Build2'},
    {'title': 'Build3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Colors.grey[200],
            height: 48.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Home', 'Search', 'Build', 'Account']
                  .map(
                    (tab) => TextButton(
                      onPressed: () {},
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: tab == 'Build' ? Colors.blue : Colors.black,
                          fontWeight: tab == 'Build'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      body: Padding(
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
            return BuildCard(title: builds[index]['title']!);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to build creation page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BuildPageScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BuildCard extends StatelessWidget {
  final String title;

  const BuildCard({required this.title});

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
              TextButton(onPressed: () {}, child: const Text("Delete")),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BuildPageScreen()),
                  );
                },
                child: const Text("Check"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
