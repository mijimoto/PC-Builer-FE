<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'home_page.dart';


class BuildPageScreen extends StatelessWidget {
  final List<String> items = [
    'Choose Item 2',
    'Choose Item 3',
    'Choose Item 4',
    'Choose Item 5',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ItemCard1(),
                SizedBox(height: 16),
                for (int i = 2; i <= 5; i++) ItemDropdown(index: i),
                SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePageScreen()),
                );
              },
              child: Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemCard1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: Icon(Icons.image, size: 40, color: Colors.grey),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name of item",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text("Price: 111\$"),
                  Row(
                    children: [
                      ElevatedButton(onPressed: () {}, child: Text("Buy")),
                      SizedBox(width: 8),
                      OutlinedButton(onPressed: () {}, child: Text("Remove")),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemDropdown extends StatelessWidget {
  final int index;

  ItemDropdown({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Item $index:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: null,
              hint: Text("Choose Item $index"),
              onChanged: (value) {},
              items: ['Option A', 'Option B', 'Option C']
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
=======
import 'package:flutter/material.dart';
import 'home_page.dart';


class BuildPageScreen extends StatelessWidget {
  final List<String> items = [
    'Choose Item 2',
    'Choose Item 3',
    'Choose Item 4',
    'Choose Item 5',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ItemCard1(),
                SizedBox(height: 16),
                for (int i = 2; i <= 5; i++) ItemDropdown(index: i),
                SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePageScreen()),
                );
              },
              child: Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemCard1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: Icon(Icons.image, size: 40, color: Colors.grey),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name of item",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text("Price: 111\$"),
                  Row(
                    children: [
                      ElevatedButton(onPressed: () {}, child: Text("Buy")),
                      SizedBox(width: 8),
                      OutlinedButton(onPressed: () {}, child: Text("Remove")),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemDropdown extends StatelessWidget {
  final int index;

  ItemDropdown({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Item $index:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: null,
              hint: Text("Choose Item $index"),
              onChanged: (value) {},
              items: ['Option A', 'Option B', 'Option C']
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> ae98357c01f35fba6cabc63a75af9dab7b85aedb
