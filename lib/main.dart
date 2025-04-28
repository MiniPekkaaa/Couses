import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'course_select_screen.dart';
import 'lms_search_field.dart';
import 'lms_tabs_screen.dart';
import 'my_courses_screen.dart';
import 'static_data.dart';

// Коллекции данных
late List<Map<String, dynamic>> categories;
late List<Map<String, dynamic>> courses;
late List<Map<String, dynamic>> lessons;

Future<bool> isAdmin() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('Admin Mode') ?? false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Загрузка данных
  categories = StaticData.categories;
  courses = StaticData.courses;
  lessons = courses.expand((course) => course['lessons'] as List).toList();
  
  // Запуск приложения
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TevaLearn Courses',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LMSTabsScreen('Test Tabs', screens: [
        CourseSelectScreen(
          title: 'Explore',
          itemsCollection: courses,
          categoryField: 'Category',
        )..icon = Icons.explore,
        CardsScreen(collection: courses, title: 'Search')..icon = Icons.search,
        LMSMyCoursesScreen(
          title: 'My Courses',
          favouritesFeature: FavouritesFeature(collection: courses),
        )..icon = Icons.person,
        CardsScreen(collection: categories)..show = (context) => isAdmin(),
        CollectionScreen(collection: courses)..show = (context) => isAdmin(),
        CollectionScreen(collection: lessons)..show = (context) => isAdmin(),
      ])..appbarEnabled = true,
    );
  }
}
