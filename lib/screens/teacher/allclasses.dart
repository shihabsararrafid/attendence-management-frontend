import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class AllClasses extends StatefulWidget {
  const AllClasses({Key? key}) : super(key: key);

  @override
  State<AllClasses> createState() => _AllClassesState();
}

class Course {
  final String id;
  final String code;
  final String section;
  final String batchName;

  Course({
    required this.id,
    required this.code,
    required this.section,
    required this.batchName,
  });
}

class _AllClassesState extends State<AllClasses> {
  String? userID = "None";
  String? role = "none";
  String? email = "none";
  String? id = "none";
  List<Course> courseList = [];
  late Future<List<Course>> _allClassesFuture;

  Future<List<Course>> _allClasses() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userID = prefs.getString('userID');
        role = prefs.getString('role');
        email = prefs.getString('email');
        id = prefs.getString('id');
      });

      final Uri loginUri =
          Uri.parse('http://192.168.0.113:4001/api/v1/teacher/course/$id');
      final http.Response response = await http.get(loginUri);
      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        for (var courseData in data['courses']) {
          Course course = Course(
            id: courseData['_id'],
            code: courseData['code'],
            section: courseData['section'],
            batchName: courseData['batchName'],
          );
          courseList.add(course);
        }
        return courseList;
      } else {
        throw Exception("Failed to Load Data");
      }
    } catch (error) {
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
      throw Exception("Failed to Load Data");
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
    _allClassesFuture = _allClasses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Text(
                "All Classes",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .8,
                  child: FutureBuilder<List<Course>>(
                    future: _allClassesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ShimmerLoadingTable();
                      } else if (snapshot.hasData) {
                        return BlueDataTable(courseList: snapshot.data!);
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

class ShimmerLoadingTable extends StatelessWidget {
  const ShimmerLoadingTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: DataTable(
        columns: [
          DataColumn(
              label: Text(
            'Course',
          )),
          DataColumn(label: Text('Section')),
          DataColumn(label: Text('Series')),
          DataColumn(label: Text('Actions')),
        ],
        rows: List.generate(
          5,
          (index) => DataRow(
            cells: [
              DataCell(Container(
                  width: MediaQuery.of(context).size.width * .21,
                  height: 16,
                  color: Colors.white)),
              DataCell(Container(
                  width: MediaQuery.of(context).size.width * .21,
                  height: 16,
                  color: Colors.white)),
              DataCell(Container(
                  width: MediaQuery.of(context).size.width * .21,
                  height: 16,
                  color: Colors.white)),
              DataCell(Container(
                  width: MediaQuery.of(context).size.width * .21,
                  height: 16,
                  color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class BlueDataTable extends StatelessWidget {
  final List<Course> courseList;

  const BlueDataTable({required this.courseList, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        columns: [
          DataColumn(
              label: Text(
            'Course',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          )),
          DataColumn(
              label: Text('Section',
                  style: TextStyle(
                    fontSize: 16,
                  ))),
          DataColumn(
              label: Text('Series',
                  style: TextStyle(
                    fontSize: 16,
                  ))),
          DataColumn(
              label: Text('Actions',
                  style: TextStyle(
                    fontSize: 16,
                  ))),
        ],
        rows: courseList.map((course) {
          return DataRow(
            cells: [
              DataCell(
                InkWell(
                  onTap: () {
                    // Handle course click
                  },
                  child: Center(child: Text(course.code)),
                ),
              ),
              DataCell(
                InkWell(
                  onTap: () {
                    // Handle section click
                  },
                  child: Center(child: Text(course.section)),
                ),
              ),
              DataCell(
                InkWell(
                  onTap: () {
                    // Handle series click
                  },
                  child: Center(child: Text(course.batchName)),
                ),
              ),
              DataCell(
                InkWell(
                  onTap: () {
                    // Handle series click
                  },
                  child: Center(
                      child: const Text(
                    "Delete",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.w400),
                  )),
                ),
              ),
            ],
          );
        }).toList(),
        dataRowHeight: 56,
        dividerThickness: 1.5,
        horizontalMargin: 0,
        headingRowHeight: 56,
      ),
    );
  }
}
