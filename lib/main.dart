import 'package:flutter/material.dart';
import 'course_select_screen.dart';
import 'nocodb_service.dart';
import 'dart:html' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Очищаем кеш Flutter при запуске
  PaintingBinding.instance.imageCache.clear();
  PaintingBinding.instance.imageCache.clearLiveImages();
  runApp(MyApp());
}

class NotAuthorizedScreen extends StatelessWidget {
  final String botLink;
  const NotAuthorizedScreen({super.key, required this.botLink});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 32),
              Text(
                'Вы не зарегистрированы в системе',
                style: Theme.of(context).textTheme.titleLarge,
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
      ),
    );
  }
}

Future<bool> checkUserRegistered() async {
  // TODO: Реализовать получение user_id через JS interop для Telegram WebApp
  // Сейчас всегда возвращает false для теста
  return false;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TevaLearn Courses',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(
        future: checkUserRegistered(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (!snapshot.data!) {
            return const NotAuthorizedScreen(botLink: 'https://t.me/school_life_otto_bot?start=register');
          }
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: AirtableService.fetchCourses(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
