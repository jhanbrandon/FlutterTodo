import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class TodoStorage {
  static Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosString = prefs.getString('todos');
    if (todosString != null) {
      final List<dynamic> decoded = jsonDecode(todosString);
      return decoded.map((item) => Todo(
        description: item['description'],
        isCompleted: item['isCompleted'],
      )).toList();
    }
    return [];
  }

  static Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final todosString = jsonEncode(todos.map((todo) => {
      'description': todo.description,
      'isCompleted': todo.isCompleted,
    }).toList());
    await prefs.setString('todos', todosString);
  }
}
