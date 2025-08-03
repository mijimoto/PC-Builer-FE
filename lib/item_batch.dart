import 'package:flutter/material.dart';

class ItemListPage extends StatefulWidget {
  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  List<String> items = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      items = ['Item 1', 'Item 2', 'Item 3'];
    });
  }

  void addNewItem() {
    setState(() {
      items.add('Item ${items.length + 1}');
    });
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        toolbarHeight: 50,
        title: Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            spacing: 10,
            children: [
              TextButton(onPressed: () {}, child: Text('Home')),
              TextButton(onPressed: () {}, child: Text('Build')),
              TextButton(onPressed: () {}, child: Text('Account')),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {},
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Item List
          Expanded(
            child: items.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: Icon(Icons.image),
                              ),
                              SizedBox(width: 10),
                              Expanded(child: Text(items[index])),
                              ElevatedButton(
                                onPressed: () {
                                  // Add your add item logic here
                                },
                                child: Text('Add'),
                              ),
                              SizedBox(width: 6),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Add New Item Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ElevatedButton.icon(
              onPressed: addNewItem,
              icon: Icon(Icons.add),
              label: Text("Add New Item"),
            ),
          ),
        ],
      ),

      // Floating Menu Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.menu),
      ),
    );
  }
}