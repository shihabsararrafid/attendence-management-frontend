import 'dart:convert';
import 'package:flutter/material.dart';
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
  late List<bool> attendanceList;
  final List<Student> students = [];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Uri loginUri = Uri.parse(
          'http://192.168.0.113:4001/api/v1/teacher/course/students/64af6a5aa4bf4019e5e9bf8e');
      final http.Response response = await http.get(loginUri);
      var data = jsonDecode(response.body);

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
        });
      } else {
        throw Exception("Failed to Load Data");
      }
    } catch (error) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(students[index].id),
            leading: Checkbox(
              value: attendanceList[index],
              onChanged: (value) {
                setState(() {
                  attendanceList[index] = value ?? false;
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveAttendance();
        },
        child: Icon(Icons.save),
      ),
    );
  }

  void saveAttendance() async {
    try {
      for (int i = 0; i < attendanceList.length; i++) {
        String studentId = students[i].id;
        bool isPresent = attendanceList[i];

        Map<String, dynamic> requestBody = {
          'studentId': studentId,
          'courseId': 'your_course_id', // Replace with the actual course ID
          'date': DateTime.now().toString(),
          'attendanceStatus': isPresent ? 'present' : 'absent',
        };

        final response = await http.post(
          Uri.parse('http://your_api_url/attendance'),
          body: requestBody,
        );

        if (response.statusCode == 200) {
          print('Attendance saved for $studentId');
        } else {
          print('Failed to save attendance for $studentId');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance saved successfully'),
        ),
      );
    } catch (error) {
      print('Failed to save attendance: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save attendance'),
        ),
      );
    }
  }
}
