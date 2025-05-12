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
  bool _isPlaying = false;

  @override
  void dispose() {
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
    player.dispose();
    super.dispose();
  }

  void _playVideo() {
    player.open(Media(widget.videoUrl));
    setState(() {
      _isPlaying = true;
    });
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoWidget = Video(controller: videoController);
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _isPlaying
          ? videoWidget
          : Stack(
              children: [
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(Icons.videocam, color: Colors.white24, size: 80),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(48),
                          onTap: _playVideo,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(24),
                            child: const Icon(Icons.play_arrow, color: Colors.white, size: 64),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Смотреть видео',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class LinkWithCopyButtonBuilder extends MarkdownElementBuilder {
  static final _imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.webp'];

  bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return _imageExtensions.any((ext) => lower.endsWith(ext));
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
  final String title;
  final List<Map<String, dynamic>> itemsCollection;
  final String categoryField;

  CourseDetailScreen({
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

class LessonDetailScreen extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final List<Map<String, dynamic>>? allLessons;

  const LessonDetailScreen({Key? key, required this.lesson, this.allLessons}) : super(key: key);

  // Автоисправление markdown: убираем пробелы перед ** и __
  String _fixMarkdownFormatting(String text) {
    return text
      .replaceAllMapped(RegExp(r'\s+(\*\*|__)'), (m) => m[1]!)
      .replaceAllMapped(RegExp(r'(\*\*|__)\s+'), (m) => m[1]!);
  }

  List<Widget> _parseRichContent(BuildContext context, String content, Map<String, dynamic> lesson) {
    final List<Widget> widgets = [];
    final lines = content.split('\n');
    bool videoInserted = false;
    for (final line in lines) {
      bool matched = false;
      // Видео
      for (int i = 1; i <= 10; i++) {
        final key = 'video $i';
        final value = lesson[key];
        if (line.trim() == key && value != null && value is List && value.isNotEmpty && value[0]['url'] != null) {
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: VideoPlayerWidget(videoUrl: value[0]['url']),
          ));
          matched = true;
          videoInserted = true;
          break;
        }
      }
      // Картинки
      for (int i = 1; i <= 10; i++) {
        final key = 'image $i';
        final value = lesson[key];
        if (line.trim() == key && value != null && value is List && value.isNotEmpty && value[0]['url'] != null) {
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Image.network(value[0]['url'], errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
          ));
          matched = true;
          break;
        }
      }
      if (!matched) {
        widgets.add(
          MarkdownBody(
            data: _fixMarkdownFormatting(line),
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              a: const TextStyle(color: Colors.blue),
              code: const TextStyle(
                backgroundColor: Color(0xFFF5F5F5),
                fontFamily: 'monospace',
              ),
            ),
            builders: {'a': LinkWithCopyButtonBuilder()},
          ),
        );
      }
    }
    // Если ни одного видео не вставили, но есть video 1, вставляем его в конец
    if (!videoInserted && lesson['video 1'] != null && lesson['video 1'] is List && lesson['video 1'].isNotEmpty && lesson['video 1'][0]['url'] != null) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: VideoPlayerWidget(videoUrl: lesson['video 1'][0]['url']),
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    // Найти следующий урок по Order
    Map<String, dynamic>? nextLesson;
    if (allLessons != null && allLessons!.isNotEmpty) {
      final currentOrder = lesson['Order'] ?? 0;
      final sorted = List<Map<String, dynamic>>.from(allLessons!)
        ..sort((a, b) => (a['Order'] ?? 0).compareTo(b['Order'] ?? 0));
      final idx = sorted.indexWhere((l) => l['id'] == lesson['id']);
      if (idx != -1 && idx < sorted.length - 1) {
        nextLesson = sorted[idx + 1];
      }
    }
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
                  data: _fixMarkdownFormatting(lesson['Description'] ?? ''),
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
            ..._parseRichContent(context, lesson['Content'] ?? '', lesson),
            if (nextLesson != null)
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LessonDetailScreen(
                          lesson: nextLesson!,
                          allLessons: allLessons,
                        ),
                      ),
                    );
                  },
                  child: Text('Перейти к "${nextLesson!['Name'] ?? 'следующий урок'}"'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
