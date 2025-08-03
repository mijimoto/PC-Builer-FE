import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  final String itemName;
  final int itemIndex;

  const DetailScreen({required this.itemName, required this.itemIndex});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<dynamic> apiList = [];
  List<dynamic> filteredList = [];
  TextEditingController searchController = TextEditingController();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<void> fetchApi() async {
    try {
      final token = await _getToken();
      final url = Uri.parse(
          'https://pcbuilder-546878159726.asia-east1.run.app/api/v1/${widget.itemName}');

      final response = await http.get(
        url,
        headers: token != null
            ? {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              }
            : {
                'Content-Type': 'application/json',
              },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          apiList = data;
          filteredList = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch API: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchApi();
  }

  void filterSearch(String query) {
    setState(() {
      filteredList = apiList
          .where(
            (item) => item['parts']['partname']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void selectPart(dynamic part) {
    final name = part['parts']['partname'];
    final price = part['parts']['partprice']?.toDouble() ?? 0.0;

    Navigator.pop(context, {
      'index': widget.itemIndex,
      'name': name,
      'price': price,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose ${widget.itemName}")),
      body: apiList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search part name...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: filterSearch,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final part = filteredList[index]['parts'];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(part['partname']),
                          subtitle: Text('Price: \$${part['partprice']}'),
                          trailing: ElevatedButton(
                            onPressed: () => selectPart(filteredList[index]),
                            child: const Text("Add"),
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
