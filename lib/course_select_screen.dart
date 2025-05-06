import 'package:flutter/material.dart';
import 'nocodb_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit/media_kit.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({required this.videoUrl, super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final player = Player();
  late final videoController = VideoController(player);

  @override
  void initState() {
    super.initState();
    player.open(Media(widget.videoUrl));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Video(
        controller: videoController,
      ),
    );
  }
}

class LinkWithCopyButtonBuilder extends MarkdownElementBuilder {
  static final _imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.webp'];
  static final _videoExtensions = ['.mp4', '.webm', '.mov', '.mkv', '.avi'];

  bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return _imageExtensions.any((ext) => lower.endsWith(ext));
  }

  bool _isDirectVideoUrl(String url) {
    final lower = url.toLowerCase();
    return (url.contains('archive.org') && _videoExtensions.any((ext) => lower.endsWith(ext)));
  }

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String? text = element.textContent;
    final String? href = element.attributes['href'];
    if (href == null) return const SizedBox();
    if (_isImageUrl(href)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Image.network(href, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
      );
    }
    if (_isDirectVideoUrl(href)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: VideoPlayerWidget(videoUrl: href),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication),
          child: Text(
            text ?? href,
            style: preferredStyle?.copyWith(color: Colors.blue, decoration: TextDecoration.underline),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 16),
          tooltip: 'Копировать адрес ссылки',
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: href));
          },
        ),
      ],
    );
  }
}

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
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      a: const TextStyle(color: Colors.blue),
                      code: const TextStyle(
                        backgroundColor: Color(0xFFF5F5F5),
                        fontFamily: 'monospace',
                      ),
                    ),
                    builders: {'a': LinkWithCopyButtonBuilder()},
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
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: MarkdownBody(
                  data: lesson['Description'] ?? '',
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    a: const TextStyle(color: Colors.blue),
                    code: const TextStyle(
                      backgroundColor: Color(0xFFF5F5F5),
                      fontFamily: 'monospace',
                    ),
                  ),
                  builders: {'a': LinkWithCopyButtonBuilder()},
                ),
              ),
            const Divider(height: 32, thickness: 1),
            MarkdownBody(
              data: lesson['Content'] ?? '',
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                a: const TextStyle(color: Colors.blue),
                code: const TextStyle(
                  backgroundColor: Color(0xFFF5F5F5),
                  fontFamily: 'monospace',
                ),
              ),
              builders: {'a': LinkWithCopyButtonBuilder()},
            ),
          ],
        ),
      ),
    );
  }
}
