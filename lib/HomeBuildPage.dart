import 'package:flutter/material.dart';
import 'AddItemPage.dart';
import 'home_page.dart';
import 'user_page.dart';
import 'log_in_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BuildPageScreen extends StatefulWidget {
  const BuildPageScreen({Key? key}) : super(key: key);

  @override
  State<BuildPageScreen> createState() => _BuildPageScreenState();
}

class _BuildPageScreenState extends State<BuildPageScreen> {
  List<Map<String, dynamic>> builds = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('BuildPageScreen: initState called');
    _fetchBuilds();
  }

  @override
  void dispose() {
    print('BuildPageScreen: dispose called');
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    print('BuildPageScreen: _getToken returned: ${token != null ? "Token found" : "No token"}');
    return token;
  }

  Future<String?> _getAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getString('accountId');
    print('BuildPageScreen: _getAccountId returned: ${accountId != null ? accountId : "No accountId"}');
    return accountId;
  }

  Future<void> _fetchBuilds() async {
    print('BuildPageScreen: _fetchBuilds started, mounted: $mounted');
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = await _getToken();
    if (token == null) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Please login first';
          _isLoading = false;
        });
      }
      print('BuildPageScreen: _fetchBuilds aborted: No token, mounted: $mounted');
      return;
    }

    try {
      print('BuildPageScreen: Sending GET to http://localhost:8080/api/v1/pcbuild');
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/pcbuild'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      print('BuildPageScreen: _fetchBuilds response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            builds = data.map((build) => {
              'pcid': build['pcid'].toString(),
              'title': build['pcs']['pcname'] ?? 'Build ${build['pcid']}',
              'components': {
                build['components']['componentid'].toString(): {
                  'componentname': build['components']['componentname'],
                  'componentid': build['components']['componentid'],
                }
              },
              'createdat': build['createdat'],
            }).toList();
            _isLoading = false;
          });
          print('BuildPageScreen: _fetchBuilds succeeded, builds count: ${builds.length}, mounted: $mounted');
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to fetch builds: ${response.statusCode} - ${response.body}';
            _isLoading = false;
          });
        }
        print('BuildPageScreen: _fetchBuilds failed: ${response.statusCode} - ${response.body}, mounted: $mounted');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection Error: ${e.toString()}';
          _isLoading = false;
        });
      }
      print('BuildPageScreen: _fetchBuilds error: ${e.toString()}, mounted: $mounted');
    }
  }

  Future<void> _addNewBuild() async {
    print('BuildPageScreen: _addNewBuild started, navigating to AddItemScreen');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddItemScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      print('BuildPageScreen: _addNewBuild received result, calling _saveBuild');
      await _saveBuild(result);
    } else {
      print('BuildPageScreen: _addNewBuild no result or invalid result, mounted: $mounted');
    }
  }

  Future<void> _saveBuild(Map<String, dynamic> buildData) async {
    print('BuildPageScreen: _saveBuild started, mounted: $mounted');
    final token = await _getToken();
    final accountId = await _getAccountId();
    if (token == null || accountId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
      }
      print('BuildPageScreen: _saveBuild aborted: token: ${token != null}, accountId: ${accountId != null}, mounted: $mounted');
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
        'pcname': 'Build ${builds.length + 1}',
        'accountid': int.parse(accountId),
        'components': buildData['items'].where((item) => item['added']).map((item) => {
          'componentid': componentIdMap[item['name']] ?? item['name'],
          'componentname': item['partname'],
        }).toList(),
      };

      print('BuildPageScreen: _saveBuild sending payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/pcbuild'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(Duration(seconds: 10));

      print('BuildPageScreen: _saveBuild response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchBuilds();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Build saved successfully')),
          );
        }
        print('BuildPageScreen: _saveBuild succeeded, mounted: $mounted');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save build: ${response.statusCode} - ${response.body}')),
          );
        }
        print('BuildPageScreen: _saveBuild failed: ${response.statusCode} - ${response.body}, mounted: $mounted');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection Error: ${e.toString()}')),
        );
      }
      print('BuildPageScreen: _saveBuild error: ${e.toString()}, mounted: $mounted');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('BuildPageScreen: _saveBuild completed, mounted: $mounted');
    }
  }

  Future<void> _deleteBuild(int index) async {
    print('BuildPageScreen: _deleteBuild started for index: $index, mounted: $mounted');
    final token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
      }
      print('BuildPageScreen: _deleteBuild aborted: No token, mounted: $mounted');
      return;
    }

    try {
      print('BuildPageScreen: Sending DELETE to http://localhost:8080/api/v1/pcbuild/${builds[index]['pcid']}');
      final response = await http.delete(
        Uri.parse('http://localhost:8080/api/v1/pcbuild/${builds[index]['pcid']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      print('BuildPageScreen: _deleteBuild response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            builds.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Build deleted successfully')),
          );
        }
        print('BuildPageScreen: _deleteBuild succeeded, mounted: $mounted');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete build: ${response.statusCode} - ${response.body}')),
          );
        }
        print('BuildPageScreen: _deleteBuild failed: ${response.statusCode} - ${response.body}, mounted: $mounted');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection Error: ${e.toString()}')),
        );
      }
      print('BuildPageScreen: _deleteBuild error: ${e.toString()}, mounted: $mounted');
    }
  }

  void _handleDelete(int index) async {
    print('BuildPageScreen: _handleDelete called for index: $index');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Do you really want to delete ${builds[index]['title']}?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('BuildPageScreen: _handleDelete cancelled for index: $index');
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              print('BuildPageScreen: _handleDelete confirmed for index: $index');
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _deleteBuild(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('BuildPageScreen: build called, mounted: $mounted, isLoading: $_isLoading, errorMessage: $_errorMessage, builds count: ${builds.length}');
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                print('BuildPageScreen: Navigating to HomePageScreen');
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
                print('BuildPageScreen: Build button pressed (no navigation)');
              },
              child: Text(
                'Build',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final accountId = await _getAccountId();
                print('BuildPageScreen: Account button pressed, accountId: ${accountId != null ? accountId : "null"}');
                if (accountId != null) {
                  print('BuildPageScreen: Navigating to UserProfile');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(accountid: accountId),
                    ),
                  );
                } else {
                  print('BuildPageScreen: Navigating to LogInScreen');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LogInScreen()),
                  );
                }
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
        backgroundColor: const Color(0xFFD1C4E9),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD1C4E9), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Padding(
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
                            print('BuildPageScreen: Check pressed for build index: $index');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddItemScreen(
                                  buildId: builds[index]['pcid'],
                                  initialComponents: builds[index]['components'],
                                ),
                              ),
                            );
                          },
                          onDeletePressed: () => _handleDelete(index),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBuild,
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