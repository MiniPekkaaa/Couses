import 'dart:convert';
import 'package:http/http.dart' as http;

class NocoDBService {
  static const String apiUrl = 'http://46.101.121.75:8080/api/v2/tables';
  static const String apiKey = 'g68IOq9S9s5zyC2KSv4Ld4z5lNVvbpKLVd7SyClP';

  // ID таблиц из вашего API
  static const String coursesTableId = 'm2dpm6io3n343mn';
  static const String lessonsTableId = 'm2inpyz3ugqrvgz';

  static Future<List<Map<String, dynamic>>> fetchCourses() async {
    final response = await http.get(
      Uri.parse('$apiUrl/$coursesTableId/records'),
      headers: {'xc-token': apiKey},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['list']);
    } else {
      throw Exception('Ошибка загрузки курсов');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchLessons(dynamic courseId) async {
    final response = await http.get(
      Uri.parse('$apiUrl/$lessonsTableId/records?where=course_id,eq,$courseId'),
      headers: {'xc-token': apiKey},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['list']);
    } else {
      throw Exception('Ошибка загрузки уроков');
    }
  }
} 