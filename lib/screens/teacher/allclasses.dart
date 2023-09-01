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
  List<Course> filteredList = [];
  TextEditingController _searchController = TextEditingController();
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
        List<Course> TempCourse = [];
        for (var courseData in data['courses']) {
          Course course = Course(
            id: courseData['_id'],
            code: courseData['code'],
            section: courseData['section'],
            batchName: courseData['batchName'],
          );
          setState(() {
            courseList.add(course);
          });
        }
        filteredList = courseList;
        print(courseList.length);
        return courseList;
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: const Text("Server Error"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
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

  void filterClasses(String query) {
    List<Course> tmp = [];
    // print(query);
    tmp = courseList
        .where((course) =>
            course.code.toLowerCase().contains(query.toLowerCase()) ||
            course.section.toLowerCase().contains(query.toLowerCase()) ||
            course.batchName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    //print(filteredList.length);
    setState(() {
      filteredList = tmp;
    });
    // if (query == "") {
    //   filteredList = courseList;
    // }
    // setState(() {
    //   courseList = filteredList;
    //   // Update the filtered list
    //   // You can use this filteredList to display the filtered data in your UI
    // });
  }

  Future<void> deleteCourse(courseId) async {
    final Uri deleteUri =
        Uri.parse('http://192.168.0.113:4001/api/v1/teacher/course/$id');
    final http.Response response =
        await http.delete(deleteUri, body: {"courseId": courseId});

    if (response.statusCode == 200) {
      setState(() {
        courseList.removeWhere((course) => course.id == courseId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            children: [
              Icon(
                Icons.check,
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Text('Course deleted successfully'),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Text('Failed to delete course'),
            ],
          ),
        ),
      );
    }
  }

  Future<void> deleteIt(String courseId) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Warning',
              style: TextStyle(color: Colors.red),
            ),
            Icon(
              Icons.warning,
              color: Colors.red,
            )
          ],
        )),
        content: const Text("Are you sure to delete this course?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => {Navigator.pop(context), deleteCourse(courseId)},
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  FocusNode _searchFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 50),
              Text(
                'All Classes',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: () => {FocusScope.of(context).unfocus()}, //,
                child: TextField(
                  focusNode: _searchFocusNode,
                  controller: _searchController,
                  onChanged: (value) {
                    // Call a function to filter the courseList based on the search query
                    filterClasses(value);
                  },
                  onTap: () {
                    _searchFocusNode.requestFocus(); // Request focus on tap
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search",
                    filled: true, //<-- SEE HERE
                    fillColor: const Color(0xFFF1F3F5),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 0,
                            color: Color.fromARGB(255, 200, 209, 230)),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: SizedBox(
                  child: FutureBuilder<List<Course>>(
                    future: _allClassesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ShimmerLoadingTable();
                      } else if (snapshot.hasData) {
                        return BlueDataTable(
                          courseList: filteredList,
                          deleteCallback: deleteIt,
                        );
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
        columns: const [
          DataColumn(label: Text('Course')),
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
  final Function(String) deleteCallback;

  const BlueDataTable({
    required this.courseList,
    required this.deleteCallback,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        columns: const [
          DataColumn(
            label: Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'Course',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Section',
              style: TextStyle(fontSize: 16),
            ),
          ),
          DataColumn(
            label: Text(
              'Series',
              style: TextStyle(fontSize: 16),
            ),
          ),
          DataColumn(
            label: Text(
              'Actions',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
        rows: courseList.map((course) {
          return DataRow(cells: [
            DataCell(
              InkWell(
                onTap: () {
                  // Handle course click
                },
                child: Center(
                  child: Row(
                    children: [
                      InkWell(
                          onTap: () => {
                                Navigator.pushNamed(
                                    context, "/teacher/takeattendence",
                                    arguments: course.id),
                                print("Icon CLicked")
                              },
                          child: Icon(Icons.arrow_forward, color: Colors.blue)),
                      Text(course.code),
                    ],
                  ),
                ),
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
                  deleteCallback(course.id);
                },
                child: Center(
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ]);
        }).toList(),
        dataRowHeight: 56,
        dividerThickness: 1.5,
        horizontalMargin: 0,
        headingRowHeight: 56,
      ),
    );
  }
}
