import 'package:flutter/material.dart';
import 'course_select_screen.dart';
import 'nocodb_service.dart';
import 'dart:html' as html;
import 'telegram_webapp_js.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Очищаем кеш Flutter при запуске
  PaintingBinding.instance.imageCache.clear();
  PaintingBinding.instance.imageCache.clearLiveImages();
  runApp(MyApp());
}

class NotRegisteredScreen extends StatelessWidget {
  const NotRegisteredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Вы не зарегистрированы в системе',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                html.window.open('https://t.me/school_life_otto_bot?start=register', '_blank');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5288c1),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Продолжить регистрацию в боте', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> getTelegramUserId() async {
  try {
    final user = initDataUnsafe.user;
    return user?.id?.toString();
  } catch (_) {
    return null;
  }
}

Future<bool> checkUserRegistered() async {
  final userId = await getTelegramUserId();
  if (userId == null || userId.isEmpty) {
    return false;
  }
  try {
    final response = await html.HttpRequest.request(
      '/api/check_user?user_id=$userId',
      method: 'GET',
    );
    return response.status == 200 && response.responseText == '1';
  } catch (_) {
    return false;
  }
}

Future<Map<String, dynamic>?> fetchUserData(String userId) async {
  try {
    final response = await html.HttpRequest.request(
      '/api/get_user?user_id=$userId',
      method: 'GET',
    );
    if (response.status == 200 && response.responseText != null) {
      return jsonDecode(response.responseText!);
    }
  } catch (_) {}
  return null;
}

Future<List<Map<String, dynamic>>> fetchAvailableCourses(String userId) async {
  final userData = await fetchUserData(userId);
  if (userData == null) return [];
  final openCourses = (userData['Open courses'] as String?)?.split(',').map((e) => e.trim()).toList() ?? [];
  final allCourses = await AirtableService.fetchCourses();
  return allCourses.where((course) {
    final opening = course['Opening procedure']?.toString();
    return opening != null && openCourses.contains(opening);
  }).toList();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TevaLearn Courses',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<String?>(
        future: getTelegramUserId(),
        builder: (context, userIdSnapshot) {
          if (!userIdSnapshot.hasData || userIdSnapshot.data == null) {
            return const NotRegisteredScreen();
          }
          final userId = userIdSnapshot.data!;
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchAvailableCourses(userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
              if (snapshot.data!.isEmpty) {
                return const NotRegisteredScreen();
              }
              return CourseSelectScreen(
                title: 'Курсы',
                itemsCollection: snapshot.data!,
                categoryField: 'categoryId',
              );
            },
          );
        },
      ),
    );
  }
}
