import 'package:flutter/material.dart';
import 'course_select_screen.dart';
import 'nocodb_service.dart';
import 'dart:html' as html;
import 'dart:js' as js;
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

Future<String?> getTelegramUserId() async {
  try {
    print('🔍 === ОТЛАДКА ПОЛУЧЕНИЯ USER ID ===');
    
    // Способ 1: через initDataUnsafe (работает для Inline Keyboard)
    try {
      final user = initDataUnsafe.user;
      print('📱 initDataUnsafe.user: $user');
      if (user?.id != null) {
        print('✅ User ID через initDataUnsafe: ${user!.id}');
        return user.id.toString();
      }
    } catch (e) {
      print('❌ Ошибка initDataUnsafe: $e');
    }
    
    // Способ 2: через webApp.initData (для Reply Keyboard)
    try {
      final initData = webApp.initData;
      print('📱 webApp.initData: "$initData"');
      if (initData.isNotEmpty) {
        final params = Uri.parse('?$initData').queryParameters;
        print('📱 Parsed params: $params');
        final userJson = params['user'];
        if (userJson != null) {
          final userData = jsonDecode(userJson);
          final userId = userData['id'];
          if (userId != null) {
            print('✅ User ID через webApp.initData: $userId');
            return userId.toString();
          }
        }
      }
    } catch (e) {
      print('❌ Ошибка webApp.initData: $e');
    }
    
    // Способ 3: через Chat ID (для Reply Keyboard в приватных чатах)
    try {
      final chat = webApp.chat;
      print('💬 webApp.chat: $chat');
      
      if (chat != null && chat.type == 'private') {
        final chatId = chat.id.toString();
        print('✅ Chat ID (= User ID для приватного чата): $chatId');
        return chatId;
      }
    } catch (e) {
      print('❌ Ошибка webApp.chat: $e');
    }
    
    // Способ 4: через URL параметры (для Reply Keyboard)
    final currentUrl = html.window.location.href;
    final uri = Uri.parse(currentUrl);
    print('🌐 Текущий URL: $currentUrl');
    print('🌐 URI параметры: ${uri.queryParameters}');
    
    final userIdFromUrl = uri.queryParameters['user_id'];
    print('🌐 user_id из URL: "$userIdFromUrl"');
    
    if (userIdFromUrl != null && userIdFromUrl.isNotEmpty) {
      print('✅ User ID через URL: $userIdFromUrl');
      return userIdFromUrl;
    }
    
    // Способ 5: через JS API напрямую
    try {
      final telegramObj = js.context['Telegram'];
      if (telegramObj != null) {
        final webAppObj = telegramObj['WebApp'];
        if (webAppObj != null) {
          final chatObj = webAppObj['chat'];
          print('🔧 JS chat object: $chatObj');
          
          if (chatObj != null) {
            final chatId = chatObj['id'];
            final chatType = chatObj['type'];
            print('🔧 Chat ID: $chatId, Type: $chatType');
            
            if (chatType == 'private' && chatId != null) {
              print('✅ User ID через JS API: $chatId');
              return chatId.toString();
            }
          }
        }
      }
    } catch (e) {
      print('❌ Ошибка JS API: $e');
    }
    
    print('❌ User ID не найден ни одним из способов');
    return null;
  } catch (e) {
    print('💥 Общая ошибка: $e');
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
