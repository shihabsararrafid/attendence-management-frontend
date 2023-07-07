import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatelessWidget {
  final TextEditingController userIDController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final String userID = userIDController.text;
    final String password = passwordController.text;

    // Make an HTTP request to your server's login endpoint
    final Uri loginUri =
        Uri.parse('http://192.168.0.113:4001/api/v1/auth/login');
    final http.Response response = await http.post(loginUri, body: {
      'userId': userID,
      'password': password,
    });
    print(response);
    if (response.statusCode == 200) {
      print("success");
      // Login successful
      // Store the login information locally using shared_preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userID', userID);
      await prefs.setString('password', password);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Login Successful'),
          content: Text('Invalid userID or password'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      // Navigate to the home screen or the next screen
      //  Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Login failed
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Login Failed'),
          content: Text('Invalid userID or password'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: userIDController,
              decoration: InputDecoration(labelText: 'UserID'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () => login(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
