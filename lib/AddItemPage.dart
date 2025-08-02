import 'package:flutter/material.dart';
import 'DetailScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddItemScreen extends StatefulWidget {
  final String? buildId;
  final Map<String, dynamic>? initialComponents;

  const AddItemScreen({Key? key, this.buildId, this.initialComponents}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
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

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('AddItemScreen: initState called, buildId: ${widget.buildId}');
    if (widget.initialComponents != null) {
      if (mounted) {
        setState(() {
          for (var item in allItems) {
            if (widget.initialComponents!.containsKey(item['name'])) {
              item['added'] = true;
              item['partname'] = widget.initialComponents![item['name']]['componentname'];
              item['price'] = widget.initialComponents![item['name']]['price']?.toDouble() ?? 0.0;
            }
          }
        });
      }
      print('AddItemScreen: Initialized with components: ${widget.initialComponents}');
    }
  }

  @override
  void dispose() {
    print('AddItemScreen: dispose called');
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    print('AddItemScreen: _getToken returned: ${token != null ? "Token found" : "No token"}');
    return token;
  }

  Future<String?> _getAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getString('accountId');
    print('AddItemScreen: _getAccountId returned: ${accountId != null ? accountId : "No accountId"}');
    return accountId;
  }

  void removeItem(int index) {
    if (mounted) {
      setState(() {
        allItems[index]["added"] = false;
        allItems[index]["partname"] = "";
        allItems[index]["price"] = 0.0;
      });
    }
    print('AddItemScreen: Removed item at index: $index, item: ${allItems[index]["item"]}');
  }

  Future<void> openDetailPage(int index) async {
    print('AddItemScreen: openDetailPage called for index: $index, item: ${allItems[index]["item"]}');
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
      if (mounted) {
        setState(() {
          int idx = result['index'];
          allItems[idx]['partname'] = result['name'];
          allItems[idx]['price'] = result['price'];
          allItems[idx]['added'] = true;
        });
      }
      print('AddItemScreen: Updated item at index: $index, result: $result');
    } else {
      print('AddItemScreen: No result from DetailScreen for index: $index');
    }
  }

  Future<void> saveBuild() async {
    print('AddItemScreen: saveBuild started, buildId: ${widget.buildId}');
    // Check for missing components
    final missingComponents = allItems.where((item) => !item['added']).toList();
    if (missingComponents.isNotEmpty) {
      final missingNames = missingComponents.map((item) => item['item']).join(', ');
      print('AddItemScreen: Missing components: $missingNames');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Missing Components'),
          content: Text('You haven\'t chosen items for: $missingNames'),
          actions: [
            TextButton(
              onPressed: () {
                print('AddItemScreen: Missing components dialog closed');
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final token = await _getToken();
    final accountId = await _getAccountId();
    if (token == null || accountId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
      }
      print('AddItemScreen: saveBuild aborted: token: ${token != null}, accountId: ${accountId != null}');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Placeholder component ID mapping (replace with actual numeric IDs)
      final componentIdMap = {
        'os': 1,
        'wirelessnetworkcard': 2,
        'wirednetworkcard': 3,
        'webcam': 4,
        'videocard': 5,
        'ups': 6,
        'thermalpaste': 7,
        'speakers': 8,
        'soundcard': 9,
        'powersupply': 10,
        'opticaldrive': 11,
        'mouse': 12,
        'motherboard': 13,
        'monitor': 14,
        'memory': 15,
        'keyboard': 16,
        'internalharddrive': 17,
        'headphones': 18,
        'fancontroller': 19,
        'externalharddrive': 20,
        'cpucooler': 21,
        'cpu': 22,
        'cases': 23,
        'casefan': 24,
        'caseaccessory': 25,
      };

      final payload = {
        'pcname': 'Build ${DateTime.now().millisecondsSinceEpoch}',
        'accountid': int.parse(accountId),
        'components': allItems.where((item) => item['added']).map((item) => {
          'componentid': componentIdMap[item['name']] ?? item['name'],
          'componentname': item['partname'],
        }).toList(),
      };

      print('AddItemScreen: saveBuild sending payload: ${jsonEncode(payload)}');

      final uri = widget.buildId == null
          ? Uri.parse('http://localhost:8080/api/v1/pcbuild')
          : Uri.parse('http://localhost:8080/api/v1/pcbuild/${widget.buildId}');
      final method = widget.buildId == null ? http.post : http.put;

      print('AddItemScreen: Sending ${widget.buildId == null ? "POST" : "PUT"} to $uri');

      final response = await method(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(Duration(seconds: 10));

      print('AddItemScreen: saveBuild response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.buildId == null ? 'Build saved successfully' : 'Build updated successfully')),
          );
        }
        print('AddItemScreen: saveBuild succeeded, navigating back');
        Navigator.pop(context); // Return to BuildPageScreen
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to save build: ${response.statusCode} - ${response.body}';
            _isLoading = false;
          });
        }
        print('AddItemScreen: saveBuild failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection Error: ${e.toString()}';
          _isLoading = false;
        });
      }
      print('AddItemScreen: saveBuild error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('AddItemScreen: saveBuild completed, mounted: $mounted');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('AddItemScreen: build called, isLoading: $_isLoading, errorMessage: $_errorMessage');
    return Scaffold(
      appBar: AppBar(
        title: Text("PC Build Parts"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : saveBuild,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF800080),
              ),
              child: Text(
                widget.buildId == null ? 'Save Build' : 'Update Build',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
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
                ),
              ],
            ),
    );
  }
}