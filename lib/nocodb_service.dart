import 'dart:convert';
import 'package:http/http.dart' as http;

class AirtableService {
  static const String apiKey = 'patjbZurod2EX97nU.c63a5194242fb65ddc7eaa406a1be34e020596b9defb130953f75b3b3daf2e62';
  static const String baseId = 'appepjeg5qmyfe7sf';
  static const String coursesTable = 'tblkJW1h5dLTW6dwJ';
  static const String lessonsTable = 'tblE4Nb1q3vvzT1eX'; // Укажите id таблицы Lessons, если есть

  static Future<List<Map<String, dynamic>>> fetchCourses() async {
    final url = 'https://api.airtable.com/v0/$baseId/$coursesTable';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
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
      throw Exception('Ошибка загрузки курсов: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchLessons() async {
    final List<Map<String, dynamic>> allLessons = [];
    String? offset;
    do {
      final url = 'https://api.airtable.com/v0/$baseId/$lessonsTable'
          '${offset != null ? '?offset=$offset' : ''}';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $apiKey'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        allLessons.addAll(List<Map<String, dynamic>>.from(
          data['records'].map((r) {
            final map = Map<String, dynamic>.from(r['fields']);
            map['id'] = r['id'];
            return map;
          })
        ));
        offset = data['offset'];
      } else {
        throw Exception('Ошибка загрузки уроков: \\${response.body}');
      }
    } while (offset != null);

    // Подмена контента для уроков с ref_lesson
    final lessonsById = {for (var l in allLessons) l['id']: l};
    for (final lesson in allLessons) {
      var refId = lesson['ref_lesson'];
      // Если ref_lesson — список, берём первый элемент
      if (refId is List && refId.isNotEmpty) {
        refId = refId.first;
      }
      if (refId != null && refId is String && refId.isNotEmpty && lessonsById.containsKey(refId)) {
        final refLesson = lessonsById[refId]!;
        for (final key in refLesson.keys) {
          if (!['id', 'Name', 'Order', 'Module', 'Course', 'ref_lesson', 'ref_course'].contains(key)) {
            lesson[key] = refLesson[key];
          }
        }
      }
    }
    return allLessons;
  }
} 