import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddClass extends StatefulWidget {
  const AddClass({super.key});

  @override
  State<AddClass> createState() => _AddClassState();
}

class _AddClassState extends State<AddClass> {
  TextEditingController courseCodeController = TextEditingController();
  TextEditingController batchNameController = TextEditingController();
  TextEditingController startRollController = TextEditingController();
  TextEditingController totalStudentsController = TextEditingController();
  TextEditingController sectionController = TextEditingController();
  String? userID = "None";
  String? role = "none";
  String? email = "none";
  String? id = "none";
  Future<void> _createClass(BuildContext context) async {
    final String courseCode = courseCodeController.text;
    final String batchName = batchNameController.text;
    final String startRoll = startRollController.text;
    final String totalStudents = totalStudentsController.text;
    final String section = sectionController.text;
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the loading screen
      builder: (_) => Center(
        child: CircularProgressIndicator(),
      ),
    );
    // startRoll, numberOfStudents, code, batchName, teacher
    try {
      final Uri loginUri = Uri.parse(
          'https://attendence-backend-silk.vercel.app/api/v1/teacher/course');
      final http.Response response = await http.post(loginUri, body: {
        'startRoll': startRoll,
        'numberOfStudents': totalStudents,
        'code': courseCode,
        'batchName': batchName,
        'section': section,
        'teacher': id
      });

      Navigator.pop(context);
      if (response.statusCode == 200) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Successful'),
            content: const Text('Class Created Successfully'),
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
            title: Center(
                child: Text(
              'Error'.toUpperCase(),
              style: TextStyle(color: Colors.red, fontSize: 18),
            )),
            content: Text('$courseCode already created for the $batchName'),
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
  }

  int _currentIndex = 0;

  Future<void> extractData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userID');
      role = prefs.getString('role');
      email = prefs.getString('email');
      id = prefs.getString('id');
    });
    print(userID);
  }

  @override
  void initState() {
    super.initState();
    extractData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
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
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 200, 209, 230)),
                          child: Center(
                              child: GestureDetector(
                                  onTap: () => {
                                        Navigator.pushNamed(context, "/teacher")
                                      },
                                  child: Icon(Icons.arrow_back)))),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Text(
                    "Add New Class",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  )),
                ),
                SizedBox(
                  height: 60,
                ),
                TextField(
                  controller: courseCodeController,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.book_online_rounded),
                      filled: true, //<-- SEE HERE
                      fillColor: const Color(0xFFF1F3F5),
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              width: 0,
                              color: Color.fromARGB(255, 200, 209, 230)),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(width: 1, color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Course Code'),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: batchNameController,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.label),
                      filled: true, //<-- SEE HERE
                      fillColor: const Color(0xFFF1F3F5),
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              width: 0,
                              color: Color.fromARGB(255, 200, 209, 230)),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(width: 1, color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Batch Name'),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: sectionController,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.school),
                      filled: true, //<-- SEE HERE
                      fillColor: const Color(0xFFF1F3F5),
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              width: 0,
                              color: Color.fromARGB(255, 200, 209, 230)),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(width: 1, color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Section'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .42,
                      child: TextField(
                        controller: startRollController,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.format_list_numbered),
                            filled: true, //<-- SEE HERE
                            fillColor: const Color(0xFFF1F3F5),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 0,
                                    color: Color.fromARGB(255, 200, 209, 230)),
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Start Roll'),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .04,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .42,
                      child: TextField(
                        controller: totalStudentsController,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.people),
                            filled: true, //<-- SEE HERE
                            fillColor: const Color(0xFFF1F3F5),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 0,
                                    color: Color.fromARGB(255, 200, 209, 230)),
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Number'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 60,
                ),
                GestureDetector(
                  onTap: () {
                    _createClass(context);
                    // login(context);
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
                        'Create '.toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      )),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            print(index);
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Log Out',
          ),
        ],
      ),
      floatingActionButton: null,
    );
  }
}
