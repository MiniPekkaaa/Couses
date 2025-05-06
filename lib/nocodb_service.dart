import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AirtableService {
  static const String apiKey = 'patjbZurod2EX97nU.c63a5194242fb65ddc7eaa406a1be34e020596b9defb130953f75b3b3daf2e62';
  static const String baseId = 'appepjeg5qmyfe7sf';
  static const String coursesTable = 'tblkJW1h5dLTW6dwJ';
  static const String lessonsTable = 'tblE4Nb1q3vvzT1eX'; // Укажите id таблицы Lessons, если есть

  static Future<List<Map<String, dynamic>>> fetchCourses() async {
    try {
      final url = 'https://api.airtable.com/v0/$baseId/$coursesTable';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $apiKey'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(
          data['records'].map((r) {
            final map = Map<String, dynamic>.from(r['fields']);
            map['id'] = r['id']; // добавляем recordId курса
            return map;
          })
        );
      } else {
        throw Exception('Ошибка загрузки курсов (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке курсов: $e');
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchLessons() async {
    try {
      final url = 'https://api.airtable.com/v0/$baseId/$lessonsTable';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $apiKey'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(
          data['records'].map((r) {
            final map = Map<String, dynamic>.from(r['fields']);
            map['id'] = r['id'];
            return map;
          })
        );
      } else {
        throw Exception('Ошибка загрузки уроков (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке уроков: $e');
      }
      rethrow;
    }
  }
} 