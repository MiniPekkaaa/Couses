import 'package:flutter/material.dart';
import 'nocodb_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;


class CourseSelectScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> itemsCollection;
  final String categoryField;

  CourseSelectScreen({
    required this.title,
    required this.itemsCollection,
    required this.categoryField,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: itemsCollection.length,
        itemBuilder: (context, index) => _buildCourseCard(context, itemsCollection[index]),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Image.network(
          course['Image'] != null && course['Image'] is List && course['Image'].isNotEmpty
              ? course['Image'][0]['url']
              : 'https://via.placeholder.com/50',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(course['Name'] ?? 'Untitled'),
        subtitle: Text(course['Instructor'] ?? 'Unknown Instructor'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailScreen(course: course),
            ),
          );
        },
      ),
    );
  }
}

class CourseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course['Name'] ?? 'Course Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              course['Image'] != null && course['Image'] is List && course['Image'].isNotEmpty
                  ? course['Image'][0]['url']
                  : 'https://via.placeholder.com/150',
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['Name'] ?? 'Untitled',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Инструктор: ${course['Instructor'] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MarkdownBody(
                    data: course['Description'] ?? 'No description',
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 16),
                      h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      strong: const TextStyle(fontWeight: FontWeight.bold),
                      em: const TextStyle(fontStyle: FontStyle.italic),
                      blockquote: const TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      listBullet: const TextStyle(fontSize: 16),
                      a: const TextStyle(color: Colors.blue),
                      code: const TextStyle(
                        backgroundColor: Color(0xFFF5F5F5),
                        fontFamily: 'monospace',
                      ),
                    ),
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        launchUrl(Uri.parse(href));
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Уроки курса',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: AirtableService.fetchLessons(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final lessons = snapshot.data!
                          .where((lesson) =>
                              lesson['Course'] != null &&
                              (lesson['Course'] as List).contains(course['id']))
                          .toList();
                      if (lessons.isEmpty) {
                        return const Text('Нет уроков');
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = lessons[index];
                          return Card(
                            child: ListTile(
                              title: Text(lesson['Name'] ?? ''),
                              subtitle: Text(lesson['Duration'] ?? ''),
                              trailing: const Icon(Icons.play_circle_outline),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LessonDetailScreen(lesson: lesson),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LessonDetailScreen extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonDetailScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson['Name'] ?? 'Урок'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lesson['Description'] != null && lesson['Description'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Описание',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MarkdownBody(
                    data: lesson['Description'],
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 16),
                      h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      strong: const TextStyle(fontWeight: FontWeight.bold),
                      em: const TextStyle(fontStyle: FontStyle.italic),
                      blockquote: const TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      listBullet: const TextStyle(fontSize: 16),
                      a: const TextStyle(color: Colors.blue),
                      code: const TextStyle(
                        backgroundColor: Color(0xFFF5F5F5),
                        fontFamily: 'monospace',
                      ),
                    ),
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        launchUrl(Uri.parse(href));
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            const Text(
              'Содержание',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            MarkdownBody(
              data: lesson['Content'] ?? '',
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 16),
                h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                strong: const TextStyle(fontWeight: FontWeight.bold),
                em: const TextStyle(fontStyle: FontStyle.italic),
                blockquote: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                listBullet: const TextStyle(fontSize: 16),
                a: const TextStyle(color: Colors.blue),
                code: const TextStyle(
                  backgroundColor: Color(0xFFF5F5F5),
                  fontFamily: 'monospace',
                ),
              ),
              onTapLink: (text, href, title) {
                if (href != null) {
                  launchUrl(Uri.parse(href));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
