import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'DetailScreen.dart';

class AddItemScreen extends StatefulWidget {
  final String? buildId;
  final Map<String, dynamic>? initialComponents;

  const AddItemScreen({Key? key, this.buildId, this.initialComponents}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  List<Map<String, dynamic>> allItems = [
    {"item": "Operating System", "name": "os", "added": false, "partname": "", "price": null, "componentId": 10},
    {"item": "Wireless Network Card", "name": "wirelessnetworkcard", "added": false, "partname": "", "price": 0.0, "componentId": 1},
    {"item": "Wired Network Card", "name": "wirednetworkcard", "added": false, "partname": "", "price": null, "componentId": 2},
    {"item": "Webcam", "name": "webcam", "added": false, "partname": "", "price": 0.0, "componentId": 3},
    {"item": "Video Card", "name": "videocard", "added": false, "partname": "", "price": 0.0, "componentId": 4},
    {"item": "UPS", "name": "ups", "added": false, "partname": "", "price": 0.0, "componentId": 5},
    {"item": "Thermalpaste", "name": "thermalpaste", "added": false, "partname": "", "price": null, "componentId": 6},
    {"item": "Speakers", "name": "speakers", "added": false, "partname": "", "price": 0.0, "componentId": 7},
    {"item": "Soundcard", "name": "soundcard", "added": false, "partname": "", "price": 0.0, "componentId": 8},
    {"item": "Power Supply", "name": "powersupply", "added": false, "partname": "", "price": 0.0, "componentId": 9},
    {"item": "Optical Drive", "name": "opticaldrive", "added": false, "partname": "", "price": 0.0, "componentId": 11},
    {"item": "Mouse", "name": "mouse", "added": false, "partname": "", "price": 0.0, "componentId": 12},
    {"item": "Motherboard", "name": "motherboard", "added": false, "partname": "", "price": 0.0, "componentId": 13},
    {"item": "Monitor", "name": "monitor", "added": false, "partname": "", "price": 0.0, "componentId": 14},
    {"item": "Memory", "name": "memory", "added": false, "partname": "", "price": 0.0, "componentId": 15},
    {"item": "Keyboard", "name": "keyboard", "added": false, "partname": "", "price": 0.0, "componentId": 16},
    {"item": "Internal Hard Drive", "name": "internalharddrive", "added": false, "partname": "", "price": 0.0, "componentId": 17},
    {"item": "Headphones", "name": "headphones", "added": false, "partname": "", "price": 0.0, "componentId": 18},
    {"item": "Fan Controller", "name": "fancontroller", "added": false, "partname": "", "price": 0.0, "componentId": 19},
    {"item": "External Hard Drive", "name": "externalharddrive", "added": false, "partname": "", "price": 0.0, "componentId": 20},
    {"item": "Cpu Cooler", "name": "cpucooler", "added": false, "partname": "", "price": 0.0, "componentId": 21},
    {"item": "Cpu", "name": "cpu", "added": false, "partname": "", "price": 0.0, "componentId": 22},
    {"item": "Cases", "name": "cases", "added": false, "partname": "", "price": 0.0, "componentId": 25},
    {"item": "Case Fan", "name": "casefan", "added": false, "partname": "", "price": 0.0, "componentId": 23},
    {"item": "Case Accessory", "name": "caseaccessory", "added": false, "partname": "", "price": 0.0, "componentId": 24},
  ];

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _savedBuilds = [];

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
    if (widget.buildId != null) {
      _fetchExistingComponents();
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

Future<void> _fetchExistingComponents() async {
  if (widget.buildId == null) return;

  setState(() => _isLoading = true);

  final token = await _getToken();
  if (token == null) return;

  try {
    final response = await http
        .get(
          Uri.parse('http://10.0.2.2:8080/api/v1/pcbuild/pc/${widget.buildId}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          // Store for deletion later
          _savedBuilds = List<Map<String, dynamic>>.from(
            data.map((build) => {
              'pcid': build['pcid'],
              'partid': build['partid'],
            }),
          );

          // Reset all items
          for (var i in allItems) {
            i['added'] = false;
            i['partname'] = '';
            i['price'] = 0.0;
          }

          // Fill with fetched data
          for (var build in data) {
            final partId = build['partid'];
            final partsMap = build['parts'] as Map<String, dynamic>?;

            final componentName = partsMap?['partname'] ?? '';
            final componentPrice =
                (partsMap?['partprice'] as num?)?.toDouble() ?? 0.0;

            final index = allItems.indexWhere(
              (i) => i['componentId'] == partId,
            );

            if (index != -1) {
              allItems[index]['added'] = true;
              allItems[index]['partname'] = componentName;
              allItems[index]['price'] = componentPrice;
            }
          }

          _isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to load components');
    }
  } catch (e) {
    if (mounted) setState(() => _isLoading = false);
    print('Fetch error: $e');
  }
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

  Future<void> _savePCBuild() async {
    if (widget.buildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No PC selected. Please create a PC first.')),
      );
      return;
    }

    print('AddItemScreen: _savePCBuild started, buildId: ${widget.buildId}');
    
    final addedComponents = allItems.where((item) => item['added']).toList();
    if (addedComponents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one component before saving.')),
      );
      return;
    }

    final token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
      }
      print('AddItemScreen: _savePCBuild aborted: no token');
      return;
    }

    if (mounted) {
      setState(() {
        _isSaving = true;
        _errorMessage = null;
      });
    }

    try {
      // First, delete existing components for this PC
      await _deleteExistingComponents();

      // Then, save new components
      for (var item in addedComponents) {
        final payload = {
          'pcid': int.parse(widget.buildId!),
          'partid': item['componentId'],
          'createdat': DateTime.now().toIso8601String(),
        };

        print('AddItemScreen: Saving component: ${jsonEncode(payload)}');

        final response = await http.post(
          Uri.parse('http://10.0.2.2:8080/api/v1/pcbuild'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        ).timeout(Duration(seconds: 10));

        print('AddItemScreen: Component save response: ${response.statusCode} - ${response.body}');

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Failed to save component: ${item['item']}');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PC Build saved successfully!')),
        );
        Navigator.pop(context);
      }
      print('AddItemScreen: _savePCBuild succeeded');

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save PC Build: ${e.toString()}';
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      print('AddItemScreen: _savePCBuild error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
      print('AddItemScreen: _savePCBuild completed, mounted: $mounted');
    }
  }

  Future<void> _deleteExistingComponents() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      for (var build in _savedBuilds) {
        final response = await http.delete(
          Uri.parse('http://10.0.2.2:8080/api/v1/pcbuild/${build['pcid']}/${build['partid']}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(Duration(seconds: 10));

        print('AddItemScreen: Delete existing component response: ${response.statusCode}');
      }
    } catch (e) {
      print('AddItemScreen: Error deleting existing components: ${e.toString()}');
    }
  }

  double calculateTotalPrice() {
    double total = 0.0;
    for (var item in allItems) {
      if (item['added'] && item['price'] != null) {
        total += item['price'];
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    print('AddItemScreen: build called, isLoading: $_isLoading, isSaving: $_isSaving, errorMessage: $_errorMessage');
    return Scaffold(
      appBar: AppBar(
        title: Text("PC Build Parts"),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Build Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PC ID: ${widget.buildId ?? "New PC"}'),
                      SizedBox(height: 8),
                      Text('Components Added: ${allItems.where((item) => item['added']).length}'),
                      SizedBox(height: 8),
                      Text('Total Price: ${calculateTotalPrice().toStringAsFixed(2)}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.red[100],
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[800], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 80), // Add padding for floating button
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
                                    item["price"] != null
                                        ? Text("Price: ${item["price"].toStringAsFixed(2)}")
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Price: Unknown"),
                                              Text(
                                                "Price ignored (null)",
                                                style: TextStyle(color: Colors.red, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                  ],
                                )
                              : Text("Add a ${item["item"]}"),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getIconForComponent(item["name"]),
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: item["added"]
                              ? ElevatedButton(
                                  onPressed: () => removeItem(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text("Remove"),
                                )
                              : ElevatedButton(
                                  onPressed: () => openDetailPage(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text("Add"),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _isSaving ? null : _savePCBuild,
              backgroundColor: Colors.green,
              child: _isSaving
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.check, color: Colors.white),
              tooltip: 'Save PC Build',
            ),
          ),
          if (allItems.where((item) => item['added']).isNotEmpty)
            Positioned(
              bottom: 80,
              right: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total: ${calculateTotalPrice().toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForComponent(String componentName) {
    switch (componentName.toLowerCase()) {
      case 'cpu':
        return Icons.memory;
      case 'motherboard':
        return Icons.developer_board;
      case 'memory':
        return Icons.storage;
      case 'videocard':
        return Icons.videogame_asset;
      case 'powersupply':
        return Icons.power;
      case 'cases':
        return Icons.computer;
      case 'monitor':
        return Icons.monitor;
      case 'keyboard':
        return Icons.keyboard;
      case 'mouse':
        return Icons.mouse;
      case 'speakers':
        return Icons.speaker;
      case 'headphones':
        return Icons.headphones;
      case 'webcam':
        return Icons.videocam;
      case 'internalharddrive':
      case 'externalharddrive':
        return Icons.storage;
      case 'opticaldrive':
        return Icons.album;
      case 'wirelessnetworkcard':
      case 'wirednetworkcard':
        return Icons.wifi;
      case 'soundcard':
        return Icons.audiotrack;
      case 'cpucooler':
      case 'casefan':
      case 'fancontroller':
        return Icons.ac_unit;
      case 'ups':
        return Icons.battery_full;
      case 'thermalpaste':
        return Icons.opacity;
      case 'caseaccessory':
        return Icons.build;
      case 'os':
        return Icons.settings;
      default:
        return Icons.memory;
    }
  }
}