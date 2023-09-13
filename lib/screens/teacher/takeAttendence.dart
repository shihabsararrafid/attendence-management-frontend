import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Student {
  final String id;

  Student({
    required this.id,
  });
}

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late String code = "";
  String batchName = "";
  late String section = "";

  late List<bool> attendanceList;
  final List<Student> students = [];
  late DateTime selectedDate; // Track the selected date

  @override
  void initState() {
    super.initState();
    fetchStudents(context);
    selectedDate =
        DateTime.now(); // Initialize the selected date to the current date
  }

  Future<void> fetchStudents(BuildContext context) async {
    // showDialog(
    //   context: context,
    //   barrierDismissible: false, // Prevent dismissing the loading screen
    //   builder: (_) => Center(
    //     child: CircularProgressIndicator(),
    //   ),
    // );
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final courseId = ModalRoute.of(context)?.settings.arguments as String?;
      final Uri loginUri = Uri.parse(
          'http://192.168.43.173:4001/api/v1/teacher/course/students/$courseId');
      final http.Response response = await http.get(loginUri);
      var data = jsonDecode(response.body);
      //  Navigator.pop(context);
      if (response.statusCode == 200) {
        List<Student> studentList = [];

        var data2 = data['courses'][0]['students'];
        print(data2.length);
        for (var courseData in data2) {
          Student student = Student(
            id: courseData['userId'],
          );
          studentList.add(student);
        }
        setState(() {
          print(studentList.length);
          students.addAll(studentList);
          attendanceList = List<bool>.filled(students.length, false);
          code = data['courses'][0]['code'];
          batchName = data['courses'][0]['batchName'];
          section = data['courses'][0]['section'];
        });
      } else {
        throw Exception("Failed to Load Data");
      }
    } catch (error) {
      // Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(
            ' Failed',
            style: TextStyle(),
          ),
          content: const Text("Failed to Load Data"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Try Again'),
            ),
          ],
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
          children: [
            Text('Attendance'),
            SizedBox(width: 8),
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
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$code",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(width: 8),
                Text(
                  "$batchName",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(width: 8),
                Text(
                  "Section $section",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
          Container(
            height: 60,
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Selected Date: ${selectedDate.toString().substring(0, 10)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: students.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      students[index].id,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    leading: Checkbox(
                      value: attendanceList[index],
                      onChanged: (value) {
                        setState(() {
                          attendanceList[index] = value ?? false;
                        });
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.info),
                      color: Colors.blue,
                      onPressed: () {
                        //   showStudentDetails(students[index]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveAttendance(courseId);
        },
        child: Icon(Icons.save),
      ),
    );
  }

  void saveAttendance(String? courseId) async {
    // Same implementation as before
    try {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing the loading screen
        builder: (_) => Center(
          child: CircularProgressIndicator(),
        ),
      );
      List<Map<String, dynamic>> attendanceData = [];
      for (int i = 0; i < attendanceList.length; i++) {
        String studentId = students[i].id;
        bool isPresent = attendanceList[i];
        var date = DateTime.parse(selectedDate.toString());
        var formattedDate = "${date.day}-${date.month}-${date.year}";

        Map<String, dynamic> requestBody = {
          'studentId': studentId,
          'courseId': courseId,
          'date': formattedDate,
          'attendanceStatus': isPresent ? 'present' : 'absent',
        };
        attendanceData.add(requestBody);
        //print(formattedDate);
        //  print(requestBody);
      }
      print(attendanceData);
      final response = await http.post(
        Uri.parse(
            'http://192.168.43.173:4001/api/v1/teacher/course/attendance'),
        headers: {
          'Content-Type': 'application/json', // Specify JSON content type
        },
        body: jsonEncode(attendanceData),
      );

      //  print(response);
      if (response.statusCode == 200) {
        print('Attendance saved for all student');
      } else {
        print('Failed to save attendance for some students');
      }
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
              Text('Attendance saved successfully'),
            ],
          ),
        ),
      );
    } catch (error) {
      Navigator.pop(context);
      print('Failed to save attendance: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Row(
            children: const [
              Icon(
                Icons.error,
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Text('Failed to Save Attendance'),
            ],
          ),
        ),
      );
    }
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
