import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceReport extends StatefulWidget {
  const AttendanceReport({super.key});

  @override
  State<AttendanceReport> createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  String? code = "";
  String batchName = "";
  late String section = "";
  late List<bool> attendanceList;
  //creating list of courses for dropdown

  List<CourseDropdownItem> Courses = [];
  List<Attendance> attendances = [];
  CourseDropdownItem? selectedCourse;

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
      final Uri loginUri =
          Uri.parse('http://192.168.43.173:4001/api/v1/teacher/course/$userID');
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

  // Future<void> saveAttendanceAsPDF(List<Attendance> attendances) async {
  //   final pdf = pw.Document();

  //   pdf.addPage(
  //     pw.Page(
  //       build: (context) => pw.Column(
  //         children: [
  //           pw.Header(text: 'Attendance Report'),
  //           pw.Table.fromTextArray(
  //             context: context,
  //             data: <List<String>>[
  //               <String>['Student ID', 'Percentage'],
  //               for (final attendance in attendances)
  //                 <String>[
  //                   attendance.studentId,
  //                   '${attendance.attendancePercentage.toStringAsFixed(2)}%'
  //                 ],
  //             ],
  //             cellStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //             headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );

  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final filePath = '${directory.path}/attendance_report.pdf';

  //     final file = File("new.pdf");
  //     await file.writeAsBytes(await pdf.save());

  //     // Show a success message to the user
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: Colors.green,
  //         content: const Text('Attendance data saved as PDF.'),
  //       ),
  //     );
  //   } catch (e) {
  //     // Handle any exceptions that may occur during file operations
  //     print('Error saving PDF: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: Colors.red,
  //         content: const Text('Failed to save PDF.'),
  //       ),
  //     );
  //   }
  // }

  Future<void> fetchAttendance(BuildContext context) async {
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
      final Uri fetchUri = Uri.parse(
          'http://192.168.43.173:4001/api/v1/teacher/course/attendance/?courseId=$courseCode');
      final http.Response response = await http.get(fetchUri);
      final Map<String, dynamic> data = await jsonDecode(response.body);
      final List<dynamic> attendance = data['attendance'];
      if (response.statusCode == 200) {
        Navigator.pop(context);
        //  print(attendance[0]._id);
        setState(() {
          attendances = attendance.map<Attendance>((item) {
            return Attendance(item['studentId'], item['attendancePercentage'],
                item['totalClass']);
          }).toList();
        });
      } else {
        throw Exception("Failed to load attendance");
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
              Text('Failed to Load Courses Item'),
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
            Text('Attendance Report'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width * .9,
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CourseDropdownItem>(
                      value: selectedCourse,
                      onChanged: (newValue) {
                        setState(() {
                          selectedCourse = newValue;
                          fetchAttendance(context);
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
          attendances.isNotEmpty
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "StudentId",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Percentage",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : const Text(
                  "No Result Found",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.red),
                ),
          const Divider(),
          Expanded(
            child: ListView.separated(
              itemCount: attendances.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 1),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          attendances[index].studentId,
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          attendances[index]
                                      .attendancePercentage
                                      .toString()
                                      .length <
                                  5
                              ? "${attendances[index].attendancePercentage}%"
                              : "${attendances[index].attendancePercentage.toString().substring(0, 5)}%",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue),
                        ),
                      ],
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
          //saveAttendance(courseId);
        },
        child: const Icon(Icons.download),
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

class Attendance {
  final String studentId;
  var attendancePercentage;
  final int totalClass;

  Attendance(
    this.studentId,
    this.attendancePercentage,
    this.totalClass,
  );
}
