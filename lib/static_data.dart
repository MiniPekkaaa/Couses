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
          'description': 'Основы языка Python и его применение',
          'content': [
            {'type': 'text', 'data': 'Python — это современный, простой и мощный язык программирования. Он используется для веб-разработки, анализа данных, автоматизации и многого другого.'},
            {'type': 'image', 'data': 'https://upload.wikimedia.org/wikipedia/commons/c/c3/Python-logo-notext.svg'},
            {'type': 'text', 'data': 'Python легко читается и пишется. Пример кода:'},
            {'type': 'code', 'data': 'print("Hello, world!")'},
            {'type': 'quiz', 'data': {'question': 'Как вывести текст на экран в Python?', 'options': ['echo', 'print', 'console.log', 'output'], 'answer': 'print'}}
          ]
        },
        {
          'id': '2',
          'title': 'Переменные и типы данных',
          'duration': '45 минут',
          'video': 'https://example.com/video2',
          'description': 'Работа с переменными и основными типами данных',
          'content': [
            {'type': 'text', 'data': 'В Python переменные не требуют явного указания типа.'},
            {'type': 'code', 'data': 'a = 5\nb = "строка"\nc = 3.14'},
            {'type': 'text', 'data': 'Основные типы данных: int, float, str, bool, list, dict.'},
            {'type': 'quiz', 'data': {'question': 'Какой тип данных у переменной b = "строка"?', 'options': ['int', 'str', 'list', 'bool'], 'answer': 'str'}}
          ]
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
          'description': 'Принципы создания пользовательских интерфейсов',
          'content': [
            {'type': 'text', 'data': 'UI (User Interface) — это то, как выглядит и ощущается приложение для пользователя.'},
            {'type': 'image', 'data': 'https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaFX_UI.png'},
            {'type': 'text', 'data': 'Важные принципы: простота, понятность, доступность.'},
            {'type': 'quiz', 'data': {'question': 'Что означает UI?', 'options': ['User Interface', 'User Internet', 'Universal Input', 'Unique Idea'], 'answer': 'User Interface'}}
          ]
        },
        {
          'id': '4',
          'title': 'Прототипирование',
          'duration': '90 минут',
          'video': 'https://example.com/video4',
          'description': 'Создание прототипов в Figma',
          'content': [
            {'type': 'text', 'data': 'Прототип — это интерактивная модель будущего интерфейса.'},
            {'type': 'image', 'data': 'https://upload.wikimedia.org/wikipedia/commons/3/33/Figma-logo.svg'},
            {'type': 'text', 'data': 'Figma — популярный инструмент для прототипирования.'},
            {'type': 'quiz', 'data': {'question': 'Для чего нужен прототип?', 'options': ['Для тестирования идей', 'Для публикации', 'Для рекламы', 'Для SEO'], 'answer': 'Для тестирования идей'}}
          ]
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
          'description': 'Введение в социальные медиа',
          'content': [
            {'type': 'text', 'data': 'SMM (Social Media Marketing) — это продвижение через соцсети.'},
            {'type': 'image', 'data': 'https://upload.wikimedia.org/wikipedia/commons/5/51/Facebook_f_logo_%282019%29.svg'},
            {'type': 'text', 'data': 'Главное — знать свою аудиторию и делать интересный контент.'},
            {'type': 'quiz', 'data': {'question': 'Что такое SMM?', 'options': ['Social Media Marketing', 'Search Media Marketing', 'Simple Media Management', 'Super Marketing Method'], 'answer': 'Social Media Marketing'}}
          ]
        },
        {
          'id': '6',
          'title': 'Контент-план',
          'duration': '60 минут',
          'video': 'https://example.com/video6',
          'description': 'Создание эффективного контент-плана',
          'content': [
            {'type': 'text', 'data': 'Контент-план — это расписание публикаций для соцсетей.'},
            {'type': 'image', 'data': 'https://upload.wikimedia.org/wikipedia/commons/4/4e/Calendar_icon_2.svg'},
            {'type': 'text', 'data': 'Планируйте публикации заранее и анализируйте вовлечённость.'},
            {'type': 'quiz', 'data': {'question': 'Для чего нужен контент-план?', 'options': ['Для планирования публикаций', 'Для SEO', 'Для рекламы', 'Для дизайна'], 'answer': 'Для планирования публикаций'}}
          ]
        }
      ]
    }
  ];
}
