import 'dart:convert';
import 'package:http/http.dart' as http;

class AirtableService {
  static const String apiKey = 'patjbZurod2EX97nU.c63a5194242fb65ddc7eaa406a1be34e020596b9defb130953f75b3b3daf2e62';
  static const String baseId = 'appepjeg5qmyfe7sf';
  static const String coursesTable = 'tblkJW1h5dLTW6dwJ';
  static const String lessonsTable = 'tblE4Nb1q3vvzT1eX';

  // Извлечение URL видео из контента
  static String? extractVideoUrl(String content) {
    final RegExp videoUrlPattern = RegExp(
      r'https?:\/\/(?:www\.)?kinescope\.io\/(?:embed\/)?([a-zA-Z0-9_-]+)',
      caseSensitive: false,
    );
    final match = videoUrlPattern.firstMatch(content);
    return match?.group(0);
  }

  // Получение ID видео из URL Kinescope
  static String? getKinescopeVideoId(String url) {
    final RegExp videoIdPattern = RegExp(
      r'kinescope\.io\/(?:embed\/)?([a-zA-Z0-9_-]+)',
      caseSensitive: false,
    );
    final match = videoIdPattern.firstMatch(url);
    return match?.group(1);
  }

  // Получение курсов
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
          map['id'] = r['id'];
          return map;
        })
      );
    } else {
      throw Exception('Ошибка загрузки курсов: ${response.body}');
    }
  }

  // Получение уроков
  static Future<List<Map<String, dynamic>>> fetchLessons() async {
    final url = 'https://api.airtable.com/v0/$baseId/$lessonsTable';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(
        data['records'].map((r) {
          final map = Map<String, dynamic>.from(r['fields']);
          map['id'] = r['id'];
          
          // Извлекаем URL видео из контента
          final content = map['Content'] ?? '';
          final videoUrl = extractVideoUrl(content);
          if (videoUrl != null) {
            map['videoUrl'] = videoUrl;
            map['videoId'] = getKinescopeVideoId(videoUrl);
          }
          
          return map;
        })
      );
    } else {
      throw Exception('Ошибка загрузки уроков: ${response.body}');
    }
  }
} 