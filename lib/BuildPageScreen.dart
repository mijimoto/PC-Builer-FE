import 'package:flutter/material.dart';
import 'DetailScreen.dart';

class BuildPageScreen extends StatefulWidget {
  @override
  _BuildPageScreenState createState() => _BuildPageScreenState();
}

class _BuildPageScreenState extends State<BuildPageScreen> {
  List<Map<String, dynamic>> allItems = [
    {"item": "Operating System", "name": "os", "added": false, "partname": "", "price": 0.0},
    {"item": "Wireless Network Card", "name": "wirelessnetworkcard", "added": false, "partname": "", "price": 0.0},
    {"item": "Wired Network Card", "name": "wirednetworkcard", "added": false, "partname": "", "price": 0.0},
    {"item": "Webcam", "name": "webcam", "added": false, "partname": "", "price": 0.0},
    {"item": "Video Card", "name": "videocard", "added": false, "partname": "", "price": 0.0},
    {"item": "UPS", "name": "ups", "added": false, "partname": "", "price": 0.0},
    {"item": "Thermalpaste", "name": "thermalpaste", "added": false, "partname": "", "price": 0.0},
    {"item": "Speakers", "name": "speakers", "added": false, "partname": "", "price": 0.0},
    {"item": "Soundcard", "name": "soundcard", "added": false, "partname": "", "price": 0.0},
    {"item": "Power Supply", "name": "powersupply", "added": false, "partname": "", "price": 0.0},
    {"item": "Optical Drive", "name": "opticaldrive", "added": false, "partname": "", "price": 0.0},
    {"item": "Mouse", "name": "mouse", "added": false, "partname": "", "price": 0.0},
    {"item": "Motherboard", "name": "motherboard", "added": false, "partname": "", "price": 0.0},
    {"item": "Monitor", "name": "monitor", "added": false, "partname": "", "price": 0.0},
    {"item": "Memory", "name": "memory", "added": false, "partname": "", "price": 0.0},
    {"item": "Keyboard", "name": "keyboard", "added": false, "partname": "", "price": 0.0},
    {"item": "Internal Hard Drive", "name": "internalharddrive", "added": false, "partname": "", "price": 0.0},
    {"item": "Headphones", "name": "headphones", "added": false, "partname": "", "price": 0.0},
    {"item": "Fan Controller", "name": "fancontroller", "added": false, "partname": "", "price": 0.0},
    {"item": "External Hard Drive", "name": "externalharddrive", "added": false, "partname": "", "price": 0.0},
    {"item": "Cpu Cooler", "name": "cpucooler", "added": false, "partname": "", "price": 0.0},
    {"item": "Cpu", "name": "cpu", "added": false, "partname": "", "price": 0.0},
    {"item": "Cases", "name": "cases", "added": false, "partname": "", "price": 0.0},
    {"item": "Case Fan", "name": "casefan", "added": false, "partname": "", "price": 0.0},
    {"item": "Case Accessory", "name": "caseaccessory", "added": false, "partname": "", "price": 0.0},

  ];

  void removeItem(int index) {
    setState(() {
      allItems[index]["added"] = false;
      allItems[index]["partname"] = "";
      allItems[index]["price"] = 0.0;
    });
  }

  Future<void> openDetailPage(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          itemName: allItems[index]["name"],
          itemIndex: index,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        int idx = result['index'];
        allItems[idx]['partname'] = result['name'];
        allItems[idx]['price'] = result['price'];
        allItems[idx]['added'] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PC Build Parts")),
      body: ListView.builder(
        itemCount: allItems.length,
        itemBuilder: (context, index) {
          final item = allItems[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(item["item"]),
              subtitle: item["added"]
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: ${item["partname"]}"),
                  Text("Price: \$${item["price"].toStringAsFixed(2)}"),
                ],
              )
                  : Text("Add a ${item["item"]}"),
              leading: Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: Icon(Icons.memory),
              ),
              trailing: item["added"]
                  ? ElevatedButton(
                onPressed: () => removeItem(index),
                child: Text("Remove"),
              )
                  : ElevatedButton(
                onPressed: () => openDetailPage(index),
                child: Text("Add"),
              ),
            ),
          );
        },
      ),
    );
  }
}

