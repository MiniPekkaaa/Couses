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
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 80),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Image.network(
            course['Image'] != null && course['Image'] is List && course['Image'].isNotEmpty
                ? course['Image'][0]['url']
                : 'https://via.placeholder.com/50',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          title: Text(
            course['Name'] ?? 'Untitled',
            overflow: TextOverflow.visible,
            maxLines: null,
          ),
          subtitle: course['author'] != null && course['author'].toString().isNotEmpty 
              ? Text(course['author']) 
              : null,
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
                  Center(
                    child: Text(
                      course['Name'] ?? 'Untitled',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (course['author'] != null && course['author'].toString().isNotEmpty)
                    Text(
                      'Автор: ${course['author']}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 16),
                  MarkdownBody(
                    data: forceLineBreaks(normalizeMarkdown(boldLineToHeader(course['Description'] ?? 'No description'))),
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      a: const TextStyle(color: Colors.blue),
                      code: const TextStyle(
                        backgroundColor: Color(0xFFF5F5F5),
                        fontFamily: 'monospace',
                      ),
                      p: const TextStyle(height: 1.5),
                      h1: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.7),
                      h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.6),
                      h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, height: 1.5),
                      pPadding: const EdgeInsets.only(bottom: 12),
                      h1Padding: const EdgeInsets.only(bottom: 16, top: 24),
                      h2Padding: const EdgeInsets.only(bottom: 14, top: 20),
                      h3Padding: const EdgeInsets.only(bottom: 12, top: 16),
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
                          .where((lesson) {
                            final courseField = lesson['Course'];
                            if (courseField == null) return false;
                            if (courseField is List) {
                              return courseField.contains(course['id']);
                            }
                            if (courseField is String) {
                              return courseField == course['id'];
                            }
                            return false;
                          })
                          .toList();
                      lessons.sort((a, b) => (a['Order'] ?? 0).compareTo(b['Order'] ?? 0));
                      if (lessons.isEmpty) {
                        return const Text('Нет уроков');
                      }
                      // Группировка по модулям
                      final List<Widget> lessonWidgets = [];
                      final Set<String> shownModules = {};
                      for (int i = 0; i < lessons.length; i++) {
                        final lesson = lessons[i];
                        final module = lesson['Module'];
                        if (module != null && module.toString().trim().isNotEmpty) {
                          if (!shownModules.contains(module)) {
                            // Собираем все уроки этого модуля
                            final moduleLessons = lessons.where((l) => l['Module'] == module).toList();
                            lessonWidgets.add(
                              Card(
                                color: Colors.blue.shade50,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(minHeight: 80),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    title: Text(
                                      'Перейти к модулю: $module (${moduleLessons.length} уроков)', 
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.visible,
                                      maxLines: null,
                                    ),
                                    trailing: const Icon(Icons.folder_special),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ModuleLessonsScreen(moduleName: module, lessons: moduleLessons, allCourseLessons: lessons),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                            shownModules.add(module);
                          }
                          // Не добавляем сами уроки модуля в основной список
                          continue;
                        }
                        // Урок без модуля — обычная карточка
                        lessonWidgets.add(
                          Card(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 80),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                title: Text(
                                  lesson['Name'] ?? '',
                                  overflow: TextOverflow.visible,
                                  maxLines: null,
                                ),
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
                            ),
                          ),
                        );
                      }
                      return ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: lessonWidgets,
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

  List<Widget> _parseRichContent(BuildContext context, String content, Map<String, dynamic> lesson) {
    final List<Widget> widgets = [];
    final videoReg = RegExp(r'\{video (\d+)\}');
    final imageReg = RegExp(r'\{image (\d+)\}');
    StringBuffer markdownBuffer = StringBuffer();
    bool videoInserted = false;

    void flushMarkdown() {
      final text = markdownBuffer.toString().trim();
      if (text.isNotEmpty) {
        widgets.add(
          MarkdownBody(
            data: forceLineBreaks(normalizeMarkdown(boldLineToHeader(text))),
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              a: const TextStyle(color: Colors.blue),
              code: const TextStyle(
                backgroundColor: Color(0xFFF5F5F5),
                fontFamily: 'monospace',
              ),
              p: const TextStyle(height: 1.5),
              h1: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.7),
              h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.6),
              h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, height: 1.5),
              pPadding: const EdgeInsets.only(bottom: 12),
              h1Padding: const EdgeInsets.only(bottom: 16, top: 24),
              h2Padding: const EdgeInsets.only(bottom: 14, top: 20),
              h3Padding: const EdgeInsets.only(bottom: 12, top: 16),
            ),
            builders: {'a': LinkWithCopyButtonBuilder()},
          ),
        );
        markdownBuffer.clear();
      }
    }

    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      final videoMatch = videoReg.firstMatch(trimmed);
      if (videoMatch != null) {
        flushMarkdown();
        final n = int.tryParse(videoMatch.group(1)!);
        if (n != null) {
          final key = 'video $n';
          final value = lesson[key];
          if (value != null && value is List && value.isNotEmpty && value[0]['url'] != null) {
            widgets.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: VideoPlayerWidget(videoUrl: value[0]['url']),
            ));
            videoInserted = true;
          }
        }
        continue;
      }
      final imageMatch = imageReg.firstMatch(trimmed);
      if (imageMatch != null) {
        flushMarkdown();
        final n = int.tryParse(imageMatch.group(1)!);
        if (n != null) {
          final key = 'image $n';
          final value = lesson[key];
          if (value != null && value is List && value.isNotEmpty && value[0]['url'] != null) {
            widgets.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Image.network(value[0]['url'], errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
            ));
          }
        }
        continue;
      }
      markdownBuffer.writeln(line);
    }
    flushMarkdown();
    // Если ни одного видео не вставили, ищем первое доступное видео (video 1 ... video 6) и вставляем его в конец
    if (!videoInserted) {
      for (int i = 1; i <= 6; i++) {
        final key = 'video $i';
        if (lesson[key] != null && lesson[key] is List && lesson[key].isNotEmpty && lesson[key][0]['url'] != null) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: VideoPlayerWidget(videoUrl: lesson[key][0]['url']),
          ));
          break;
        }
      }
    }
    return widgets;
  }

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
                  data: forceLineBreaks(normalizeMarkdown(boldLineToHeader(lesson['Description'] ?? ''))),
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    a: const TextStyle(color: Colors.blue),
                    code: const TextStyle(
                      backgroundColor: Color(0xFFF5F5F5),
                      fontFamily: 'monospace',
                    ),
                    p: const TextStyle(height: 1.5),
                    h1: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.7),
                    h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.6),
                    h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, height: 1.5),
                    pPadding: const EdgeInsets.only(bottom: 12),
                    h1Padding: const EdgeInsets.only(bottom: 16, top: 24),
                    h2Padding: const EdgeInsets.only(bottom: 14, top: 20),
                    h3Padding: const EdgeInsets.only(bottom: 12, top: 16),
                  ),
                  builders: {'a': LinkWithCopyButtonBuilder()},
                ),
              ),
            const Divider(height: 32, thickness: 1),
            ..._parseRichContent(context, lesson['Content'] ?? '', lesson),
            const SizedBox(height: 24),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: AirtableService.fetchLessons(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final allLessons = snapshot.data!;
                // Универсальная фильтрация по курсу
                final currentCourseLessons = allLessons.where((l) {
                  final courseField = l['Course'];
                  final currentCourseField = lesson['Course'];
                  if (courseField == null || currentCourseField == null) return false;
                  if (courseField is List && currentCourseField is List) {
                    return courseField.any((id) => currentCourseField.contains(id));
                  } else if (courseField is List) {
                    return courseField.contains(currentCourseField);
                  } else if (currentCourseField is List) {
                    return currentCourseField.contains(courseField);
                  } else {
                    return courseField == currentCourseField;
                  }
                }).toList()
                  ..sort((a, b) => (a['Order'] ?? 0).compareTo(b['Order'] ?? 0));

                final currentIndex = currentCourseLessons.indexWhere((l) => l['id'] == lesson['id']);
                if (currentIndex == -1) {
                  return const SizedBox.shrink();
                }

                // Проверяем, является ли этот урок последним в своём модуле
                final module = lesson['Module'];
                bool isLastInModule = false;
                if (module != null && module.toString().trim().isNotEmpty) {
                  final moduleLessons = currentCourseLessons.where((l) => l['Module'] == module).toList()
                    ..sort((a, b) => (a['Order'] ?? 0).compareTo(b['Order'] ?? 0));
                  if (moduleLessons.isNotEmpty && moduleLessons.last['id'] == lesson['id']) {
                    isLastInModule = true;
                  }
                }

                // Если это последний урок модуля и после него идёт модуль — показываем кнопку перехода к следующему модулю
                if (isLastInModule && currentIndex < currentCourseLessons.length - 1) {
                  final next = currentCourseLessons[currentIndex + 1];
                  final nextModule = next['Module'];
                  if (nextModule != null && nextModule.toString().trim().isNotEmpty) {
                    final nextModuleLessons = currentCourseLessons.where((l) => l['Module'] == nextModule).toList();
                    return Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ModuleLessonsScreen(moduleName: nextModule, lessons: nextModuleLessons, allCourseLessons: currentCourseLessons),
                            ),
                          );
                        },
                        icon: const Icon(Icons.folder_special),
                        label: Text('Перейти к модулю: $nextModule (${nextModuleLessons.length} уроков)'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    );
                  }
                }

                // Обычная логика перехода к следующему уроку
                if (currentIndex < currentCourseLessons.length - 1) {
                  final nextLesson = currentCourseLessons[currentIndex + 1];
                  return Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonDetailScreen(lesson: nextLesson),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: Text('Перейти к уроку: ${nextLesson['Name'] ?? ''}'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Новый экран для отображения уроков модуля
class ModuleLessonsScreen extends StatelessWidget {
  final String moduleName;
  final List<Map<String, dynamic>> lessons;
  final List<Map<String, dynamic>>? allCourseLessons; // все уроки курса (для поиска следующего модуля/урока)

  const ModuleLessonsScreen({Key? key, required this.moduleName, required this.lessons, this.allCourseLessons}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(moduleName)),
      body: ListView.builder(
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          final isLast = index == lessons.length - 1;
          return Column(
            children: [
              Card(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 80),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      lesson['Name'] ?? '',
                      overflow: TextOverflow.visible,
                      maxLines: null,
                    ),
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
                ),
              ),
              if (isLast && allCourseLessons != null)
                _buildNextButton(context, lesson, allCourseLessons!),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, Map<String, dynamic> lastLesson, List<Map<String, dynamic>> allLessons) {
    // Найти следующий элемент после последнего урока модуля в общем списке курса
    final sortedLessons = List<Map<String, dynamic>>.from(allLessons)
      ..sort((a, b) => (a['Order'] ?? 0).compareTo(b['Order'] ?? 0));
    final lastIndex = sortedLessons.indexWhere((l) => l['id'] == lastLesson['id']);
    if (lastIndex == -1 || lastIndex >= sortedLessons.length - 1) return const SizedBox.shrink();
    final next = sortedLessons[lastIndex + 1];
    final nextModule = next['Module'];
    if (nextModule != null && nextModule.toString().trim().isNotEmpty) {
      // Переход к следующему модулю
      final nextModuleLessons = sortedLessons.where((l) => l['Module'] == nextModule).toList();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ModuleLessonsScreen(moduleName: nextModule, lessons: nextModuleLessons, allCourseLessons: allLessons),
                ),
              );
            },
            icon: const Icon(Icons.folder_special),
            label: Text('Перейти к модулю: $nextModule (${nextModuleLessons.length} уроков)'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      );
    } else {
      // Переход к следующему одиночному уроку
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonDetailScreen(lesson: next),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: Text('Перейти к уроку: ${next['Name'] ?? ''}'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      );
    }
  }
}

String forceLineBreaks(String text) => text.replaceAll('\n', '  \n');

String boldLineToHeader(String text) {
  final lines = text.split('\n');
  return lines.map((line) {
    final trimmed = line.trim();
    // Ищем строку, которая начинается и заканчивается на **, допускаем пробелы/табы между **
    final match = RegExp(r'^\*{2}\s*(.*?)\s*\*{2} 0-]*$').firstMatch(trimmed);
    if (match != null) {
      // Убираем все невидимые символы и пробелы вокруг текста внутри **
      final headerText = match.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim();
      return '### $headerText';
    }
    return line;
  }).join('\n');
}

String normalizeMarkdown(String text) {
  final lines = text.split('\n');
  return lines.map((line) {
    String l = line.trim();
    // Нормализуем заголовки: ###   текст  => ### текст
    final headerMatch = RegExp(r'^(#{1,6})\s*(.*?)\s* -\u001f\u007f]*$').firstMatch(l);
    if (headerMatch != null) {
      final hashes = headerMatch.group(1)!;
      final content = headerMatch.group(2)!.replaceAll(RegExp(r'\s+'), ' ').trim();
      l = '$hashes $content';
    }
    // Нормализуем жирный текст: ** текст ** => **текст**
    l = l.replaceAllMapped(RegExp(r'\*\*\s*(.*?)\s*\*\*'), (m) => '**${m[1]!.replaceAll(RegExp(r'\s+'), ' ').trim()}**');
    // Нормализуем курсив: * текст * => *текст*
    l = l.replaceAllMapped(RegExp(r'\*\s*(.*?)\s*\*'), (m) => '*${m[1]!.replaceAll(RegExp(r'\s+'), ' ').trim()}*');
    return l;
  }).join('\n');
}
