import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<void> fetchApi() async {
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/v1/${widget.itemName}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          apiList = data;
          filteredList = data;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to fetch API")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
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
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(part['partname']),
                          subtitle: Text('Price: \$${part['partprice']}'),
                          trailing: ElevatedButton(
                            onPressed: () => selectPart(filteredList[index]),
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
