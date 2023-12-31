import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class GenerateAttendanceQrCode extends StatefulWidget {
  const GenerateAttendanceQrCode({super.key});

  @override
  State<GenerateAttendanceQrCode> createState() =>
      _GenerateAttendanceQrCodeState();
}

class _GenerateAttendanceQrCodeState extends State<GenerateAttendanceQrCode> {
  String? code = "";
  String batchName = "";
  late String section = "";
  late List<bool> attendanceList;
  //creating list of courses for dropdown

  List<CourseDropdownItem> Courses = [];
  List<String> Duration = ['5 min', '10 min', '30 min', '45 min', '60 min'];

  CourseDropdownItem? selectedCourse;
  String? selectedDuration;
  String? qrUriImg;
  late DateTime selectedDate; // Track the selected date
  String? userID = "None";
  String? role = "none";
  String? email = "none";

  Future<void> extractData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('id');
      role = prefs.getString('role');
      email = prefs.getString('email');
    });
  }

  @override
  void initState() {
    super.initState();
    extractData();
    fetchCourses(context);
    selectedDate =
        DateTime.now(); // Initialize the selected date to the current date
  }

  Future<void> setCode(BuildContext context) async {
    code = ModalRoute.of(context)?.settings.arguments as String?;
  }

  Future<void> fetchCourses(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final courseId = ModalRoute.of(context)?.settings.arguments as String?;
      final Uri loginUri = Uri.parse(
          'https://attendence-backend-silk.vercel.app/api/v1/teacher/course/$userID');
      final http.Response response = await http.get(loginUri);
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> courses = data['courses'];
      // final List<dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // var data2 = data['courses'];
        // print(data2.length);

        setState(() {
          Courses = courses.map<CourseDropdownItem>((item) {
            return CourseDropdownItem(
              item['_id'],
              '${item['code']} - ${item['section']} Section - ${item['batchName']} Batch',
            );
          }).toList();
        });
      } else {
        throw Exception("Failed to Load Courses Item");
      }
    } catch (error) {
      // Navigator.pop(context);
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
              Text('Failed to Load Courses Item'),
            ],
          ),
        ),
      );
      //throw Exception("Failed to Load Data");
    }
  }

  Future<void> getQrCode(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the loading screen
      builder: (_) => Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      var date = DateTime.parse(selectedDate.toString());
      var formattedDate = "${date.day}-${date.month}-${date.year}";
      final courseCode = selectedCourse?.id;
      var duration = int.parse(selectedDuration!.split(" ")[0]) * 60;
      final Uri fetchUri = Uri.parse(
          'https://attendence-backend-silk.vercel.app/api/v1/teacher/course/attendance/qr?courseId=$courseCode&date=$formattedDate&duration=$duration');
      print(fetchUri);
      final http.Response response = await http.get(fetchUri);
      final Map<String, dynamic> data = await jsonDecode(response.body);
      // final List<dynamic> code = data['qrCode'];
      if (response.statusCode == 200) {
        Navigator.pop(context);
        print(data);
        //  print(attendance[0]._id);
        setState(() {
          qrUriImg = data['qrCode'];
        });
      } else {
        throw Exception("Failed to Create Attendance");
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
              Text('Failed to Create Attendance'),
            ],
          ),
        ),
      );
      //throw Exception("Failed to Load Data");
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseId = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Text('Generate Qr Code'),
            SizedBox(width: 8),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 60,
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Selected Date: ${selectedDate.toString().substring(0, 10)}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    DatePickerButton(
                      // Custom button to open date picker
                      selectedDate: selectedDate,
                      onDateChanged: (DateTime newDate) {
                        setState(() {
                          selectedDate = newDate;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width * .9,
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CourseDropdownItem>(
                        value: selectedCourse,
                        onChanged: (newValue) {
                          setState(() {
                            selectedCourse = newValue;
                            // fetchAttendance(context);
                          });
                        },
                        hint: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Select a Course"),
                        ),
                        underline: Container(), // Removes the underline
                        items: Courses.map((item) {
                          return DropdownMenuItem<CourseDropdownItem>(
                            value: item,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(item.text),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Icon(Icons.arrow_drop_down), // Right-aligned dropdown arrow
                ],
              ),
            ),
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width * .9,
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedDuration,
                        onChanged: (newValue) {
                          setState(() {
                            selectedDuration = newValue!;
                            // fetchAttendance(context);
                          });
                        },
                        hint: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Qr Code Validation Time"),
                        ),

                        underline: Container(), // Removes the underline
                        items: Duration.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(item),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Icon(Icons.arrow_drop_down), // Right-aligned dropdown arrow
                ],
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            GestureDetector(
              onTap: () {
                if (selectedCourse == null) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text(
                        'Validation Error',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      content: const Text(
                        'Course Cannot Be Empty',
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else if (selectedDuration == null) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text(
                        'Validation Error',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      content: const Text(
                        'Duration Cannot Be Empty',
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  print(selectedDuration);
                  print(selectedCourse);
                  getQrCode(context);
                }
                // login(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * .5,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue, width: 2),
                  color: Colors.blue,
                ),
                child: const Center(
                  child: Text(
                    'Generate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            qrUriImg != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height:
                              300, // Set the desired height of the container
                          width: MediaQuery.of(context).size.width * .8,
                          // Set the desired width of the container
                          decoration: BoxDecoration(
                            color: Colors.white, // Container background color
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.memory(
                            // Replace this with your base64 image data
                            base64Decode(qrUriImg!.split(',')[1]),
                            fit: BoxFit.contain,
                          ),
                          // This resizes the image to fit within the container
                        ),

                        // Image.memory(
                        //   base64Decode(
                        //       // Your base64 data URI here
                        //       qrUriImg!.split(',')[1]),
                        // ),

                        GestureDetector(
                          onTap: () {
                            // login(context);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * .5,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.black, width: 2),
                              color: Colors.black,
                            ),
                            child: const Center(
                              child: Text(
                                'Share Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Image.memory(
                        //   base64Decode(
                        //       // Your base64 data URI here
                        //       qrUriImg!.split(',')[1]),
                        // ),
                      ],
                    ),
                  )
                : const Text(
                    "No Qr Code Found",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Colors.red),
                  ),
          ],
        ),
      ),
    );
  }
}

class DatePickerButton extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DatePickerButton({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _showDatePicker(context);
      },
      icon: Icon(Icons.date_range),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2025),
    );

    if (pickedDate != null) {
      onDateChanged(pickedDate);
    }
  }
}

class CourseDropdownItem {
  final String id;
  final String text;
  CourseDropdownItem(this.id, this.text);
}
