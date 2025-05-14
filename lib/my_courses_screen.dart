import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soar_quest/soar_quest.dart';

class LMSMyCoursesScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> collection;
  final IconData? icon;

  LMSMyCoursesScreen({
    required this.title,
    required this.collection,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<bool>(
        future: _isAdmin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final isAdmin = snapshot.data!;
          final user = _getUserInfo();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${user['firstName']} ${user['lastName']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        user['username'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isAdmin)
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _navigateToAdminSettings(context),
                            child: const Text('Admin Settings'),
                          ),
                        ),
                      const SizedBox(height: 24),
                      const Text(
                        'Favorite Courses',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCoursesList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('Admin Mode') ?? false;
  }

  Map<String, dynamic> _getUserInfo() {
    // Здесь должна быть логика получения информации о пользователе из Telegram
    return {
      'firstName': 'User',
      'lastName': 'Name',
      'username': '@username',
    };
  }

  void _navigateToAdminSettings(BuildContext context) {
    // Навигация к настройкам администратора
  }

  Widget _buildCoursesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: collection.length,
      itemBuilder: (context, index) {
        final course = collection[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Image.network(
              course['Course Image'] ?? 'https://via.placeholder.com/50',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(course['Course Title'] ?? 'Untitled'),
            subtitle: Text(course['author'] ?? 'Unknown Author'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Навигация к деталям курса
            },
          ),
        );
      },
    );
  }
}
