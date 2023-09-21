import 'package:flutter/material.dart';
import './screens/login.dart';
import './screens/carousel.dart';
import "./screens/register.dart";
import "./screens/teacher//teacherdashboard.dart";
import "./screens/teacher/allclasses.dart";
import "./screens/teacher/addClass.dart";
import "./screens/teacher/generateQr.dart";
import "./screens/teacher/takeAttendence.dart";
import 'screens/teacher/viewAttendance.dart';
import 'screens/teacher/attendanceReport.dart';
import 'screens/student/studentDashboard.dart';
import 'screens/student/allClasses.dart';
import 'screens/student/viewAttendance.dart';
import 'utils/scanQrCode.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (context) => CarouselPage(),
        "/login": (context) => Login(),
        "/register": (context) => RegisterPage(),
        "/teacher": (context) => TeacherDashBoard(),
        "/teacher/allClasses": (context) => AllClasses(),
        "/teacher/addClass": (context) => AddClass(),
        "/teacher/view": (context) => ViewAttendanceByTeacher(),
        "/teacher/takeattendence": (context) => AttendanceScreen(),
        "/teacher/attendanceReport": (context) => AttendanceReport(),
        "/teacher/qr": (context) => GenerateAttendanceQrCode(),
        "/student": (context) => StudentDashBoard(),
        "/student/allClasses": (context) => AllClassesStudent(),
        "/student/view": (context) => ViewAttendanceByStudent()
        // "/capturePhoto": (context) => CameraScreen(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
