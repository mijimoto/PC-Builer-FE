import 'package:flutter/material.dart';
import '../AddItemPage.dart';
import '../home_page.dart';
import '../user_page.dart';
import '../log_in_page.dart';
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
    final accountId = await _getAccountId();
    if (token == null || accountId == null) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Please login first';
          _isLoading = false;
        });
      }
      print('BuildPageScreen: _fetchBuilds aborted: No token or accountId, mounted: $mounted');
      return;
    }

    try {
      print('BuildPageScreen: Sending GET to http://10.0.2.2:8080/api/v1/pcs');
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/v1/pcs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('BuildPageScreen: _fetchBuilds response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            builds = data
                .where((pc) => pc['accountid'].toString() == accountId)
                .map((pc) => {
                      'pcid': pc['pcid'].toString(),
                      'title': pc['pcname'] ?? 'Build ${pc['pcid']}',
                      'accountid': pc['accountid'],
                    })
                .toList();
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

  Future<void> _createNewPC() async {
    print('BuildPageScreen: _createNewPC started');
    final token = await _getToken();
    final accountId = await _getAccountId();
    if (token == null || accountId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
      }
      print('BuildPageScreen: _createNewPC aborted: token: ${token != null}, accountId: ${accountId != null}');
      return;
    }

    // Ask user for PC name
    final nameController = TextEditingController();
    final enteredName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Build Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Build name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (enteredName == null || enteredName.isEmpty) {
      print('BuildPageScreen: _createNewPC cancelled by user');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final payload = {
        'pcname': enteredName,
        'accountid': int.parse(accountId),
      };

      print('BuildPageScreen: _createNewPC sending payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/v1/pcs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));

      print('BuildPageScreen: _createNewPC response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        String? newPcId;
        if (response.body.isNotEmpty) {
          final responseData = jsonDecode(response.body);
          newPcId = responseData['pcid']?.toString() ?? responseData['id']?.toString();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New PC created successfully')),
          );

          if (newPcId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddItemScreen(
                  buildId: newPcId,
                  initialComponents: null,
                ),
              ),
            ).then((_) => _fetchBuilds());
          } else {
            _fetchBuilds(); // Refresh list if no ID returned
          }
        }
        print('BuildPageScreen: _createNewPC succeeded, pcid: $newPcId, mounted: $mounted');
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to create PC: ${response.statusCode} - ${response.body}';
            _isLoading = false;
          });
        }
        print('BuildPageScreen: _createNewPC failed: ${response.statusCode} - ${response.body}, mounted: $mounted');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection Error: ${e.toString()}';
          _isLoading = false;
        });
      }
      print('BuildPageScreen: _createNewPC error: ${e.toString()}, mounted: $mounted');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('BuildPageScreen: _createNewPC completed, mounted: $mounted');
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
      print('BuildPageScreen: Sending DELETE to http://10.0.2.2:8080/api/v1/pcs/${builds[index]['pcid']}');
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8080/api/v1/pcs/${builds[index]['pcid']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('BuildPageScreen: _deleteBuild response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
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
              child: const Text('Home', style: TextStyle(color: Colors.black)),
            ),
            const Text('Build', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () async {
                final accountId = await _getAccountId();
                print('BuildPageScreen: Account button pressed, accountId: ${accountId ?? "null"}');
                if (accountId != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(accountid: accountId),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LogInScreen()),
                  );
                }
              },
              child: const Text('Account', style: TextStyle(color: Colors.black)),
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
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchBuilds,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
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
                                  initialComponents: null,
                                ),
                              ),
                            ).then((_) => _fetchBuilds());
                          },
                          onDeletePressed: () => _handleDelete(index),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _createNewPC,
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
                child: Icon(Icons.computer, size: 50, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: onDeletePressed, child: const Text("Delete")),
              TextButton(onPressed: onCheckPressed, child: const Text("Check")),
            ],
          ),
        ],
      ),
    );
  }
}
