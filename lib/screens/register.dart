import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String selectedRole = "teacher";
  final TextEditingController userIDController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final String userID = userIDController.text;
    final String password = passwordController.text;
    final String email = emailController.text;
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the loading screen
      builder: (_) => Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      final Uri loginUri =
          Uri.parse('http://192.168.0.113:4001/api/v1/auth/register');
      final http.Response response = await http.post(loginUri, body: {
        'userId': userID,
        'password': password,
        'email': email,
        'role': selectedRole
      });

      Navigator.pop(context);
      if (response.statusCode == 200) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Registration Successful'),
            content: const Text('Thanks for registering'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
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
            title: const Text('Registration Failed'),
            content: const Text('Invalid userID or password'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Try Again'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Registration Failed'),
          content: const Text("Duplicate Email or UserId"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    // Make an HTTP request to your server's login endpoint
  }

  var items = ['teacher', 'student'];
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
                  "SIGN UP",
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
                controller: emailController,
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
                    labelText: 'Email'),
              ),
              const SizedBox(
                height: 20,
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
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Select your role")),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 0, color: Color(0xFFF1F3F5)),
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 0, color: Color(0xFFF1F3F5)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true, //<-- SEE HERE
                    fillColor: const Color(0xFFF1F3F5),
                  ),
                  value: selectedRole,
                  items: [
                    //add items in the dropdown
                    DropdownMenuItem(
                      child: Row(
                        children: [
                          Text("teacher"),
                        ],
                      ),
                      value: "teacher",
                    ),
                    DropdownMenuItem(
                        child: Row(
                          children: [
                            Text("student"),
                          ],
                        ),
                        value: "student"),
                  ],
                  onSaved: (value) {
                    //get value when changed
                    // print("You have selected $value");
                    setState(() {
                      selectedRole = value.toString();
                    });
                    // print(selectedRole);
                  },
                  onChanged: (value) {
                    //get value when changed
                    // print("You have selected $value");
                    setState(() {
                      selectedRole = value.toString();
                    });
                    //print(selectval);
                  },
                  //dropdown background color
                  // underline: Container(), //remove underline
                  isExpanded: true, //make
                ),
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
                      'Sign Up',
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
                      "Already Have an Account ?",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/login");
                      },
                      child: Text(
                        "Sign In",
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
