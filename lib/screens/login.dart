import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;
  final TextEditingController userIDController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    final String userID = userIDController.text;
    final String password = passwordController.text;
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the loading screen
      builder: (_) => Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      final Uri loginUri =
          Uri.parse('http://192.168.0.113:4001/api/v1/auth/login');
      final http.Response response = await http.post(loginUri, body: {
        'userId': userID,
        'password': password,
      });
      setState(() {
        isLoading = true;
      });
      Navigator.pop(context);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final String role = responseData['user']['role'];
        final String email = responseData['user']['email'];
        final String _id = responseData['user']['_id'];
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userID', userID);
        await prefs.setString('role', role);
        await prefs.setString('id', _id);
        await prefs.setString('email', email);
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Login Successful'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        if (role == "teacher") {
          Navigator.pushNamed(context, "/teacher");
        }
        // Navigate to the home screen or the next screen
        //  Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Login failed
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Invalid userID or password'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print(error);
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Server Error'),
          content: const Text('Server not responding'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    // Make an HTTP request to your server's login endpoint
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: DecoratedBox(
                        decoration:
                            const BoxDecoration(color: const Color(0xFFF1F3F5)),
                        child: Center(
                            child: GestureDetector(
                          onTap: () => {Navigator.pop(context)},
                          child: const Text(
                            "<",
                            style: TextStyle(color: Colors.blue, fontSize: 30),
                          ),
                        ))),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "SIGN IN",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                      color: Colors.blueGrey[400]),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: userIDController,
                decoration: InputDecoration(
                    filled: true, //<-- SEE HERE
                    fillColor: const Color(0xFFF1F3F5),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 0, color: Color(0xFFF1F3F5)),
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'UserId'),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                    filled: true, //<-- SEE HERE
                    fillColor: const Color(0xFFF1F3F5),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 0, color: Color(0xFFF1F3F5)),
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Password'),
              ),
              const SizedBox(
                height: 20,
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot Password ?",
                  style:
                      TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              GestureDetector(
                onTap: () {
                  login(context);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue, width: 2),
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Align(
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't Have an Account ?",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/register");
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
