import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherDashBoard extends StatefulWidget {
  TeacherDashBoard({Key? key});

  @override
  State<TeacherDashBoard> createState() => _TeacherDashBoardState();
}

class _TeacherDashBoardState extends State<TeacherDashBoard> {
  String? userID = "None";
  String? role = "none";
  String? email = "none";
  int _currentIndex = 0;

  Future<void> extractData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userID');
      role = prefs.getString('role');
      email = prefs.getString('email');
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 24.0,
                    ),
                    const Icon(
                      Icons.menu_outlined,
                      color: Colors.black,
                      size: 24.0,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Align(
                  child: Text(
                    'ID: $userID',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                Text(
                  '$role'.toUpperCase(),
                  style: const TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .6,
                  child: GridView.count(
                    crossAxisCount: 3, // Number of columns in the grid
                    padding: const EdgeInsets.all(10),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _buildOptionCard(
                        icon: Icons.visibility,
                        label: 'View Attendance',
                        color: Colors.orange,
                        onPressed: () {
                          // Add your logic for "View Attendance" option
                        },
                      ),
                      _buildOptionCard(
                        icon: Icons.edit,
                        label: 'Mark Attendance',
                        color: Colors.blue,
                        onPressed: () {
                          // Add your logic for "Mark Attendance" option
                        },
                      ),
                      _buildOptionCard(
                        icon: Icons.edit,
                        label: 'Edit Attendance',
                        color: Colors.red,
                        onPressed: () {
                          // Add your logic for "Edit Attendance" option
                        },
                      ),
                      _buildOptionCard(
                        icon: Icons.receipt,
                        label: 'Attendance Reports',
                        color: Colors.green,
                        onPressed: () {
                          // Add your logic for "Attendance Reports" option
                        },
                      ),
                      _buildOptionCard(
                        icon: Icons.add,
                        label: 'Add Courses',
                        color: Colors.purple,
                        onPressed: () {
                          // Add your logic for "Add Courses" option
                        },
                      ),
                      _buildOptionCard(
                        icon: Icons.add,
                        label: 'Add Students',
                        color: Colors.teal,
                        onPressed: () {
                          // Add your logic for "Add Students" option
                        },
                      ),
                      _buildOptionCard(
                        icon: Icons.person,
                        label: 'Student Profiles',
                        color: Colors.black,
                        onPressed: () {
                          // Add your logic for "Student Profiles" option
                        },
                      ),
                      _buildOptionCard(
                        icon: Icons.analytics,
                        label: 'Analytics and Insights',
                        color: Colors.deepOrange,
                        onPressed: () {
                          // Add your logic for "Analytics and Insights" option
                        },
                      ),
                      _buildOptionCard(
                        icon: Icons.import_export,
                        label: 'Export/Import Data',
                        color: Colors.cyan,
                        onPressed: () {
                          // Add your logic for "Export/Import Data" option
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            print(index);
            _currentIndex = index;
            _handleNavigation(index);
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

  Future<void> _logOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Perform additional log out functionality if needed
    // For example, navigate to the login screen
  }

  void _handleNavigation(index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, "/teacher");
        break;
      case 1:
      case 2:
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('You will be logged out'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => {_logOut(), Navigator.pushNamed(context, "/")},
                child: const Text('OK'),
              ),
            ],
          ),
        );
        //
        break;
    }
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
