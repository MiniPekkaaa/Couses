import 'package:flutter/material.dart';
import 'course_select_screen.dart';
import 'nocodb_service.dart';
import 'dart:html' as html;
import 'telegram_webapp_js.dart';
import 'dart:convert';
import 'dart:developer' as developer;

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
                html.window.open('https://t.me/SvetlanaGyataAi_bot?start=register', '_blank');
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

void logMessage(String message, {String name = 'App'}) {
  developer.log(message, name: name);
  print('[$name] $message'); // Дублируем в print для надежности
}

Future<String?> getTelegramUserId() async {
  try {
    // Сначала пробуем получить из initDataUnsafe
    final user = initDataUnsafe.user;
    if (user?.id != null) {
      logMessage('Got user ID from initDataUnsafe: ${user!.id}');
      return user!.id!.toString();
    }

    logMessage('User not found in initDataUnsafe, trying URL params');
    // Если не получилось, пробуем из URL параметров
    final uri = Uri.parse(html.window.location.href);
    final userIdFromUrl = uri.queryParameters['user_id'];
    if (userIdFromUrl != null && userIdFromUrl.isNotEmpty) {
      logMessage('Got user ID from URL: $userIdFromUrl');
      return userIdFromUrl;
    }
    
    logMessage('Trying start_param');
    final startParam = initDataUnsafe.start_param;
    logMessage('start_param value: $startParam');
    
    if (startParam != null && startParam.contains('user_id=')) {
      final match = RegExp(r'user_id=(\d+)').firstMatch(startParam);
      final userId = match?.group(1); 
      logMessage('Extracted user ID from start_param: $userId');
      return userId;
    }
    
    return null;
  } catch (e) {
    print('Error getting user ID: $e');
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

Future<Map<String, dynamic>?> fetchUserData() async {
  final userId = await getTelegramUserId();
  if (userId == null || userId.isEmpty) return null;
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

Future<List<Map<String, dynamic>>> fetchAvailableCourses() async {
  final userId = await getTelegramUserId();
  if (userId == null) return [];
  final userData = await fetchUserData();
  final openCoursesRaw = userData?['Open courses'];
  final openCourses = openCoursesRaw != null
      ? openCoursesRaw.toString().split(',').map((e) => int.tryParse(e.trim())).where((e) => e != null).toList()
      : [];
  if (openCourses.isEmpty) {
    return [];
  }
  final allCourses = await AirtableService.fetchCourses();
  final availableCourses = allCourses.where((course) {
    final opening = course['Opening procedure'];
    final openingInt = opening is int ? opening : int.tryParse(opening.toString());
    return openingInt != null && openCourses.contains(openingInt);
  }).toList();
  
  // Сортируем курсы по полю "Opening procedure"
  availableCourses.sort((a, b) {
    final aOpening = a['Opening procedure'];
    final bOpening = b['Opening procedure'];
    final aInt = aOpening is int ? aOpening : int.tryParse(aOpening.toString()) ?? 0;
    final bInt = bOpening is int ? bOpening : int.tryParse(bOpening.toString()) ?? 0;
    return aInt.compareTo(bInt);
  });
  
  return availableCourses;
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
          return FutureBuilder<bool>(
            future: checkUserRegistered(),
            builder: (context, regSnapshot) {
              if (!regSnapshot.hasData) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (!regSnapshot.data!) {
                return const NotRegisteredScreen();
              }
              // Пользователь зарегистрирован — грузим курсы
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchAvailableCourses(),
                builder: (context, coursesSnapshot) {
                  if (!coursesSnapshot.hasData) {
                    return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  }
                  final items = coursesSnapshot.data!;
                  if (items.isEmpty) {
                    return const Scaffold(body: Center(child: Text('У вас пока нет доступных курсов', style: TextStyle(fontSize: 18))));
                  }
                  return CourseSelectScreen(
                    title: 'Курсы',
                    itemsCollection: items,
                    categoryField: 'categoryId',
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
