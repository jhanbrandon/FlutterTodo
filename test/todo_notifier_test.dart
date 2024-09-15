import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertodo/main.dart';

void main() {
  group('TodoNotifier Tests', () {
    test('Initial state is an empty list', () {
      final notifier = TodoNotifier();
      expect(notifier.state, []);
    });

    test('Add a todo to the list', () {
      final notifier = TodoNotifier();

      notifier.addTodo('Test Task');
      expect(notifier.state.length, 1);
      expect(notifier.state[0].description, 'Test Task');
      expect(notifier.state[0].isCompleted, false);
    });

    test('Toggle todo completion status', () {
      final notifier = TodoNotifier();

      notifier.addTodo('Test Task');
      expect(notifier.state[0].isCompleted, false);

      notifier.toggleTodoStatus(0);
      expect(notifier.state[0].isCompleted, true);

      notifier.toggleTodoStatus(0);
      expect(notifier.state[0].isCompleted, false);
    });

    test('Remove a todo from the list', () {
      final notifier = TodoNotifier();

      notifier.addTodo('Task 1');
      notifier.addTodo('Task 2');
      expect(notifier.state.length, 2);

      notifier.removeTodoAt(0);
      expect(notifier.state.length, 1);
      expect(notifier.state[0].description, 'Task 2');
    });
  });
}
