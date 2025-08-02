import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InfoPartScreen extends StatefulWidget {
  final String partName;

  const InfoPartScreen({Key? key, required this.partName}) : super(key: key);

  @override
  _InfoPartScreenState createState() => _InfoPartScreenState();
}

class _InfoPartScreenState extends State<InfoPartScreen> {
  Map<String, dynamic>? partInfo;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchPartInfo();
  }

  Future<void> fetchPartInfo() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8080/api/v1/${widget.partName}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          partInfo = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.partName.toUpperCase()} Info")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
          ? Center(child: Text("Failed to load part info."))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: partInfo!.entries.map((entry) {
            return ListTile(
              title: Text(entry.key),
              subtitle: Text(entry.value.toString()),
            );
          }).toList(),
        ),
      ),
    );
  }
}