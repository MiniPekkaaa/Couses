import 'package:flutter/material.dart';
import 'static_data.dart';
import 'course_select_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TevaLearn Courses',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CourseSelectScreen(
        title: 'Курсы',
        itemsCollection: StaticData.courses,
        categoryField: 'categoryId',
      ),
    );
  }
}
