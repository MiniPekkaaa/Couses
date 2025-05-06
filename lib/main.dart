import 'package:flutter/material.dart';
import 'course_select_screen.dart';
import 'nocodb_service.dart';

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
      home: FutureBuilder<List<Map<String, dynamic>>>(
        future: AirtableService.fetchCourses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          return CourseSelectScreen(
            title: 'Курсы',
            itemsCollection: snapshot.data!,
            categoryField: 'categoryId',
          );
        },
      ),
    );
  }
}
