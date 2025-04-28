// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'main.dart';

class StaticData {
  static final List<Map<String, dynamic>> categories = [
    {
      'id': '1',
      'title': 'Программирование',
      'description': 'Курсы по различным языкам программирования',
      'image': 'https://i.ibb.co/dDP1ZGx/file-cover-2.png'
    },
    {
      'id': '2',
      'title': 'Дизайн',
      'description': 'Курсы по графическому и веб-дизайну',
      'image': 'https://i.ibb.co/dDP1ZGx/file-cover-2.png'
    },
    {
      'id': '3',
      'title': 'Маркетинг',
      'description': 'Курсы по цифровому маркетингу и SMM',
      'image': 'https://i.ibb.co/dDP1ZGx/file-cover-2.png'
    }
  ];

  static final List<Map<String, dynamic>> courses = [
    {
      'id': '1',
      'title': 'Python для начинающих',
      'instructor': 'Иван Петров',
      'image': 'https://i.ibb.co/dDP1ZGx/file-cover-2.png',
      'duration': '12 часов',
      'likes': '120',
      'price': 'Бесплатно',
      'categoryId': '1',
      'description': 'Базовый курс по Python для тех, кто только начинает программировать',
      'lessons': [
        {
          'id': '1',
          'title': 'Введение в Python',
          'duration': '30 минут',
          'video': 'https://example.com/video1',
          'description': 'Основы языка Python и его применение'
        },
        {
          'id': '2',
          'title': 'Переменные и типы данных',
          'duration': '45 минут',
          'video': 'https://example.com/video2',
          'description': 'Работа с переменными и основными типами данных'
        }
      ]
    },
    {
      'id': '2',
      'title': 'UI/UX дизайн',
      'instructor': 'Анна Сидорова',
      'image': 'https://i.ibb.co/dDP1ZGx/file-cover-2.png',
      'duration': '24 часа',
      'likes': '85',
      'price': '2999 руб',
      'categoryId': '2',
      'description': 'Создание пользовательских интерфейсов и улучшение пользовательского опыта',
      'lessons': [
        {
          'id': '3',
          'title': 'Основы UI дизайна',
          'duration': '60 минут',
          'video': 'https://example.com/video3',
          'description': 'Принципы создания пользовательских интерфейсов'
        },
        {
          'id': '4',
          'title': 'Прототипирование',
          'duration': '90 минут',
          'video': 'https://example.com/video4',
          'description': 'Создание прототипов в Figma'
        }
      ]
    },
    {
      'id': '3',
      'title': 'SMM для бизнеса',
      'instructor': 'Мария Иванова',
      'image': 'https://i.ibb.co/dDP1ZGx/file-cover-2.png',
      'duration': '18 часов',
      'likes': '150',
      'price': '1999 руб',
      'categoryId': '3',
      'description': 'Продвижение бизнеса в социальных сетях',
      'lessons': [
        {
          'id': '5',
          'title': 'Основы SMM',
          'duration': '45 минут',
          'video': 'https://example.com/video5',
          'description': 'Введение в социальные медиа'
        },
        {
          'id': '6',
          'title': 'Контент-план',
          'duration': '60 минут',
          'video': 'https://example.com/video6',
          'description': 'Создание эффективного контент-плана'
        }
      ]
    }
  ];
}

Future<void> testAdd() async {
  await categories.loadCollection();
  StaticData.categories.forEach((category) {
    final newDocId = category['id'] as String;
    if (!categories.docs.any((element) => element.id == newDocId)) {
      categories.docs.add(categories.newDoc(id: newDocId, source: category));
    }
  });
  await categories.saveCollection();

  await courses.loadCollection();
  StaticData.courses.forEach((course) {
    final newDocId = course['id'] as String;
    if (!courses.docs.any((element) => element.id == newDocId)) {
      courses.docs.add(courses.newDoc(
          id: newDocId, source: course['data'] as Map<String, dynamic>));
    }
  });
  await courses.saveCollection();

  await lessons.loadCollection();
  staticLessons.forEach((lesson) {
    final newDocId = lesson['id'] as String;
    if (!lessons.docs.any((element) => element.id == newDocId)) {
      lessons.docs.add(lessons.newDoc(
          id: newDocId, source: lesson['data'] as Map<String, dynamic>));
    }
  });
  await lessons.saveCollection();
}
