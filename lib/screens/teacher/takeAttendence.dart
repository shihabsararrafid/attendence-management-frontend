import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TakeAttendence extends StatefulWidget {
  const TakeAttendence({super.key});

  @override
  State<TakeAttendence> createState() => _TakeAttendenceState();
}

class _TakeAttendenceState extends State<TakeAttendence> {
  @override
  Widget build(BuildContext context) {
    var route = ModalRoute.of(context);
    var courseId = route?.settings.arguments as String;
    print('CourseId : $courseId');
    return const Placeholder();
  }
}
