import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class PasteQrCode extends StatefulWidget {
  const PasteQrCode({super.key});

  @override
  State<PasteQrCode> createState() => _PasteQrCodeState();
}

class _PasteQrCodeState extends State<PasteQrCode> {
  final TextEditingController _controller = TextEditingController();
  String? userID = "None";
  void _postTextToBackend() async {
    String text = _controller.text;
    // Here you would add your logic to post the text to the backend.
    // For example, using http.post to send data to your API.
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the loading screen
      builder: (_) => Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      final Uri fetchUri = Uri.parse(
        'http://192.168.0.112:4001/api/v1/teacher/course/attendance/qr',
      );
      print(userID);
      final http.Response response = await http.post(fetchUri, body: {
        'studentId': userID,
        'token': text,
      });
      // final Map<String, dynamic> data = jsonDecode(response.body);
      // final List<dynamic> res = data['message'];
      // print(res);
      print(response.statusCode);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Row(
              children: const [
                Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 5,
                ),
                Text('Attendance Recorded'),
              ],
            ),
          ),
        );
        //  print(attendance[0]._id);
      } else {
        throw Exception("Invalid Server Response");
      }
    } catch (error) {
      print(error);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Row(
            children: const [
              Icon(
                Icons.check,
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Text('Invalid Server Response'),
            ],
          ),
        ),
      );
      //throw Exception("Failed to Load Data");
    }
  }

  Future<void> extractData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userID');
    });
  }

  @override
  void initState() {
    super.initState();
    extractData();
    // Initialize the selected date to the current date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Paste Qr Code '),
            SizedBox(width: 8),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * .8,
              // Specify the width here
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Enter Text',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _postTextToBackend,
              child: const Text('Submit Qr Code'),
            ),
          ],
        ),
      ),
    );
  }
}
