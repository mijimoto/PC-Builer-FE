import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<void> fetchPartInfo() async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse(
          "https://pcbuilder-546878159726.asia-east1.run.app/api/v1/${widget.partName}",
        ),
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
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Failed to load part info."))
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
